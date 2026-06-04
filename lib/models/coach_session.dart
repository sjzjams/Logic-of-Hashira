/// Coach 会话级元信息，对应 PRD 中 `CoachSession` 数据模型。
///
/// 一次进入 `AiCoachScreen` 视为一个 session；离开或长时间无活动时结束。
/// V1 阶段字段都设为基本类型，避免引入 `Duration` 等复合结构带来的解析负担。
class CoachSession {
  const CoachSession({
    required this.sessionId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.source,
    required this.messageCount,
    required this.firstCategory,
  });

  /// 会话 ID，与埋点参数 `session_id` 对齐。
  final String sessionId;

  /// 进入 Coach 的时间。
  final DateTime startedAt;

  /// 离开 / 失活的时间，可为空表示进行中。
  final DateTime? endedAt;

  /// 已持续时长（秒），用于埋点 `coach_session_end.duration`。
  final int durationSeconds;

  /// 入口来源，例如 `tab` / `push`。
  final String source;

  /// 本次会话产生的有效消息数。
  final int messageCount;

  /// 用户首条消息命中分类，可为空（首条由 Suggestion 触发时无 category）。
  final String? firstCategory;
}
