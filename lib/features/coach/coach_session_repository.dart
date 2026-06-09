import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/analytics/event_models.dart';
import '../../models/coach_message_event.dart';
import '../../models/coach_session.dart';

/// Coach 会话仓库（SharedPreferences 持久化版）。
///
/// 行为约定：
/// - `ChangeNotifier` API 与 Sprint 4 内存版完全一致，UI 层无需修改；
/// - 构造时**不**强依赖 SharedPreferences，单元测试可直接 `CoachSessionRepository()` 使用；
/// - 生产环境应在 `main()` 启动时调用 [init] 加载上次未完成的活跃会话；
/// - 每次 `startSession` / `recordMessage` / `endSession` 都把状态序列化到
///   `SharedPreferences`，进程崩溃后再次启动可恢复上下文；
/// - 持久化键统一加 `coach.` 前缀，避免与其它模块冲突。
class CoachSessionRepository extends ChangeNotifier {
  CoachSessionRepository();

  /// 全局默认单例。
  static final CoachSessionRepository instance = CoachSessionRepository();

  // ---- 活跃会话状态 ----

  String? _activeSessionId;
  DateTime? _startedAt;
  int _messageCount = 0;
  CoachMessageCategory? _firstCategory;
  final List<CoachMessageEvent> _messageLog = <CoachMessageEvent>[];

  // ---- 持久化句柄 ----

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// 异步初始化：从 [SharedPreferences] 恢复上次的活跃会话。
  ///
  /// 调用方：`main()` 启动时；幂等可重复调用。
  Future<void> init(SharedPreferences prefs) async {
    if (_initialized && identical(_prefs, prefs)) {
      return;
    }
    _prefs = prefs;
    _activeSessionId = prefs.getString(_kActiveSessionId);
    final int? startedAtMs = prefs.getInt(_kStartedAtMs);
    _startedAt = startedAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(startedAtMs);
    _messageCount = prefs.getInt(_kMessageCount) ?? 0;
    final String? firstCat = prefs.getString(_kFirstCategory);
    _firstCategory = _decodeCategory(firstCat);
    final String? logJson = prefs.getString(_kMessageLog);
    _messageLog
      ..clear()
      ..addAll(_decodeLog(logJson));
    _initialized = true;
    notifyListeners();
  }

  /// 当前是否有活跃会话。
  bool get hasActiveSession => _activeSessionId != null;

  /// 当前会话已累计消息数。
  int get currentMessageCount => _messageCount;

  /// 当前会话首条消息分类（若有）。
  CoachMessageCategory? get firstCategory => _firstCategory;

  /// 启动一个会话。
  ///
  /// [source] 建议传 `tab` / `push` / `deep_link`。
  /// 若已有活跃会话，调用本方法会被忽略（避免重复打 session_start 埋点）。
  void startSession({required String source}) {
    if (_activeSessionId != null) {
      return;
    }
    _activeSessionId = 'coach_${DateTime.now().microsecondsSinceEpoch}';
    _startedAt = DateTime.now();
    _messageCount = 0;
    _firstCategory = null;
    _messageLog.clear();
    notifyListeners();
    _persist();
  }

  /// 结束当前会话，返回 [CoachSession] 摘要供埋点消费。
  ///
  /// 若无活跃会话，返回 null。
  CoachSession? endSession() {
    final String? id = _activeSessionId;
    final DateTime? startedAt = _startedAt;
    if (id == null || startedAt == null) {
      return null;
    }
    final DateTime endedAt = DateTime.now();
    final int durationSeconds = endedAt.difference(startedAt).inSeconds;
    final CoachSession session = CoachSession(
      sessionId: id,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      source: 'tab',
      messageCount: _messageCount,
      firstCategory: _firstCategory?.parameterValue,
    );
    _activeSessionId = null;
    _startedAt = null;
    _messageCount = 0;
    _firstCategory = null;
    _messageLog.clear();
    notifyListeners();
    _persist();
    return session;
  }

