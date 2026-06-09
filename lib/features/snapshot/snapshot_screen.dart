import 'package:flutter/material.dart';

import '../../core/analytics/analytics.dart';
import '../../core/theme.dart';
import '../../core/widgets/edge_effect_intensity.dart';
import '../../core/widgets/edge_glow_image.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/hand_drawn_card.dart';
import '../../core/widgets/processing_view_v2.dart';
import '../../core/widgets/prototype_page.dart';
import '../../models/meal.dart';
import '../../models/nutrition.dart';
import '../nutrition/meal_repository.dart';
import 'foreground_segmentation_service.dart';
import 'foreground_segmenter_factory.dart';
import 'image_input_service.dart';
import 'live_capture_screen.dart';
import 'mock_snapshot_recognizer.dart';
import 'ncnn_snapshot_recognizer.dart';
import 'package_image_input_service.dart';
import 'snapshot_phase.dart';
import 'snapshot_result.dart';

/// Sprint 5+ 识别策略。
///
/// - [auto]：根据是否有原生 NCNN（Android 走 platform 通道）选择
///   [NcnnSnapshotRecognizer],否则回退到 [MockSnapshotRecognizer]。
/// - [mock]：强制走 Mock（用于 iOS / Web / 单元测试）。
/// - [ncnn]：强制走 NCNN（用于 [snapshot_capture] 真实链路调试）。
enum SnapshotRecognitionMode { auto, mock, ncnn }

/// Snapshot 主链路页面。
///
/// 设计原则：
/// - 只用本文件内的 [SnapshotPhase] 状态机驱动 UI；
/// - 拍摄/分析均为 Mock，真实接入在后续 Sprint 完成；
/// - 全部事件通过 [AnalyticsService] 上报，避免在 UI 文件中嵌入裸字符串。
class SnapshotScreen extends StatefulWidget {
  const SnapshotScreen({
    super.key,
    this.repository,
    this.recognitionMode = SnapshotRecognitionMode.auto,
  });

  /// 注入的饮食仓库；不传则走 [MealRepository.instance] 兜底。
  final MealRepository? repository;

  /// 识别策略；默认 [SnapshotRecognitionMode.auto],正式出包应当走
  /// NCNN 真实识别,Mock 仍保留供 iOS / Web 与 widget test 使用。
  final SnapshotRecognitionMode recognitionMode;

  @override
  State<SnapshotScreen> createState() => _SnapshotScreenState();
}

class _SnapshotScreenState extends State<SnapshotScreen> {
  SnapshotPhase _phase = SnapshotPhase.idle;
  SnapshotResult? _result;
  String? _errorMessage;
  SegmentationResult? _lastSegmentation;
  String? _imagePath;
  ImageInputSource? _lastInputSource;
  late final MockSnapshotRecognizer _mockRecognizer;
  late final NcnnSnapshotRecognizer _ncnnRecognizer;
  late final ImageInputService _imageInput;
  late final ForegroundSegmentationService _segmentation;
  late final MealRepository _repository;

  @override
  void initState() {
    super.initState();
    _mockRecognizer = MockSnapshotRecognizer();
    _ncnnRecognizer = const NcnnSnapshotRecognizer();
    _imageInput = PackageImageInputService();
    _segmentation = ForegroundSegmenterFactory.create();
    _repository = widget.repository ?? MealRepository.instance;
    AnalyticsService.instance.track(AnalyticsEventNames.snapshotOpen);
  }

  Future<void> _capture({String? sampleName}) async {
    if (_phase == SnapshotPhase.analyzing) {
      return;
    }
    setState(() {
      _phase = SnapshotPhase.analyzing;
      _errorMessage = null;
    });
    AnalyticsService.instance.track(
      AnalyticsEventNames.snapshotCapture,
      <String, Object?>{
        'input_source': _inputSourceLabel(_lastInputSource, sampleName),
        // ignore: use_null_aware_elements
        if (sampleName != null) 'sample': sampleName,
      },
    );

    try {
      // 走样本 (sample) 时不走原生通道,直接用 Mock。
      final SnapshotResult result = await _mockRecognizer.recognize(
        sampleName: sampleName,
      );
      if (!mounted) {
        return;
      }
      AnalyticsService.instance.track(
        AnalyticsEventNames.snapshotAnalysisSuccess,
        <String, Object?>{'confidence': result.confidence},
      );
      setState(() {
        _result = result;
        _phase = SnapshotPhase.result;
      });
    } on SnapshotRecognitionException catch (error) {
      if (!mounted) {
        return;
      }
      AnalyticsService.instance.track(
        AnalyticsEventNames.snapshotAnalysisFail,
        <String, Object?>{'reason': error.message},
      );
      setState(() {
        _phase = SnapshotPhase.failed;
        _errorMessage = error.message;
      });
    }
  }

