/// Calorie Snap 完整埋点事件字典（V2 架构对齐）。
///
/// 覆盖 8 幕完整用户旅程：
///   Home → Camera → Capture → AI Analysis → Result → Detail → Save → History
///
/// 使用方式：
/// ```dart
/// AnalyticsService.instance.track(SnapshotEvents.snapButtonTapped);
/// ```
class SnapshotEvents {
  const SnapshotEvents._();

  // ===== 第一幕：Home =====

  /// SNAP 按钮曝光
  static const String snapButtonShown = 'snap_button_shown';

  /// SNAP 按钮点击
  static const String snapButtonTapped = 'snap_button_tapped';

  /// 首页 Recent Meal 卡片点击
  static const String homeRecentMealTapped = 'home_recent_meal_tapped';

  // ===== 第二幕：Camera =====

  /// 相机页面打开
  static const String cameraOpen = 'camera_open';

  /// CameraX / camera plugin 初始化完成
  static const String cameraReady = 'camera_ready';

  /// 相机权限被拒绝
  static const String cameraPermissionDenied = 'camera_permission_denied';

  /// 设备 Benchmark 完成（附带 tier 属性）
  static const String deviceBenchmarkComplete = 'device_benchmark_complete';

  /// 设备档位上报（flagship / midrange / budget）
  static const String deviceTier = 'device_tier';

  // ===== 第三幕：Capture =====

  /// 食物被锁定（AI 连续 N 帧确认同一食物）
  static const String foodLocked = 'food_locked';

  /// 食物锁定解除（目标丢失/镜头移动）
  static const String foodUnlocked = 'food_unlocked';

  /// 快门按钮点击
  static const String captureClicked = 'capture_clicked';

  /// 拍照成功（拿到文件路径）
  static const String captureSuccess = 'capture_success';

  /// 拍照失败
  static const String captureFailed = 'capture_failed';

  // ===== 第四幕：AI Analysis =====

  /// 开始分析（进入 segmenting / analyzing 状态）
  static const String analysisStart = 'analysis_start';

  /// 分析完成
  static const String analysisComplete = 'analysis_complete';

  /// 分析耗时（ms，数值属性）
  static const String analysisDurationMs = 'analysis_duration_ms';

  /// YOLO 原始分类输出（TemporalVoter 前）
  static const String yoloClassRaw = 'yolo_class_raw';

  /// TemporalVoter 投票后的稳定结果
  static const String yoloClassVoted = 'yolo_class_voted';

  // ===== 第五幕：Result Reveal =====

  /// 结果页曝光
  static const String resultShown = 'result_shown';

  /// 卡路里数字展示
  static const String calorieDisplayed = 'calorie_displayed';

  /// 卡路里置信度等级（High / Medium / Low）
  static const String calorieConfidenceLevel = 'calorie_confidence_level';

  // ===== 第六幕：数字动画 =====
  // （无需单独埋点，包含在 calorie_displayed 中）

  // ===== 第七幕：Food Detail =====

  /// 详情页打开（Hero 过渡后）
  static const String detailOpened = 'detail_opened';

  /// AI Coach 卡片曝光
  static const String coachShown = 'coach_shown';

  /// Coach "Ask follow-up" 点击
  static const String coachTapped = 'coach_tapped';

  // ===== 第八幕：Save + History =====

  /// Save 按钮点击
  static const String saveClicked = 'save_clicked';

  /// 保存成功（写库完成）
  static const String saveComplete = 'save_complete';

  /// Food Collapse 动画结束
  static const String saveCollapseAnimEnd = 'save_collapse_anim_end';

  /// Timeline 卡片弹出曝光
  static const String timelineCardShown = 'timeline_card_shown';

  /// History 页面打开
  static const String historyOpened = 'history_opened';

  /// History 条目点击
  static const String historyItemTapped = 'history_item_tapped';

  // ===== 通用 =====

  /// 错误事件
  static const String snapshotError = 'snapshot_error';

  /// 各阶段耗时（ms，数值属性；通过 `phase_name` 属性区分阶段）
  static const String phaseDurationMs = 'phase_duration_ms';

  // ===== V1 兼容别名（指向现有事件名）=====

  /// @deprecated 使用 [cameraOpen] 替代
  @Deprecated('Use cameraOpen instead')
  static const String cameraLiveOpen = 'camera_live_open';

  /// @deprecated 使用 [captureSuccess] 替代
  @Deprecated('Use captureSuccess instead')
  static const String cameraLiveCapture = 'camera_live_capture';

  /// @deprecated 使用 [detailOpened] 或 [resultShown] 替代
  @Deprecated('Use resultShown / detailOpened instead')
  static const String snapshotOpen = 'snapshot_open';

  /// @deprecated 使用 [captureClicked] 替代
  @Deprecated('Use captureClicked instead')
  static const String snapshotCapture = 'snapshot_capture';

  /// @deprecated 使用 [analysisComplete] 替代
  @Deprecated('Use analysisComplete instead')
  static const String snapshotAnalysisSuccess = 'snapshot_analysis_success';

  /// @deprecated 使用 [snapshotError] 替代
  @Deprecated('Use snapshotError instead')
  static const String snapshotAnalysisFail = 'snapshot_analysis_fail';

  /// @deprecated 使用 [saveComplete] 替代
  @Deprecated('Use saveComplete instead')
  static const String snapshotSave = 'snapshot_save';

  /// @deprecated 使用 [analysisStart] 替代
  @Deprecated('Use analysisStart instead')
  static const String snapshotSegmentStart = 'snapshot_segment_start';

  /// 前景区分割成功（保留，无直接替代项）
  static const String snapshotSegmentSuccess = 'snapshot_segment_success';

  /// @deprecated 使用 [snapshotError] 替代
  @Deprecated('Use snapshotError instead')
  static const String snapshotSegmentFail = 'snapshot_segment_fail';

  // ===== 全量事件列表（供 registry / debug 校验用）=====

  static const List<String> allEvents = <String>[
    snapButtonShown,
    snapButtonTapped,
    homeRecentMealTapped,
    cameraOpen,
    cameraReady,
    cameraPermissionDenied,
    deviceBenchmarkComplete,
    deviceTier,
    foodLocked,
    foodUnlocked,
    captureClicked,
    captureSuccess,
    captureFailed,
    analysisStart,
    analysisComplete,
    analysisDurationMs,
    yoloClassRaw,
    yoloClassVoted,
    resultShown,
    calorieDisplayed,
    calorieConfidenceLevel,
    detailOpened,
    coachShown,
    coachTapped,
    saveClicked,
    saveComplete,
    saveCollapseAnimEnd,
    timelineCardShown,
    historyOpened,
    historyItemTapped,
    snapshotError,
    phaseDurationMs,
    snapshotSegmentSuccess,
  ];
}
