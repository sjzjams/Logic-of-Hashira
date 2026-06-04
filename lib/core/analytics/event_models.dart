/// Coach 消息分类枚举，保持与埋点口径一致。
enum CoachMessageCategory {
  workout,
  nutrition,
  recovery,
  mindset,
  unknown,
}

/// Coach 消息长度桶，用于区分搜索型输入和长文本倾诉型输入。
enum MessageLengthBucket {
  zeroToTwenty,
  twentyToHundred,
  hundredPlus,
}

/// Snapshot 输入来源枚举。
enum SnapshotInputType {
  camera,
  gallery,
  sample,
}

/// Snapshot 分析失败阶段枚举。
enum SnapshotAnalysisStage {
  capture,
  segmentation,
  nutrition,
  save,
}

/// 通用埋点参数接口，所有事件参数对象都应实现 `toMap()`。
abstract class AnalyticsEventParams {
  const AnalyticsEventParams();

  /// 将当前参数对象序列化为埋点系统可消费的键值对。
  Map<String, Object> toMap();
}

/// 进入 Snapshot 页面时使用的参数对象。
class SnapshotOpenEventParams extends AnalyticsEventParams {
  const SnapshotOpenEventParams({this.source});

  final String? source;

  @override
  /// 输出 `snapshot_open` 事件所需参数。
  Map<String, Object> toMap() {
    return _compact(<String, Object?>{
      'source': source,
    });
  }
}

/// 完成拍照、选图或样本选择后使用的参数对象。
class SnapshotCaptureEventParams extends AnalyticsEventParams {
  const SnapshotCaptureEventParams({
    required this.inputType,
    this.sampleName,
  });

  final SnapshotInputType inputType;
  final String? sampleName;

  @override
  /// 输出 `snapshot_capture` 事件所需参数。
  Map<String, Object> toMap() {
    return _compact(<String, Object?>{
      'input_type': inputType.parameterValue,
      'sample_name': sampleName,
    });
  }
}

/// Snapshot 分析成功后使用的参数对象。
class SnapshotAnalysisSuccessEventParams extends AnalyticsEventParams {
  const SnapshotAnalysisSuccessEventParams({
    required this.analysisDurationMs,
    this.foodName,
    this.confidence,
  });

  final int analysisDurationMs;
  final String? foodName;
  final double? confidence;

  @override
  /// 输出 `snapshot_analysis_success` 事件所需参数。
  Map<String, Object> toMap() {
    return _compact(<String, Object?>{
      'analysis_duration_ms': analysisDurationMs,
      'food_name': foodName,
      'confidence': confidence,
    });
  }
}

/// Snapshot 分析失败后使用的参数对象。
class SnapshotAnalysisFailEventParams extends AnalyticsEventParams {
  const SnapshotAnalysisFailEventParams({
    required this.errorCode,
    required this.analysisStage,
  });

  final String errorCode;
  final SnapshotAnalysisStage analysisStage;

  @override
  /// 输出 `snapshot_analysis_fail` 事件所需参数。
  Map<String, Object> toMap() {
    return <String, Object>{
      'error_code': errorCode,
      'analysis_stage': analysisStage.parameterValue,
    };
  }
}

/// Snapshot 保存成功后使用的参数对象。
class SnapshotSaveEventParams extends AnalyticsEventParams {
  const SnapshotSaveEventParams({
    this.mealType,
    this.calories,
    this.saveDurationMs,
  });

  final String? mealType;
  final double? calories;
  final int? saveDurationMs;

  @override
  /// 输出 `snapshot_save` 事件所需参数。
  Map<String, Object> toMap() {
    return _compact(<String, Object?>{
      'meal_type': mealType,
      'calories': calories,
      'save_duration_ms': saveDurationMs,
    });
  }
}

/// 打开 Coach 页面时使用的参数对象。
class CoachOpenEventParams extends AnalyticsEventParams {
  const CoachOpenEventParams({this.source});

  final String? source;

  @override
  /// 输出 `coach_open` 事件所需参数。
  Map<String, Object> toMap() {
    return _compact(<String, Object?>{
      'source': source,
    });
  }
}

/// 首条消息发送时使用的参数对象。
class CoachChatStartEventParams extends AnalyticsEventParams {
  const CoachChatStartEventParams({this.firstMessage = true});

  final bool firstMessage;

  @override
  /// 输出 `coach_chat_start` 事件所需参数。
  Map<String, Object> toMap() {
    return <String, Object>{
      'first_message': firstMessage,
    };
  }
}

