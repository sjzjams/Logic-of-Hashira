import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/mag_bitplane.dart';

/// PRD 模块二第 2 段：背景消融提取 V2 视图。
///
/// 视觉组成：
/// - 底层白色卡片（[Color(0xFFFFFFFF)]，模拟"消融后背景"）；
/// - 中层用 `disintegrate_bg.frag` 渲染原图：中心主体保留 + 边缘白色高光呼吸 +
///   背景按 hash 噪声 step/discard 渐隐；
/// - 顶层不绘制（保留可扩展性）。
///
/// 行为约定：
/// - 图片缺失 / Shader 不可用 → 退化为普通 `Image.file` 渲染，不阻断主链路；
/// - `[onComplete]` 仅触发一次，避免 setState 抖动；
/// - 动画时间由外部传入 [duration]，与 ProcessingViewV2 的 disintegratingDuration
///   保持一致时能精准对接阶段切换。
class DisintegrateView extends StatefulWidget {
  const DisintegrateView({
    super.key,
    required this.imagePath,
    this.maskPath,
    this.duration = const Duration(milliseconds: 1600),
    this.borderRadius = 24,
    this.intensity = 1.0,
    this.onComplete,
  });

  /// 本地图片绝对路径；为空时退化为 lilac 占位。
  final String imagePath;

  /// V1.2-C：NCNN 真实 mask 路径（8-bit 灰度 PNG，与原图同分辨率）。
  /// 为空时 Shader 走 V1.2-B 软椭圆 mask 模式。
  final String? maskPath;

  final Duration duration;
  final double borderRadius;
  final double intensity;
  final VoidCallback? onComplete;

  @override
  State<DisintegrateView> createState() => _DisintegrateViewState();
}