  /// 累计一条用户消息，并落盘到 [_messageLog]。
  ///
  /// [category] 允许为 null（首条由 Suggestion 触发时尚未分类时）；
  /// [suggestion] / [tag] 二者择一即可，都为空表示用户自由输入。
  void recordMessage({
    required String text,
    CoachMessageCategory? category,
    String? suggestion,
    String? tag,
  }) {
    if (_activeSessionId == null) {
      // 防御性兜底：调用方忘了 startSession 时，自动按 tab 开启一次。
      startSession(source: 'tab');
    }
    final int length = text.length;
    final MessageLengthBucket bucket = bucketForMessageLength(length);
    _messageCount += 1;
    if (_firstCategory == null && category != null) {
      _firstCategory = category;
    }
    _messageLog.add(
      CoachMessageEvent(
        messageLength: length,
        messageLengthBucket: bucket.parameterValue,
        category: category?.parameterValue ?? 'unknown',
        suggestion: suggestion,
        tag: tag,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    _persist();
  }

  /// 当前会话完整消息日志（倒序，最新在前），供未来 Debug 用。
  List<CoachMessageEvent> get currentMessageLog =>
      List<CoachMessageEvent>.unmodifiable(_messageLog.reversed);

  // ---- 持久化内部方法 ----

  /// 把当前活跃会话状态写入 SharedPreferences。失败仅 `debugPrint`。
  Future<void> _persist() async {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      return;
    }
    try {
      if (_activeSessionId == null) {
        await prefs.remove(_kActiveSessionId);
        await prefs.remove(_kStartedAtMs);
        await prefs.remove(_kMessageCount);
        await prefs.remove(_kFirstCategory);
        await prefs.remove(_kMessageLog);
        return;
      }
      await prefs.setString(_kActiveSessionId, _activeSessionId!);
      await prefs.setInt(
        _kStartedAtMs,
        _startedAt?.millisecondsSinceEpoch ?? 0,
      );
      await prefs.setInt(_kMessageCount, _messageCount);
      await prefs.setString(
        _kFirstCategory,
        _firstCategory?.parameterValue ?? '',
      );
      await prefs.setString(_kMessageLog, _encodeLog(_messageLog));
    } catch (error) {
      debugPrint('CoachSessionRepository: persist failed: $error');
    }
  }

  // ---- 序列化工具 ----

  /// 把 [CoachMessageEvent] 列表编码成 JSON 字符串。
  /// 字段命名沿用 `CoachMessageEvent` 的属性名，方便未来 grep 调试。
  static String _encodeLog(List<CoachMessageEvent> log) {
    final List<Map<String, Object?>> rows = log
        .map(
          (CoachMessageEvent e) => <String, Object?>{
            'messageLength': e.messageLength,
            'messageLengthBucket': e.messageLengthBucket,
            'category': e.category,
            'suggestion': e.suggestion,
            'tag': e.tag,
            'createdAt': e.createdAt.millisecondsSinceEpoch,
          },
        )
        .toList(growable: false);
    return jsonEncode(rows);
  }

  /// 把 JSON 字符串解码回 [CoachMessageEvent] 列表。
  /// 解码失败返回空列表（不让坏数据阻塞 UI）。
  static List<CoachMessageEvent> _decodeLog(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <CoachMessageEvent>[];
    }
    try {
      final List<Object?> decoded = jsonDecode(raw) as List<Object?>;
      return decoded
          .map((Object? row) {
            final Map<String, Object?> map = (row as Map<Object?, Object?>).map(
              (Object? k, Object? v) =>
                  MapEntry<String, Object?>(k?.toString() ?? '', v),
            );
            return CoachMessageEvent(
              messageLength: (map['messageLength'] as num?)?.toInt() ?? 0,
              messageLengthBucket:
                  (map['messageLengthBucket'] as String?) ?? '0_20',
              category: (map['category'] as String?) ?? 'unknown',
              suggestion: map['suggestion'] as String?,
              tag: map['tag'] as String?,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                (map['createdAt'] as num?)?.toInt() ?? 0,
              ),
            );
          })
          .toList(growable: false);
    } catch (error) {
      debugPrint('CoachSessionRepository: decode log failed: $error');
      return <CoachMessageEvent>[];
    }
  }

  /// 把持久化字符串解码为 [CoachMessageCategory]；未知值退化为 `null`。
  static CoachMessageCategory? _decodeCategory(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final CoachMessageCategory c in CoachMessageCategory.values) {
      if (c.parameterValue == value) {
        return c;
      }
    }
    return null;
  }

  // ---- 持久化键（私有常量） ----

  static const String _kActiveSessionId = 'coach.active_session_id';
  static const String _kStartedAtMs = 'coach.session_started_at_ms';
  static const String _kMessageCount = 'coach.message_count';
  static const String _kFirstCategory = 'coach.first_category';
  static const String _kMessageLog = 'coach.message_log';
}
