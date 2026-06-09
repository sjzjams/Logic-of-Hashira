import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/analytics/analytics.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/shutter_animation_widget.dart';
import 'image_input_service.dart';

/// 实时相机预览 + 拍照页。
///
/// 使用 `camera` 插件（Camera2 / AVFoundation 包装）打开后置摄像头，
/// 比 `image_picker` 走系统相机 Intent 帧率更高、可自定义分辨率；
/// 拍照后 `Navigator.pop(filePath)`，由调用方继续 Snapshot 链路。
///
/// 行为约定：
/// - 进入时打 `camera_live_open` 事件，拍照时打 `camera_live_capture`；
/// - 用户取消（返回按钮）时 `Navigator.pop(null)`，不打 `camera_live_capture`；
/// - 异常时通过 [ImageInputException] 上抛，UI 层走 Snapshot 失败态。
class LiveCaptureScreen extends StatefulWidget {
  const LiveCaptureScreen({super.key});

  @override
  State<LiveCaptureScreen> createState() => _LiveCaptureScreenState();
}

class _LiveCaptureScreenState extends State<LiveCaptureScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ShutterAnimationWidgetState> _shutterKey =
      GlobalKey<ShutterAnimationWidgetState>();
  CameraController? _controller;
  List<CameraDescription> _cameras = const <CameraDescription>[];
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isCapturing = false;
  String? _capturedPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AnalyticsService.instance.track(AnalyticsEventNames.cameraLiveOpen);
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      c.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// 异步初始化：枚举摄像头 → 选后置 → 创建 Controller → `initialize`。
  ///
  /// 函数级注释：失败时把异常 message 存到 [_errorMessage]，让 build 给出
  /// "重试 / 返回" 入口，避免在 initState 里直接弹 SnackBar。
  Future<void> _initialize() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const ImageInputException('No camera available on this device');
      }
      _cameras = cameras;
      // 优先选后置（背面），否则退到第一个。
      final CameraDescription back = cameras.firstWhere(
        (CameraDescription c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final CameraController controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isInitializing = false;
      });
    }
  }

  bool _animationDone = false;

  /// 拍照：成功则触发快门动画，动画结束后 `Navigator.pop(filePath)`。
  Future<void> _takePicture() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }
    setState(() {
      _isCapturing = true;
      _animationDone = false;
      _capturedPath = null;
    });

    // 拍照与快门动画并行触发，但 _maybePop 必须在两者都完成时才允许 pop。
    Future<void>? shutterFuture;
    try {
      // 1. 启动快门动效（闭合 → 弹性旋开）。
      shutterFuture = _shutterKey.currentState?.snap();

      // 2. 同时执行拍照。
      final XFile file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedPath = file.path;
      });
      AnalyticsService.instance.track(AnalyticsEventNames.cameraLiveCapture);

      // 3. 等待快门动画结束（最多 3 秒兜底）。
      if (shutterFuture != null) {
        await shutterFuture.timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            // 物理模拟异常：兜底直接认为动画完成，避免永远卡住。
          },
        );
      }

      if (!mounted) return;
      setState(() {
        _animationDone = true;
      });
      _maybePop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _animationDone = true;
        _errorMessage = 'Failed to take picture: $error';
      });
    }
  }

  void _onShutterComplete() {
    // 快门物理模拟结束时由 ShutterAnimationWidget 的 status 触发；
    // 当 _takePicture 的 await shutterFuture 结束时会主动 setState。
    // 此回调仅作为兼容性兜底。
    if (mounted) {
      setState(() {
        _animationDone = true;
      });
    }
    _maybePop();
  }

  void _maybePop() {
    if (!mounted) return;
    if (_capturedPath != null && _animationDone) {
      Navigator.of(context).pop<String>(_capturedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22, color: Colors.white),
          onPressed: () => Navigator.of(context).pop<String?>(null),
        ),
        title: const Text(
          'Live Capture',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
      );
    }
    if (_errorMessage != null) {
      return _ErrorView(
        message: _errorMessage!,
        onRetry: _initialize,
        onBack: () => Navigator.of(context).pop<String?>(null),
      );
    }
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Text(
          'Camera not ready',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ShutterAnimationWidget(
              key: _shutterKey,
              onComplete: _onShutterComplete,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _CameraHints(cameras: _cameras),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HandDrawnButton(
              text: 'Back',
              style: HandDrawnButtonStyle.secondary,
              onTap: () => Navigator.of(context).pop<String?>(null),
            ),
            _ShutterButton(busy: _isCapturing, onTap: _takePicture),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

/// 大圆形快门按钮，固定尺寸 64x64 居中，描边跟随 AppColors.inkText。
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: busy ? AppColors.softLilac : AppColors.canvas,
          border: Border.all(color: AppColors.inkText, width: 2),
        ),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.inkText,
                ),
              ),
      ),
    );
  }
}

/// 顶部提示行：展示当前摄像头方向，让用户确认对的是后置摄像头。
class _CameraHints extends StatelessWidget {
  const _CameraHints({required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    final bool hasBack = cameras.any(
      (CameraDescription c) => c.lensDirection == CameraLensDirection.back,
    );
    final String label = hasBack
        ? 'Rear camera • ${cameras.length} lens available'
        : 'Using front camera (no rear lens found)';
    return Text(
      label,
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              'Camera failed to start',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            HandDrawnButton(text: 'Retry', onTap: onRetry),
            const SizedBox(height: 10),
            HandDrawnButton(
              text: 'Back',
              style: HandDrawnButtonStyle.secondary,
              onTap: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