class _DisintegrateViewState extends State<DisintegrateView>
    with SingleTickerProviderStateMixin {
  static const String _shaderAsset = 'shaders/disintegrate_bg.frag';

  late final AnimationController _controller;
  ui.FragmentProgram? _program;
  ui.Image? _decodedImage;
  ui.Image? _decodedMask;
  String? _loadError;
  bool _ready = false;
  bool _onCompleteFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(_onTick);
    _load();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    _decodedImage?.dispose();
    _decodedMask?.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {});
    if (_controller.value >= 1.0 &&
        !_onCompleteFired &&
        widget.onComplete != null) {
      _onCompleteFired = true;
      widget.onComplete!();
    }
  }

  /// V1.2-C：若 [widget.maskPath] 非空，会再解码一次 mask 通道。
  ///
  /// V1.2-D：支持 `.mag` (MAG1 bit plane) 自定义格式；用 `decodeImageFromPixels`
  /// 零依赖解码为 `ui.Image`（R8 → RGBA8888 复制），不再走 PNG deflate。
  /// 解码失败时降级到软椭圆（V1.2-B 行为）而不是闪退。
  Future<void> _load() async {
    try {
      final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
        _shaderAsset,
      );
      final File file = File(widget.imagePath);
      if (!file.existsSync()) {
        throw FileSystemException('Image file missing', widget.imagePath);
      }
      final Uint8List bytes = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }

      // 尝试加载 mask；失败则保持 _decodedMask = null,Shader 走软椭圆。
      ui.Image? mask;
      final String? maskPath = widget.maskPath;
      if (maskPath != null &&
          maskPath.isNotEmpty &&
          File(maskPath).existsSync()) {
        mask = await _loadMaskFile(maskPath);
      }

      if (!mounted) {
        frame.image.dispose();
        mask?.dispose();
        return;
      }
      setState(() {
        _program = program;
        _decodedImage = frame.image;
        _decodedMask = mask;
        _ready = true;
        _loadError = null;
      });
      await _controller.forward(from: 0);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _ready = false;
      });
    }
  }

  /// 根据后缀选择 PNG codec 或 MAG1 bit plane 解码器。
  /// 任何失败都返回 null,调用方降级到软椭圆模式。
  static Future<ui.Image?> _loadMaskFile(String path) async {
    try {
      final Uint8List bytes = await File(path).readAsBytes();
      if (path.toLowerCase().endsWith('.mag')) {
        return _decodeMagBitplane(bytes);
      }
      // 兼容旧 PNG 格式 (V1.2-C 协议已废弃,保留一段时间以防降级路径)。
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      // 静默降级,不阻断主链路。
      return null;
    }
  }

  /// MAG1 bit plane 解码器。
  ///
  /// 格式：4 字节 "MAG1" + 4 字节 width(BE) + 4 字节 height(BE) + bit plane。
  /// bit plane 行优先,每字节 8 个像素,MSB first。
  ///
  /// 由于 Flutter 当前不支持 `PixelFormat.singleChannel`,
  /// 我们把单通道 mask 扩展为 RGBA8888 (R=mask, G=R, B=R, A=255),
  /// 然后用 `decodeImageFromPixels` 构造 `ui.Image`。
  /// Shader 仅读 R 通道,所以 G/B 复制 R 不会影响视觉效果。
  static Future<ui.Image> _decodeMagBitplane(Uint8List bytes) async {
    final MagBitplane decoded = decodeMagBitplane(bytes);
    final Uint8List rgba = decoded.toRgba();
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      decoded.width,
      decoded.height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) => completer.complete(img),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath.isEmpty) {
      return _PlaceholderTile(borderRadius: widget.borderRadius);
    }
    if (_loadError != null) {
      return _FallbackImage(
        imagePath: widget.imagePath,
        borderRadius: widget.borderRadius,
      );
    }
    if (!_ready || _decodedImage == null || _program == null) {
      return _LoadingTile(borderRadius: widget.borderRadius);
    }
    return AspectRatio(
      aspectRatio: _decodedImage!.width / _decodedImage!.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 底层：纯白卡片（消融目标态）
            const ColoredBox(color: Color(0xFFFFFFFF)),
            // 中层：Shader 渲染原图（主体保留 + 背景消融）
            CustomPaint(
              painter: _DisintegratePainter(
                program: _program!,
                image: _decodedImage!,
                mask: _decodedMask,
                progress: _controller.value,
                intensity: widget.intensity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 实际绘制 Shader 的 Painter。
///
/// Uniform 顺序与 `assets/shaders/disintegrate_bg.frag` 顶部注释一致：
///   0=uSize.x  1=uSize.y  2=uProgress  3=uDisintegrate
///   4=uMaskStrength  5=uHasMask
///   setImageSampler(0, image) → uImage
///   setImageSampler(1, mask)  → uMask
class _DisintegratePainter extends CustomPainter {
  _DisintegratePainter({
    required this.program,
    required this.image,
    this.mask,
    required this.progress,
    this.intensity = 1.0,
  });

  final ui.FragmentProgram program;
  final ui.Image image;
  final ui.Image? mask;
  final double progress;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    // 0.0~0.6 阶段：disintegrate 上升（背景开始消融）；
    // 0.6~1.0 阶段：保持 0.55 不再增加（避免完全消失）。
    final double disintegrate = _mapRange(progress, 0.0, 0.6, 0.0, 0.55);
    final double k = intensity.clamp(0.0, 1.5);
    final ui.FragmentShader shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, progress)
      ..setFloat(3, (disintegrate * k).clamp(0.0, 0.55))
      ..setFloat(4, 0.55)
      ..setFloat(5, mask != null ? 1.0 : 0.0)
      ..setImageSampler(0, image);
    if (mask != null) {
      shader.setImageSampler(1, mask!);
    }
    final Paint paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  /// 把 [t] 在 [start,end] 区间线性映射到 0..1；越界时返回 0 或 1。
  static double _mapRange(
    double t,
    double start,
    double end,
    double min,
    double max,
  ) {
    if (t <= start) {
      return min;
    }
    if (t >= end) {
      return max;
    }
    final double k = (t - start) / (end - start);
    return min + (max - min) * k;
  }

  @override
  bool shouldRepaint(covariant _DisintegratePainter old) {
    return old.image != image ||
        old.mask != mask ||
        old.program != program ||
        (old.progress - progress).abs() > 0.001 ||
        (old.intensity - intensity).abs() > 0.001;
  }
}

/// 无图片时的 lilac 占位（与 Result 页 _SampleResultHero 风格一致）。
class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({required this.borderRadius});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFEDE7F6), Color(0xFFCDBEF9)],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFFE7E4F4), width: 1.2),
        ),
        alignment: Alignment.center,
        child: const Text('🍱', style: TextStyle(fontSize: 56)),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({required this.borderRadius});
  final double borderRadius;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: const Color(0xFFEDE7F6),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 1.4),
          ),
        ),
      ),
    );
  }
}

/// Shader 不可用 / 图片加载失败时的回退。
class _FallbackImage extends StatelessWidget {
  const _FallbackImage({required this.imagePath, required this.borderRadius});
  final String imagePath;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return Container(
            color: const Color(0xFFEDE7F6),
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF6E5BA8),
            ),
          );
        },
      ),
    );
  }
}