  /// 真实识别入口：相机 / 相册路径走完 NCNN 分割后调用。
  ///
  /// - NCNN 模式 / auto 模式下Android:把 [SegmentationResult] 喂给
  ///   [NcnnSnapshotRecognizer],由它读出 topClassId 给出真实食物名。
  /// - Mock 模式:不调用,UI 永远走样本路径 (sampleName != null)。
  Future<void> _runRecognition() async {
    final SegmentationResult? seg = _lastSegmentation;
    if (seg == null) {
      return;
    }
    final SnapshotRecognitionMode mode = widget.recognitionMode;
    final bool useNcnn = switch (mode) {
      SnapshotRecognitionMode.ncnn => true,
      SnapshotRecognitionMode.mock => false,
      SnapshotRecognitionMode.auto => seg.topClassId != null,
    };
    if (!mounted) {
      return;
    }
    setState(() {
      _phase = SnapshotPhase.analyzing;
      _errorMessage = null;
    });
    try {
      final SnapshotResult result = useNcnn
          ? await _ncnnRecognizer.recognize(seg)
          : await _mockRecognizer.recognize();
      if (!mounted) {
        return;
      }
      AnalyticsService.instance.track(
        AnalyticsEventNames.snapshotAnalysisSuccess,
        <String, Object?>{'confidence': result.confidence},
      );
      setState(() {
        _result = result;
        _phase = SnapshotPhase.result;
      });
    } on SnapshotRecognitionException catch (error) {
      if (!mounted) {
        return;
      }
      AnalyticsService.instance.track(
        AnalyticsEventNames.snapshotAnalysisFail,
        <String, Object?>{'reason': error.message},
      );
      setState(() {
        _phase = SnapshotPhase.failed;
        _errorMessage = error.message;
      });
    }
  }

  /// 真实图像入口：相机 / 相册。
  ///
  /// 行为约定：
  /// - 用户取消时不打 `snapshot_capture` 事件；
  /// - 真实图片路径会记录到 `_imagePath`，供 Sprint 2.2-B 前景提取使用；
  /// - 真实路径会先走 [ForegroundSegmentationService]，再走营养识别。
  Future<void> _captureFromInput(ImageInputSource source) async {
    if (_phase == SnapshotPhase.analyzing ||
        _phase == SnapshotPhase.segmenting) {
      return;
    }
    String? path;
    try {
      path = switch (source) {
        ImageInputSource.camera => await _imageInput.captureFromCamera(),
        ImageInputSource.gallery => await _imageInput.pickFromGallery(),
        ImageInputSource.sample => null,
      };
    } on ImageInputException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _phase = SnapshotPhase.failed;
        _errorMessage = error.message;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    if (path == null) {
      // 用户取消，回到 idle。
      setState(() => _phase = SnapshotPhase.idle);
      return;
    }

    setState(() {
      _imagePath = path;
      _lastInputSource = source;
      _phase = SnapshotPhase.segmenting;
    });
    AnalyticsService.instance.track(
      AnalyticsEventNames.snapshotSegmentStart,
      <String, Object?>{'input_source': _inputSourceLabel(source, null)},
    );

    try {
      final SegmentationResult segmentation = await _segmentation.segment(path);
      _lastSegmentation = segmentation;
    } on SegmentationException catch (error) {
      if (!mounted) {
        return;
      }
      AnalyticsService.instance.track(
        AnalyticsEventNames.snapshotSegmentFail,
        <String, Object?>{'reason': error.message},
      );
      setState(() {
        _phase = SnapshotPhase.failed;
        _errorMessage = error.message;
      });
      return;
    }
    if (!mounted) {
      return;
    }
    AnalyticsService.instance.track(AnalyticsEventNames.snapshotSegmentSuccess);
    await _runRecognition();
  }

  void _retake() {
    setState(() {
      _phase = SnapshotPhase.idle;
      _result = null;
      _errorMessage = null;
    });
  }

