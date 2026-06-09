import 'dart:async';

import 'package:flutter/foundation.dart';

/// NCNN 模型加载状态。
enum ModelLoadState {
  /// 未开始加载
  idle,

  /// 正在加载（后台 Isolate）
  loading,

  /// 加载完成，可推理
  ready,

  /// 加载失败（降级：允许相册/Sample 路径，但禁用实时分析）
  failed,
}

/// 模型加载进度信息。
class ModelLoadProgress {
  const ModelLoadProgress({
    this.state = ModelLoadState.idle,
    this.progress = 0.0,
    this.errorMessage,
  });

  final ModelLoadState state;
  final double progress;
  final String? errorMessage;

  bool get isReady => state == ModelLoadState.ready;

  ModelLoadProgress copyWith({
    ModelLoadState? state,
    double? progress,
    String? errorMessage,
  }) {
    return ModelLoadProgress(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }
}

/// 模型懒加载服务。
///
/// 设计目标：
///   Splash → Home（首屏 500ms 内可见）
///       ↓ 后台加载
///   模型就绪 → SNAP 按钮变为可点击
///
/// 监听方式：
/// ```dart
/// final svc = ModelLoaderService.instance;
/// svc.addListener(() {
///   if (svc.isReady) { /* 启用 SNAP */ }
/// });
/// ```
class ModelLoaderService extends ChangeNotifier {
  ModelLoaderService._();
  static final ModelLoaderService instance = ModelLoaderService._();

  ModelLoadProgress _progress = const ModelLoadProgress();
  ModelLoadProgress get progress => _progress;
  bool get isReady => _progress.isReady;
  ModelLoadState get state => _progress.state;

  /// 触发后台加载（应在 [main] → `runApp` 之后异步调用）。
  ///
  /// 实现策略（V1）：
  /// - 模拟 NCNN 模型加载耗时（800~1500ms 的 staged 进度条）；
  /// - 真实 NCNN 初始化通过 Android MethodChannel 或 Isolate 触发；
  /// - V1 不做真正的 NCNN init，因它会阻塞主线程 ~200ms + 无法在纯 Dart Isolate 中进行。
  ///   真实模型加载由 Android 侧 CameraX 初始化时自动完成（INF2）。
  ///
  /// 调用方通过 [isReady] 判断是否可启用实时分析功能。
  Future<void> preload() async {
    if (_progress.state == ModelLoadState.ready ||
        _progress.state == ModelLoadState.loading) {
      return;
    }

    _update(ModelLoadState.loading, 0.0);

    try {
      // V1: staged fake loading（进度条驱动的动画感知）。
      // 真实场景下替换为实际 NCNN init + asset 解压逻辑。
      await _simulateModelLoad();
      _update(ModelLoadState.ready, 1.0);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠ ModelLoaderService: preload failed ($e)');
      }
      _update(ModelLoadState.failed, 0.0, errorMessage: e.toString());
    }
  }

  void _update(ModelLoadState state, double progress, {String? errorMessage}) {
    _progress = _progress.copyWith(
      state: state,
      progress: progress,
      errorMessage: errorMessage,
    );
    notifyListeners();
  }

  /// 模拟分阶段加载进度（供首屏 SNAP 按钮 loading UI 使用）。
  Future<void> _simulateModelLoad() async {
    const List<Duration> stages = <Duration>[
      Duration(milliseconds: 300),
      Duration(milliseconds: 250),
      Duration(milliseconds: 300),
      Duration(milliseconds: 250),
    ];
    for (int i = 0; i < stages.length; i++) {
      await Future<void>.delayed(stages[i]);
      if (_progress.state != ModelLoadState.loading) return;
      _update(ModelLoadState.loading, (i + 1) / stages.length);
    }
  }

  /// 是否模型失败导致需要降级。
  bool get isDegraded => _progress.state == ModelLoadState.failed;
}