/// 用户发送消息时使用的参数对象。
class CoachMessageSendEventParams extends AnalyticsEventParams {
  const CoachMessageSendEventParams({
    required this.messageLength,
    required this.category,
    MessageLengthBucket? lengthBucket,
  }) : lengthBucket =
           lengthBucket ?? (messageLength <= 20
               ? MessageLengthBucket.zeroToTwenty
               : messageLength <= 100
                   ? MessageLengthBucket.twentyToHundred
                   : MessageLengthBucket.hundredPlus);

  final int messageLength;
  final CoachMessageCategory category;
  final MessageLengthBucket lengthBucket;

  @override
  /// 输出 `coach_message_send` 事件所需参数。
  Map<String, Object> toMap() {
    return <String, Object>{
      'message_length': messageLength,
      'length_bucket': lengthBucket.parameterValue,
      'category': category.parameterValue,
    };
  }
}

/// 点击 Coach 建议卡时使用的参数对象。
class CoachSuggestionClickEventParams extends AnalyticsEventParams {
  const CoachSuggestionClickEventParams({required this.suggestion});

  final String suggestion;

  @override
  /// 输出 `coach_suggestion_click` 事件所需参数。
  Map<String, Object> toMap() {
    return <String, Object>{
      'suggestion': suggestion,
    };
  }
}

/// 点击 Coach 快捷标签时使用的参数对象。
class CoachTagClickEventParams extends AnalyticsEventParams {
  const CoachTagClickEventParams({required this.tag});

  final CoachMessageCategory tag;

  @override
  /// 输出 `coach_tag_click` 事件所需参数。
  Map<String, Object> toMap() {
    return <String, Object>{
      'tag': tag.parameterValue,
    };
  }
}

/// 结束 Coach 会话时使用的参数对象。
class CoachSessionEndEventParams extends AnalyticsEventParams {
  const CoachSessionEndEventParams({
    required this.durationSeconds,
    this.messageCount,
  });

  final int durationSeconds;
  final int? messageCount;

  @override
  /// 输出 `coach_session_end` 事件所需参数。
  Map<String, Object> toMap() {
    return _compact(<String, Object?>{
      'duration': durationSeconds,
      'message_count': messageCount,
    });
  }
}

extension CoachMessageCategoryValue on CoachMessageCategory {
  /// 将分类枚举转换为埋点使用的稳定字符串值。
  String get parameterValue {
    switch (this) {
      case CoachMessageCategory.workout:
        return 'workout';
      case CoachMessageCategory.nutrition:
        return 'nutrition';
      case CoachMessageCategory.recovery:
        return 'recovery';
      case CoachMessageCategory.mindset:
        return 'mindset';
      case CoachMessageCategory.unknown:
        return 'unknown';
    }
  }
}

extension MessageLengthBucketValue on MessageLengthBucket {
  /// 将长度桶枚举转换为埋点使用的稳定字符串值。
  String get parameterValue {
    switch (this) {
      case MessageLengthBucket.zeroToTwenty:
        return '0_20';
      case MessageLengthBucket.twentyToHundred:
        return '20_100';
      case MessageLengthBucket.hundredPlus:
        return '100_plus';
    }
  }
}

extension SnapshotInputTypeValue on SnapshotInputType {
  /// 将输入来源枚举转换为埋点使用的稳定字符串值。
  String get parameterValue {
    switch (this) {
      case SnapshotInputType.camera:
        return 'camera';
      case SnapshotInputType.gallery:
        return 'gallery';
      case SnapshotInputType.sample:
        return 'sample';
    }
  }
}

extension SnapshotAnalysisStageValue on SnapshotAnalysisStage {
  /// 将失败阶段枚举转换为埋点使用的稳定字符串值。
  String get parameterValue {
    switch (this) {
      case SnapshotAnalysisStage.capture:
        return 'capture';
      case SnapshotAnalysisStage.segmentation:
        return 'segmentation';
      case SnapshotAnalysisStage.nutrition:
        return 'nutrition';
      case SnapshotAnalysisStage.save:
        return 'save';
    }
  }
}

/// 根据消息长度计算推荐的长度桶。
MessageLengthBucket bucketForMessageLength(int messageLength) {
  if (messageLength <= 20) {
    return MessageLengthBucket.zeroToTwenty;
  }
  if (messageLength <= 100) {
    return MessageLengthBucket.twentyToHundred;
  }
  return MessageLengthBucket.hundredPlus;
}

/// 移除空值字段，避免在埋点系统中写入无意义参数。
Map<String, Object> _compact(Map<String, Object?> values) {
  final Map<String, Object> result = <String, Object>{};
  values.forEach((String key, Object? value) {
    if (value != null) {
      result[key] = value;
    }
  });
  return result;
}