  /// V1 升级 - 真实相机集成入口。
  ///
  /// 弹出 [LiveCaptureScreen] 走 `camera` 插件实时预览（Camera2 包装），
  /// 拍完拿到 path 后直接复用与 [_captureFromInput] 相同的 segment / 分析
  /// 流程。用户取消则保持 idle。
  Future<void> _captureLive() async {
    if (_phase == SnapshotPhase.analyzing ||
        _phase == SnapshotPhase.segmenting) {
      return;
    }
    final String? path = await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        builder: (_) => const LiveCaptureScreen(),
        fullscreenDialog: true,
      ),
    );
    if (!mounted || path == null) {
      return;
    }
    // 复用真实图像入口的分段 + 识别逻辑，但 input_source 标为 `live_camera`。
    setState(() {
      _imagePath = path;
      _lastInputSource = ImageInputSource.camera;
      _phase = SnapshotPhase.segmenting;
    });
    AnalyticsService.instance.track(
      AnalyticsEventNames.snapshotSegmentStart,
      <String, Object?>{'input_source': 'live_camera'},
    );
    try {
      // V1.2-C：把 segment 结果存到 _lastSegmentation,让处理页能拿到 mask。
      final SegmentationResult segResult = await _segmentation.segment(path);
      _lastSegmentation = segResult;
    } on SegmentationException catch (error) {
      if (!mounted) {
        return;
      }
      AnalyticsService.instance.track(
        AnalyticsEventNames.snapshotSegmentFail,
        <String, Object?>{'reason': error.message},
      );
      setState(() {
        _phase = SnapshotPhase.failed;
        _errorMessage = error.message;
      });
      return;
    }
    if (!mounted) {
      return;
    }
    AnalyticsService.instance.track(AnalyticsEventNames.snapshotSegmentSuccess);
    await _capture();
  }

  void _save() {
    final SnapshotResult? result = _result;
    if (result == null) {
      return;
    }
    final DateTime now = DateTime.now();
    final String mealId = 'meal_${now.microsecondsSinceEpoch}';
    final Meal meal = Meal(
      id: mealId,
      photoPath: _imagePath ?? '',
      thumbnailPath: _imagePath ?? '',
      foodName: result.foodName,
      confidence: result.confidence,
      mealType: _inferMealType(now),
      createdAt: now,
    );
    final Nutrition nutrition = Nutrition(
      mealId: mealId,
      calories: result.calories,
      protein: result.protein,
      carbs: result.carbs,
      fat: result.fat,
      fiber: result.fiber,
      weight: result.weightGrams,
    );
    _repository.addMeal(meal, nutrition);
    AnalyticsService.instance.track(
      AnalyticsEventNames.snapshotSave,
      <String, Object?>{
        'meal_name': result.foodName,
        'calories': result.calories.round(),
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.foodName} saved to today.'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  /// 简单按时段推断 MealType；Sprint 3 范围内不接入时区与用户设置。
  MealType _inferMealType(DateTime now) {
    final int hour = now.hour;
    if (hour < 11) {
      return MealType.breakfast;
    }
    if (hour < 15) {
      return MealType.lunch;
    }
    if (hour < 20) {
      return MealType.dinner;
    }
    return MealType.snack;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Food Snapshot',
          style: AppTypography.title(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.inkText,
          ),
        ),
        centerTitle: true,
      ),
      body: switch (_phase) {
        SnapshotPhase.idle => _IdleView(
          onCamera: () => _captureFromInput(ImageInputSource.camera),
          onGallery: () => _captureFromInput(ImageInputSource.gallery),
          onCapture: _capture,
          onLiveCapture: _captureLive,
        ),
        // V1.2-A：处理页动效升级到 V2（LOCATING → DISINTEGRATING）。
        // 业务层保持单态：segmenting 与 analyzing 共用同一视觉，
        // 由 ProcessingViewV2 内部按时间轴自动推进两段文案。
        // V1.2-B：disintegrating 阶段若有真实图片则改用 DisintegrateView 渲染。
        // V1.2-C：disintegrating 阶段若 NCNN 真实 mask 可用则把路径透传。
        SnapshotPhase.segmenting => _ProcessingV2View(
          imagePath: _imagePath,
          maskPath: _lastSegmentation?.maskPath,
        ),
        SnapshotPhase.analyzing => _ProcessingV2View(
          imagePath: _imagePath,
          maskPath: _lastSegmentation?.maskPath,
        ),
        SnapshotPhase.result => _ResultView(
          result: _result!,
          imagePath: _imagePath,
          maskPath: _lastSegmentation?.maskPath,
          onRetake: _retake,
          onSave: _save,
        ),
        SnapshotPhase.failed => _FailedView(
          message: _errorMessage,
          onRetry: _retake,
          onUseSample: () =>
              _capture(sampleName: MockSnapshotRecognizer.samples.first.name),
        ),
        SnapshotPhase.capturing => const _ProcessingV2View(),
      },
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({
    required this.onCamera,
    required this.onGallery,
    required this.onCapture,
    required this.onLiveCapture,
  });

  final Future<void> Function() onCamera;
  final Future<void> Function() onGallery;
  final Future<void> Function({String? sampleName}) onCapture;

  /// V1 升级：进入 [LiveCaptureScreen] 走 camera 插件实时预览。
  final Future<void> Function() onLiveCapture;

  @override
  Widget build(BuildContext context) {
    return PrototypePage(
      children: [
        const PrototypeHeader(title: 'Snap a meal', kicker: 'OR TEST A SAMPLE'),
        const SizedBox(height: 18),
        // Viewport 现在是可点入口：点击进入 LiveCaptureScreen（camera 插件实时预览）。
        _CameraViewport(onTap: onLiveCapture),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: HandDrawnButton(text: 'Take photo', onTap: onCamera),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HandDrawnButton(
                text: 'Pick from gallery',
                style: HandDrawnButtonStyle.secondary,
                onTap: onGallery,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Sample library',
          style: AppTypography.title(fontSize: 16, color: AppColors.inkText),
        ),
        const SizedBox(height: 8),
        // 高度从 92 提到 100,容纳 _SampleChip 主轴收缩后约 78px 的内容
        // (36 图标 + 6 间距 + 19 标题行高 + 16 分量行高) + 20 垂直 padding + 2.4 边框,
        // 修复 "RenderFlex overflowed by 7.4 pixels on the bottom"。
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              final sample = MockSnapshotRecognizer.samples[index];
              return _SampleChip(
                name: sample.name,
                portion: sample.portion,
                onTap: () => onCapture(sampleName: sample.name),
              );
            },
            separatorBuilder: (BuildContext _, int _) =>
                const SizedBox(width: 10),
            itemCount: MockSnapshotRecognizer.samples.length,
          ),
        ),
      ],
    );
  }
}

