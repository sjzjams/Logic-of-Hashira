import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 把一张本地图片用 "边缘发光 + 像素消融" Fragment Shader 渲染。
///
/// 行为约定：
/// - 进入页面后一次性加载 shader + 解码图片，缓存到 State；
/// - 通过 [AnimationController] 驱动 4 段动画：消融出 → 稳定 → 边缘起光 → 收口；
/// - 如果图片加载失败或平台不支持 fragment shader，回退到普通 `Image.file`；
/// - 不会重复触发 [AnimationController.forward]，可安全地放进 `ListView`。
class EdgeDisintegrateImage extends StatefulWidget {
  const EdgeDisintegrateImage({
    super.key,
    required this.imagePath,
    this.duration = const Duration(milliseconds: 1800),
    this.borderRadius = 24,

    /// V1.1 升级：动效强度倍率。
    /// - 0.0 = 完全关闭消融与发光,只显示原图；
    /// - 1.0 = 标准动效 (与 V1 一致)；
    /// - 1.2 = 增强动效 (被 NCNN 高置信度食物用)；
    /// 推荐:由 [SnapshotResult.confidence] 线性映射出 0.7~1.2 范围。
    this.intensity = 1.0,

    /// V1.1 升级：动效自然播完一次时回调。
    ///
    /// 设计目的:UI 可以在动效结束才显示「保存 / 重拍」按钮,让交互
    /// 节奏感更明确;若 widget 被 unmount,回调不会被触发。
    this.onComplete,
  });

  /// 本地图片绝对路径；为空时 widget 直接返回 SizedBox.shrink。
  final String imagePath;
  final Duration duration;
  final double borderRadius;
  final double intensity;
  final VoidCallback? onComplete;

  @override
  State<EdgeDisintegrateImage> createState() => _EdgeDisintegrateImageState();
}

class _EdgeDisintegrateImageState extends State<EdgeDisintegrateImage>
    with SingleTickerProviderStateMixin {
  static const String _shaderAsset = 'shaders/edge_disintegrate.frag';

  late final AnimationController _controller;
  ui.FragmentProgram? _program;
  ui.Image? _decodedImage;
  String? _loadError;
  bool _ready = false;
  // V1.1 升级：确保 onComplete 只触发一次。
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
    super.dispose();
  }

  void _onTick() {
    if (mounted) {
      setState(() {});
      // V1.1 升级：动效完成时回调给业务层。
      if (_controller.value >= 1.0 &&
          !_onCompleteFired &&
          widget.onComplete != null) {
        _onCompleteFired = true;
        widget.onComplete!();
      }
    }
  }

  /// 一次性加载 shader + 解码图片；任一失败就只走 [Image.file] fallback。
  ///
  /// 函数级注释：放在 initState 后立即调用，加载完成才 _ready = true；
  /// 此时启动 controller，避免动画在第一帧缺图。
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
      setState(() {
        _program = program;
        _decodedImage = frame.image;
        _ready = true;
        _loadError = null;
      });
      await _controller.forward(from: 0);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error.toString();
        _ready = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath.isEmpty) {
      return const SizedBox.shrink();
    }
    // 加载失败 → 退化到普通图片，不阻断 Snapshot 主链路。
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
          painter: _EdgeDisintegratePainter(
            program: _program!,
            image: _decodedImage!,
            progress: _controller.value,
            intensity: widget.intensity,
          ),
        ),
      ),
    );
  }
}

/// 把 [ui.FragmentProgram] + 当前进度绘制到一个矩形上。
///
/// Uniform 顺序必须和 `assets/shaders/edge_disintegrate.frag` 顶部注释一致：
///   0=uSize.x  1=uSize.y  2=uTime  3=uGlowIntensity  4=uDisintegrate
class _EdgeDisintegratePainter extends CustomPainter {
  _EdgeDisintegratePainter({
    required this.program,
    required this.image,
    required this.progress,
    this.intensity = 1.0,
  });

  final ui.FragmentProgram program;
  final ui.Image image;
  final double progress;

  /// V1.1 升级：动效强度倍率。0 = 不动,1 = 标准,1.2 = 增强。
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    // 4 段时间映射：
    //   0.0–0.4  像素消融上升（uDisintegrate: 0 → 0.55）
    //   0.4–0.6  稳定期（uDisintegrate 慢慢回到 0.05）
    //   0.6–1.0  边缘发光脉冲（uGlowIntensity: 0.4 → 0.9 → 0.5）
    final double disintegrate =
        _mapRange(progress, 0.0, 0.4, 0.0, 0.55) -
        _mapRange(progress, 0.4, 0.6, 0.0, 0.50);
    final double glow =
        _mapRange(progress, 0.6, 0.85, 0.4, 0.9) -
        _mapRange(progress, 0.85, 1.0, 0.0, 0.4);
    // 把 intensity 限制在合理区间,避免负数或极端值破坏视觉。
    final double k = intensity.clamp(0.0, 1.5);
    final ui.FragmentShader shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, progress)
      ..setFloat(3, (glow * k).clamp(0.0, 1.0))
      ..setFloat(4, (disintegrate * k).clamp(0.0, 1.0))
      ..setImageSampler(0, image);
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
  bool shouldRepaint(covariant _EdgeDisintegratePainter old) {
    return old.image != image ||
        old.program != program ||
        !_nearlyEqual(old.progress, progress) ||
        !_nearlyEqual(old.intensity, intensity);
  }

  static bool _nearlyEqual(double a, double b) => (a - b).abs() < 0.001;
}

/// 加载完成前的占位（与背景同色 + 居中 spinner），避免空白闪烁。
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

/// Shader 不可用 / 图片加载失败时的回退：直接展示原图。
///
/// 函数级注释：保留 Hero 区域视觉一致性，避免视觉特效"翻车"影响主链路。
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

/// 把 `dart:ui` 引用一次保留别名，便于未来扩展（例如画笔大小）。
// ignore: unused_element
typedef _UiImage = ui.Image;
