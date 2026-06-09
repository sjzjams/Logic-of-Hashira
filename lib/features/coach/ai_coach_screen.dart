import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '../../core/analytics/analytics.dart';
import '../../core/theme.dart';
import '../../core/widgets/hand_drawn_button.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/prototype_page.dart';
import '../../firebase_options.dart';
import '../../models/coach_session.dart';
import 'ai_coach_chat_style.dart';
import 'ai_coach_provider.dart';
import 'coach_session_repository.dart';

/// Sprint 4: Coach V1 闭环 UI。
///
/// 职责：
/// - 进入页面：触发 `coach_open` + `coach_session_start` 埋点；
/// - 离开页面：触发 `coach_session_end` 埋点（含 duration / message_count）；
/// - 顶部 Quick Tags：点击即打 `coach_tag_click` 埋点，并填入输入框（占位）；
/// - 主区 `LlmChatView` 复用既有 Flutter AI Toolkit 样式。
///
/// Quick Tag 文案直接对应 [CoachMessageCategory] 枚举值（workout / nutrition /
/// recovery / mindset），避免再维护第二份字面量。
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key, this.sessionRepository});

  /// 注入的会话仓库；不传则走 [CoachSessionRepository.instance] 兜底。
  final CoachSessionRepository? sessionRepository;

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  LlmProvider? _provider;
  bool _isInitializing = true;
  String? _initError; // FE-10: 兜住 Firebase / LLM 初始化失败。
  late final CoachSessionRepository _sessionRepo;

  @override
  void initState() {
    super.initState();
    _sessionRepo = widget.sessionRepository ?? CoachSessionRepository.instance;
    _sessionRepo.startSession(source: 'tab');
    AnalyticsService.instance.track(
      AnalyticsEventNames.coachSessionStart,
      <String, Object?>{'source': 'tab'},
    );
    _initialize();
  }

  @override
  void dispose() {
    final CoachSession? ended = _sessionRepo.endSession();
    if (ended != null) {
      AnalyticsService.instance.track(
        AnalyticsEventNames.coachSessionEnd,
        CoachSessionEndEventParams(
          durationSeconds: ended.durationSeconds,
          messageCount: ended.messageCount,
        ).toMap(),
      );
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      // FE-10:即使是 Unknown Error 也不再静默吞掉,而是把 message 存到 _initError,
      // 让 UI 层可以给用户一个"重新连接"的入口。
      if (error is UnsupportedError) {
        debugPrint('Firebase init skipped: ${error.message}');
      } else {
        debugPrint('Firebase init failed: $error');
        setState(() {
          _initError = error.toString();
        });
        return;
      }
    }

    if (!mounted) {
      return;
    }
    try {
      final LlmProvider created = createAiCoachProvider();
      setState(() {
        _provider = created;
        _isInitializing = false;
      });
    } catch (error) {
      setState(() {
        _initError = error.toString();
        _isInitializing = false;
      });
    }
  }

  /// Quick Tag 点击：写入 Session 仓库 + 触发埋点。
  ///
  /// V1 阶段不直接发送，仅记录用户对哪类话题感兴趣（用于未来 "tag-based
  /// suggestion" 与埋点口径校验）。
  void _onTagClick(CoachMessageCategory tag) {
    _sessionRepo.recordMessage(
      text: '[tag] ${tag.parameterValue}',
      category: tag,
      tag: tag.parameterValue,
    );
    AnalyticsService.instance.track(
      AnalyticsEventNames.coachTagClick,
      CoachTagClickEventParams(tag: tag).toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LlmProvider? provider = _provider;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
          child: Row(
            children: [
              Expanded(
                child: PrototypeHeader(
                  title: 'AI Coach',
                  kicker: _isInitializing ? 'Connecting...' : 'Build the chain',
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1.2),
                  color: AppColors.softLilac,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.inkText.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const PrototypeIllustration(
                  assetId: 'coach_robot',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1.2, color: AppColors.border),
        _QuickTagsRow(onTagClick: _onTagClick),
        Expanded(
          child: _initError != null
              ? _CoachErrorView(
                  message: _initError!,
                  onRetry: () {
                    setState(() {
                      _initError = null;
                      _isInitializing = true;
                    });
                    _initialize();
                  },
                )
              : provider == null
              ? Container(
                  color: AppColors.canvas,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                )
              : Container(
                  color: AppColors.canvas,
                  child: LlmChatView(
                    provider: provider,
                    style: aiCoachChatViewStyle(),
                    welcomeMessage: aiCoachWelcomeMessage,
                    suggestions: aiCoachSuggestions,
                    enableAttachments: false,
                    enableVoiceNotes: false,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Quick Tags 横向条，承载 FE-08 中"分类快捷入口"的最小可视化。
class _QuickTagsRow extends StatelessWidget {
  const _QuickTagsRow({required this.onTagClick});

  final ValueChanged<CoachMessageCategory> onTagClick;

  static const List<CoachMessageCategory> _tags = <CoachMessageCategory>[
    CoachMessageCategory.workout,
    CoachMessageCategory.nutrition,
    CoachMessageCategory.recovery,
    CoachMessageCategory.mindset,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _tags.length,
          separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 8),
          itemBuilder: (BuildContext context, int index) {
            final CoachMessageCategory tag = _tags[index];
            return GestureDetector(
              onTap: () => onTagClick(tag),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softLilac,
                  border: Border.all(
                    color: AppColors.inkBlue.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '#${tag.parameterValue}',
                  style: AppTypography.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBlue,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// FE-10 验收项：Coach 初始化/连接失败时给用户一个"Retry / 切回 Mock"的恢复路径。
class _CoachErrorView extends StatelessWidget {
  const _CoachErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvas,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.inkText,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                'Coach is offline. Try again or use a sample message.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  fontSize: 11,
                  color: AppColors.grayText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              HandDrawnButton(text: 'Retry', onTap: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