String _inputSourceLabel(ImageInputSource? source, String? sampleName) {
  if (sampleName != null) {
    return 'sample';
  }
  switch (source) {
    case ImageInputSource.camera:
      return 'camera';
    case ImageInputSource.gallery:
      return 'gallery';
    case ImageInputSource.sample:
      return 'sample';
    case null:
      return 'unknown';
  }
}

/// 轻量标记：在 Result 页 header 上显示当前图片路径是否存在，
/// 让 `_imagePath` 字段被 UI 显式消费，避免 `unused_field` 警告。
String snapshotScreenImageTag(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return '';
  }
  return ' • image ready';
}

class _CameraViewport extends StatelessWidget {
  const _CameraViewport({required this.onTap});

  /// V1 升级：点击后进入 [LiveCaptureScreen] 走 camera 插件实时预览。
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.softLilac,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_outlined,
                size: 32,
                color: AppColors.inkText,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to open live camera',
                style: AppTypography.body(
                  fontSize: 14,
                  color: AppColors.inkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Higher frame rate via Camera2',
                style: AppTypography.body(
                  fontSize: 11,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  const _SampleChip({
    required this.name,
    required this.portion,
    required this.onTap,
  });

  final String name;
  final String portion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        // 用 mainAxisSize.min 让 chip 高度由内容决定,避免 76 高度容器溢出。
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.softLilac,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(
                fontSize: 13,
                color: AppColors.inkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              portion,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                fontSize: 11,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// V1.2-A：处理页 V2 入口。
///
/// 函数级注释：
/// - 复用 V2 动效组件，4 角 L 形定位器 + LOCATING/DISINTEGRATING 文案；
/// - 阶段由 [ProcessingViewV2] 内部时间轴推进，UI 层无需关心；
/// - V1.2-B：在 disintegrating 阶段若传入图片路径，则切换为 DisintegrateView。
class _ProcessingV2View extends StatelessWidget {
  const _ProcessingV2View({this.imagePath, this.maskPath});

  final String? imagePath;
  final String? maskPath;

  @override
  Widget build(BuildContext context) {
    return ProcessingViewV2(imagePath: imagePath, maskPath: maskPath);
  }
}

class _ResultView extends StatefulWidget {
  const _ResultView({
    required this.result,
    required this.imagePath,
    required this.onRetake,
    required this.onSave,
    this.maskPath,
  });

  final SnapshotResult result;
  final String? imagePath;
  final VoidCallback onRetake;
  final VoidCallback onSave;

  /// V1.2-D：NCNN 真实 mask 路径，用于"主体识别后再次发光收口"。
  final String? maskPath;

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  /// V1.1 升级：动效期间隐藏 Save / Retake 按钮,完成后才浮出,提升仪式感。
  /// 走 sample 路径或动效已完成的回退路径默认视为"立即可用"。
  bool _effectCompleted = false;

  @override
  void initState() {
    super.initState();
    final String? path = widget.imagePath;
    if (path == null || path.isEmpty) {
      // 没有真实图片 → 没有动效 → 直接可用。
      _effectCompleted = true;
    }
  }

  void _onEffectComplete() {
    if (mounted) {
      setState(() {
        _effectCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SnapshotResult result = widget.result;
    final String? path = widget.imagePath;
    // V1.1 升级：把识别置信度线性映射到动效强度。
    final double intensity = edgeEffectIntensityForConfidence(
      result.confidence,
    );
    return PrototypePage(
      children: [
        PrototypeHeader(
          title: result.foodName,
          kicker:
              'Confidence ${(result.confidence * 100).toStringAsFixed(0)}%'
              '${snapshotScreenImageTag(widget.imagePath)}',
        ),
        // V1 升级 - Visual Effects: 真实图片走"边缘发光 + 像素消融" Fragment Shader；
        // sample / 识别 mock 路径没有本地图片，给一个 lilac 占位保持视觉一致。
        const SizedBox(height: 18),
        if (path != null && path.isNotEmpty)
          EdgeGlowImage(
            imagePath: path,
            maskPath: widget.maskPath,
            intensity: intensity,
            onComplete: _onEffectComplete,
          )
        else
          const _SampleResultHero(),
        const SizedBox(height: 18),
        HandDrawnCard(
          child: Column(
            children: [
              Text(
                '${result.calories.round()}',
                style: AppTypography.title(
                  fontSize: 56,
                  color: AppColors.inkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'KCAL',
                style: AppTypography.body(
                  fontSize: 12,
                  color: AppColors.grayText,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MacroTile(
                label: 'Protein',
                value: '${result.protein.round()}g',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroTile(
                label: 'Carbs',
                value: '${result.carbs.round()}g',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroTile(label: 'Fat', value: '${result.fat.round()}g'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroTile(
                label: 'Fiber',
                value: '${result.fiber.round()}g',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // V1.1 升级：动效未完成时,Save/Retake 按钮以低不透明度占位但不响应点击。
        // 这样做的好处:布局不抖动 + 仪式感更强。
        AnimatedOpacity(
          opacity: _effectCompleted ? 1.0 : 0.35,
          duration: const Duration(milliseconds: 400),
          child: IgnorePointer(
            ignoring: !_effectCompleted,
            child: Row(
              children: [
                Expanded(
                  child: HandDrawnButton(
                    text: 'Retake',
                    style: HandDrawnButtonStyle.secondary,
                    onTap: widget.onRetake,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HandDrawnButton(text: 'Save', onTap: widget.onSave),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return HandDrawnCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.title(fontSize: 22, color: AppColors.inkText),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.body(fontSize: 12, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }
}

/// Sample 路径下的 Result Hero 占位。
///
/// 函数级注释：因为 Mock 识别没有真实图片可渲染，避免 EdgeDisintegrateImage
/// 出现空图；这里用 lilac 渐变 + 食物 emoji 给出"虚位以待"的视觉。
class _SampleResultHero extends StatelessWidget {
  const _SampleResultHero();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFEDE7F6), Color(0xFFCDBEF9)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🍱', style: TextStyle(fontSize: 56)),
            SizedBox(height: 8),
            Text(
              'Sample result',
              style: TextStyle(
                color: AppColors.inkText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Live camera path will show shader effects',
              style: TextStyle(color: AppColors.grayText, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.message,
    required this.onRetry,
    this.onUseSample,
  });

  final String? message;
  final VoidCallback onRetry;

  /// FE-09 验收项：失败时允许用户直接切到样本（无需重新走相机/相册）。
  final VoidCallback? onUseSample;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.inkText, size: 36),
            const SizedBox(height: 12),
            Text(
              message ?? 'Analysis failed. Please try again.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                fontSize: 14,
                color: AppColors.grayText,
              ),
            ),
            const SizedBox(height: 18),
            HandDrawnButton(text: 'Retry', onTap: onRetry),
            if (onUseSample != null) ...[
              const SizedBox(height: 10),
              HandDrawnButton(
                text: 'Try a sample instead',
                style: HandDrawnButtonStyle.secondary,
                onTap: onUseSample!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
