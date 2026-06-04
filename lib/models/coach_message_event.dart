/// Coach 单条用户消息事件，对应 PRD 中 `CoachMessageEvent`。
///
/// 字段集与 `coach_message_send` 埋点参数保持一致，方便后续在仓储层
/// 直接把 [toAnalyticsParams] 序列化为埋点 `Map`。
class CoachMessageEvent {
  const CoachMessageEvent({
    required this.messageLength,
    required this.messageLengthBucket,
    required this.category,
    required this.suggestion,
    required this.tag,
    required this.createdAt,
  });

  /// 原文长度（Unicode 码位）。
  final int messageLength;

  /// 长度桶：`0_20` / `20_100` / `100_plus`。
  final String messageLengthBucket;

  /// 主题分类：`workout` / `nutrition` / `recovery` / `mindset` / `unknown`。
  final String category;

  /// Suggestion 触发的消息对应的 suggestion id（可空）。
  final String? suggestion;

  /// Quick Tag 触发的消息对应的 tag 名（可空）。
  final String? tag;

  /// 事件时间。
  final DateTime createdAt;
}
