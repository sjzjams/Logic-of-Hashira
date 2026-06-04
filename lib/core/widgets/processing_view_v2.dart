import 'package:flutter/material.dart';

import '../theme.dart';
import 'disintegrate_view.dart';
import 'l_corner_finder.dart';

/// PRD 模块二处理页的阶段枚举（动效层）。
///
/// 与 [SnapshotPhase] 解耦：
/// - 业务层只关心 segmenting / analyzing / result / failed；
/// - 动效层把 `analyzing` 细分为 `locating` + `disintegrating`，
///   通过定时器自动推进，不阻塞真实 NCNN 推理时间。
enum ProcessingStage { locating, disintegrating }

/// PRD 模块二“动态分析与消融提取页”动效版（V2）。
///
/// 设计要点：
/// - 顶部 `PROCESSING` kicker + 底部阶段文案 `LOCATING…` / `DISINTEGRATING…`；
/// - 4 个 L 型定位角标 [LCornerFinder] 在 ~1.2s 内从外框收紧到内框；
/// - 阶段切换使用 [AnimatedSwitcher] + 三个点循环动效；
/// - 阶段推进：locating 持续 1.4s → disintegrating 持续 1.6s → 回调 [onCompleted]；
/// - 取消：组件 [dispose] 时停止定时器与动画。
class ProcessingViewV2 extends StatefulWidget {
  const ProcessingViewV2({
    super.key,
    this.imagePath,
    this.onCompleted,
    this.locatingDuration = const Duration(milliseconds: 1400),
    this.disintegratingDuration = const Duration(milliseconds: 1600),
    this.cornerDuration = const Duration(milliseconds: 1200),
  });

  /// V1.2-B：进入 disintegrating 阶段时若提供图片路径，则用 DisintegrateView
  /// 渲染真实视觉（主体保留 + 背景消融）。空时退化为 L 形角标动画。
  final String? imagePath;

  /// 两阶段都播完后回调。
  final VoidCallback? onCompleted;
  final Duration locatingDuration;
  final Duration disintegratingDuration;
  final Duration cornerDuration;

  @override
  State<ProcessingViewV2> createState() => _ProcessingViewV2State();
}

class _ProcessingViewV2State extends State<ProcessingViewV2>
    with TickerProviderStateMixin {
  late final AnimationController _cornerController;
  ProcessingStage _stage = ProcessingStage.locating;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _cornerController = AnimationController(
      vsync: this,
      duration: widget.cornerDuration,
    );
    _cornerController.addListener(() {
      if (mounted) setState(() {});
    });
    _cornerController.forward();

    // 阶段推进：locating → disintegrating → 完成
    _scheduleStageTransition();
  }

  void _scheduleStageTransition() {
    Future<void>.delayed(widget.locatingDuration, () {
      if (_disposed || !mounted) return;
      setState(() => _stage = ProcessingStage.disintegrating);
      Future<void>.delayed(widget.disintegratingDuration, () {
        if (_disposed || !mounted) return;
        widget.onCompleted?.call();
      });
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _cornerController.dispose();
    super.dispose();
  }

  String _stageLabel(ProcessingStage stage) {
    switch (stage) {
      case ProcessingStage.locating:
        return 'LOCATING…';
      case ProcessingStage.disintegrating:
        return 'DISINTEGRATING…';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部 PROCESSING kicker
            const Text(
              'PROCESSING',
              style: TextStyle(
                color: AppColors.inkText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 22),
            // 主体可视化区域：locating 用 L 形角标，disintegrating 用真实消融。
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                child: _stage == ProcessingStage.locating
                    ? Container(
                        key: const ValueKey<String>('locating'),
                        decoration: BoxDecoration(
                          color: AppColors.softLilac,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border, width: 1.2),
                        ),
                        child: LCornerFinder(
                          progress: _cornerController.value,
                        ),
                      )
                    : (widget.imagePath != null && widget.imagePath!.isNotEmpty
                        ? DisintegrateView(
                            key: const ValueKey<String>('disintegrating'),
                            imagePath: widget.imagePath!,
                            duration: widget.disintegratingDuration,
                          )
                        : Container(
                            key: const ValueKey<String>('disintegrating-empty'),
                            decoration: BoxDecoration(
                              color: AppColors.softLilac,
                              borderRadius: BorderRadius.circular(24),
                              border:
                                  Border.all(color: AppColors.border, width: 1.2),
                            ),
                            child: const Center(
                              child: Text('🍱',
                                  style: TextStyle(fontSize: 56)),
                            ),
                          )),
              ),
            ),
            const SizedBox(height: 22),
            // 阶段文案（带切换动效）
            SizedBox(
              height: 22,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                child: Row(
                  key: ValueKey<ProcessingStage>(_stage),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _stageLabel(_stage),
                      style: const TextStyle(
                        color: AppColors.inkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _ThreeDotIndicator(color: AppColors.inkText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 三个点循环跳动，表示“进行中”。
class _ThreeDotIndicator extends StatefulWidget {
  const _ThreeDotIndicator({required this.color});

  final Color color;

  @override
  State<_ThreeDotIndicator> createState() => _ThreeDotIndicatorState();
}

class _ThreeDotIndicatorState extends State<_ThreeDotIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (int i) {
            // 每个点错开 1/3 周期
            final double phase = (_controller.value - i / 3.0);
            final double t = phase < 0 ? phase + 1.0 : phase;
            // 0..1..0 的正弦曲线
            final double alpha = (t < 0.5 ? t * 2.0 : 2.0 - t * 2.0).clamp(0.0, 1.0);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: i == 1 ? 1.0 : 0.5),
              child: Opacity(
                opacity: 0.35 + alpha * 0.65,
                child: Text(
                  '.',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
