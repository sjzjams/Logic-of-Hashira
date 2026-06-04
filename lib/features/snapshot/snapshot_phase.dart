/// Snapshot 状态机的阶段枚举。
///
/// V1.0 阶段全部本地驱动；未来接入相机与原生前景提取时，
/// 只需把 `MockSnapshotRecognizer` / `MockForegroundSegmentationService`
/// 替换为真实实现，状态机本身保持稳定。
enum SnapshotPhase {
  /// 等待用户拍摄 / 选择样本
  idle,

  /// 拍摄完成，等待处理
  capturing,

  /// 正在执行前景区分割（与 [analyzing] 区分，便于埋点统计）
  segmenting,

  /// 正在提取与分析（Locating / Disintegrating 在动效层表现，业务层只用此状态）
  analyzing,

  /// 分析成功，等待用户保存
  result,

  /// 分析失败，保留重试路径
  failed,
}
