import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/mag_bitplane.dart';

/// V1.2-D：Result 页"主体识别后再次发光收口"组件。
///
/// 与 [EdgeDisintegrateImage]（V1.1 通用版）的差异：
/// - 接收可选 [maskPath] (NCNN 真实 mask，与原图同分辨率)；
/// - Shader (edge_disintegrate.frag V1.2-D) 收到 mask 后把 Sobel glow
///   限制在主体像素内，避免背景假发光；
/// - 复用 .mag bit plane 解码器 (与 [DisintegrateView] 一致)；
/// - mask 缺失时自动回退到 V1.1 通用模式（无 glow 限制）。
///
/// 4 段动画节奏同 V1.1：
///   0.0–0.4  像素消融上升 → 主体显形
///   0.4–0.6  稳定期
///   0.6–0.85 主体边缘起光（受 mask 限制在主体范围内）
///   0.85–1.0 收口到中心
class EdgeGlowImage extends StatefulWidget {
  const EdgeGlowImage({
    super.key,
    required this.imagePath,
    this.maskPath,
    this.duration = const Duration(milliseconds: 1800),
    this.borderRadius = 24,
    this.intensity = 1.0,
    this.onComplete,
  });

  /// 本地图片绝对路径。
  final String imagePath;

  /// V1.2-D：NCNN 真实 mask 路径（.mag bit plane 或旧 PNG）;
  /// 为 null 时退化为 V1.1 通用模式。
  final String? maskPath;

  final Duration duration;
  final double borderRadius;
  final double intensity;
  final VoidCallback? onComplete;

  @override
  State<EdgeGlowImage> createState() => _EdgeGlowImageState();
}

class _EdgeGlowImageState extends State<EdgeGlowImage>
    with SingleTickerProviderStateMixin {
  static const String _shaderAsset = 'shaders/edge_disintegrate.frag';

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

  /// 一次性加载 Shader + 解码图片与 mask；任一失败进入 [Image.file] fallback。
  ///
  /// V1.2-D：mask 通道加载参考 [DisintegrateView._loadMaskFile]，
  /// 优先用 `.mag` bit plane 解码，缺省回退 PNG codec。
  Future<void> _load() async {
    try {
      final ui.FragmentProgram program =
          await ui.FragmentProgram.fromAsset(_shaderAsset);
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

      // 尝试加载 mask；失败则 _decodedMask = null,Shader 走 V1.1 通用模式。
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
  /// 失败返回 null,调用方降级到无 mask 模式。
  static Future<ui.Image?> _loadMaskFile(String path) async {
    try {
      final Uint8List bytes = await File(path).readAsBytes();
      if (path.toLowerCase().endsWith('.mag')) {
        return _decodeMagBitplane(bytes);
      }
      // 兼容旧 PNG (V1.2-C 协议)。
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      return null;
    }
  }

  /// MAG1 bit plane → RGBA8888 → [ui.Image]。
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
      return const SizedBox.shrink();
    }
    if (_loadError != null) {
      return _FallbackImage(
        imagePath: widget.imagePath,
        borderRadius: widget.borderRadius,
      );
    }
    if (!_ready || _decodedImage == null || _program == null) {
      return _LoadingPlaceholder(borderRadius: widget.borderRadius);
    }
    return AspectRatio(
      aspectRatio: _decodedImage!.width / _decodedImage!.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CustomPaint(
          painter: _EdgeGlowPainter(
            program: _program!,
            image: _decodedImage!,
            mask: _decodedMask,
            progress: _controller.value,
            intensity: widget.intensity,
          ),
        ),
      ),
    );
  }
}

/// Shader Painter。Uniform 索引与 edge_disintegrate.frag 顶部注释一致：
///   0=uSize.x  1=uSize.y  2=uTime  3=uGlowIntensity
///   4=uDisintegrate  5=uHasMask
class _EdgeGlowPainter extends CustomPainter {
  _EdgeGlowPainter({
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
    // 4 段时间映射 (与 V1.1 通用版一致)。
    final double disintegrate = _mapRange(progress, 0.0, 0.4, 0.0, 0.55) -
        _mapRange(progress, 0.4, 0.6, 0.0, 0.50);
    final double glow = _mapRange(progress, 0.6, 0.85, 0.4, 0.9) -
        _mapRange(progress, 0.85, 1.0, 0.0, 0.4);
    final double k = intensity.clamp(0.0, 1.5);
    final ui.FragmentShader shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, progress)
      ..setFloat(3, (glow * k).clamp(0.0, 1.0))
      ..setFloat(4, (disintegrate * k).clamp(0.0, 1.0))
      ..setFloat(5, mask != null ? 1.0 : 0.0)
      ..setImageSampler(0, image);
    if (mask != null) {
      shader.setImageSampler(1, mask!);
    }
    final Paint paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  static double _mapRange(double t, double start, double end, double min, double max) {
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
  bool shouldRepaint(covariant _EdgeGlowPainter old) {
    return old.image != image ||
        old.mask != mask ||
        old.program != program ||
        (old.progress - progress).abs() > 0.001 ||
        (old.intensity - intensity).abs() > 0.001;
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.borderRadius});
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
