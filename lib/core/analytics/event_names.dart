/// 统一维护 Calorie Snap V1.0 的埋点事件名。
class AnalyticsEventNames {
  const AnalyticsEventNames._();

  static const String snapshotOpen = 'snapshot_open';
  static const String snapshotCapture = 'snapshot_capture';
  static const String snapshotAnalysisSuccess = 'snapshot_analysis_success';
  static const String snapshotAnalysisFail = 'snapshot_analysis_fail';
  static const String snapshotSave = 'snapshot_save';
  static const String snapshotEdit = 'snapshot_edit';
  static const String snapshotDelete = 'snapshot_delete';
  static const String snapshotSegmentStart = 'snapshot_segment_start';
  static const String snapshotSegmentSuccess = 'snapshot_segment_success';
  static const String snapshotSegmentFail = 'snapshot_segment_fail';
  // V1 升级 - 真实相机集成：进入 / 拍照两个事件。
  static const String cameraLiveOpen = 'camera_live_open';
  static const String cameraLiveCapture = 'camera_live_capture';
  static const String nutritionDashboardOpen = 'nutrition_dashboard_open';

  static const String coachOpen = 'coach_open';
  static const String coachShown = 'coach_shown';
  static const String coachTapped = 'coach_tapped';
  static const String coachChatStart = 'coach_chat_start';
  static const String coachMessageSend = 'coach_message_send';
  static const String coachSuggestionClick = 'coach_suggestion_click';
  static const String coachTagClick = 'coach_tag_click';
  static const String coachSessionStart = 'coach_session_start';
  static const String coachSessionEnd = 'coach_session_end';

  static const List<String> snapshotEvents = <String>[
    snapshotOpen,
    snapshotCapture,
    snapshotSegmentStart,
    snapshotSegmentSuccess,
    snapshotSegmentFail,
    snapshotAnalysisSuccess,
    snapshotAnalysisFail,
    snapshotSave,
    snapshotEdit,
    snapshotDelete,
    nutritionDashboardOpen,
    cameraLiveOpen,
    cameraLiveCapture,
  ];

  static const List<String> coachEvents = <String>[
    coachOpen,
    coachShown,
    coachTapped,
    coachChatStart,
    coachMessageSend,
    coachSuggestionClick,
    coachTagClick,
    coachSessionStart,
    coachSessionEnd,
  ];

  static const List<String> allEvents = <String>[
    ...snapshotEvents,
    ...coachEvents,
  ];
}
