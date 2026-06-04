import '../../core/analytics/event_models.dart';

/// 根据用户输入的文本粗略推断 Coach 消息分类。
///
/// Sprint 4 范围内使用**关键词匹配**而非真实 LLM 意图识别，原因：
/// - 真正调用 Firebase AI Logic 需要网络 + 已配置 Firebase；
/// - 单元测试应能在不依赖网络的前提下验证分类行为；
/// - 这是 V1 阶段埋点打点用的“合理默认值”，后续可替换为 LLM 分类。
///
/// 规则（不区分大小写）：
/// - 命中 `workout|训练|练|bench|squat|form|rep` -> workout
/// - 命中 `nutrition|food|meal|eat|protein|calorie|diet` -> nutrition
/// - 命中 `sleep|recovery|rest|recover|tired` -> recovery
/// - 命中 `motivation|focus|mindset|stress|anxiety` -> mindset
/// - 其它一律 unknown
class CoachMessageClassifier {
  const CoachMessageClassifier();

  /// 公开方法：返回最匹配的分类，兜底 unknown。
  CoachMessageCategory classify(String text) {
    final String lower = text.toLowerCase();
    // 顺序就是优先级：先看最具体的话题（workout / nutrition），
    // 避免 "I need protein after workout" 同时命中 workout 与 nutrition 时被 workout 抢先。
    if (_matchesAny(lower, _workoutKeywords)) {
      return CoachMessageCategory.workout;
    }
    if (_matchesAny(lower, _nutritionKeywords)) {
      return CoachMessageCategory.nutrition;
    }
    if (_matchesAny(lower, _recoveryKeywords)) {
      return CoachMessageCategory.recovery;
    }
    if (_matchesAny(lower, _mindsetKeywords)) {
      return CoachMessageCategory.mindset;
    }
    return CoachMessageCategory.unknown;
  }

  /// 内部：判断 [text] 中是否包含 [keywords] 任意一个。
  static bool _matchesAny(String text, List<String> keywords) {
    for (final String kw in keywords) {
      if (text.contains(kw)) {
        return true;
      }
    }
    return false;
  }

  // 注意：只保留具体动作/动作技术词，避免 `workout`/`training` 这类通用词
  // 抢占其它类目（如 "I need protein after a workout" 应归 nutrition）。
  static const List<String> _workoutKeywords = <String>[
    'bench', 'squat', 'deadlift', 'rep', 'set', 'form',
    '练', '训练', '动作', '组数',
  ];

  static const List<String> _nutritionKeywords = <String>[
    'protein', 'calorie', 'carb', 'fiber', 'meal prep',
    '吃', '蛋白', '碳水', '脂肪', '饮食', '卡路里',
  ];

  static const List<String> _recoveryKeywords = <String>[
    'sleep', 'recovery', 'rest', 'tired', 'fatigue', 'sore', 'nap',
    '休息', '睡眠', '恢复', '酸痛', '累',
  ];

  static const List<String> _mindsetKeywords = <String>[
    'motivation', 'focus', 'mindset', 'stress', 'anxiety', 'habit',
    'discipline', 'goal', '坚持', '动力', '焦虑', '压力', '目标', '习惯',
  ];
}
