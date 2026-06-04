/// 埋点服务抽象层。
///
/// V1 阶段只输出日志，**不**直接调用 Firebase / Mixpanel / PostHog / Amplitude，
/// 以保持：
///   1. 业务代码与具体 SDK 解耦；
///   2. widget test 不依赖外部网络；
///   3. 后续可在不改业务代码的前提下替换实现。
///
/// 上层应通过 `AnalyticsService.instance.track(...)` 调用本服务。
library;

import 'package:flutter/foundation.dart';

abstract class AnalyticsService {
  /// 全局可用的单例；测试可通过 [AnalyticsService.debugOverride] 替换。
  static AnalyticsService instance = DebugPrintAnalyticsService();

  /// 记录一次事件。
  ///
  /// [event] 必须来自 `event_names.dart`，禁止业务代码使用裸字符串。
  /// [params] 允许空 Map；key 仅允许基础类型，调用方负责裁剪 null / 复杂对象。
  void track(String event, [Map<String, Object?> params = const {}]);

  /// 仅供测试 / 调试使用：在测试用例中注入一个不刷日志的实现。
  static void debugOverride(AnalyticsService service) {
    instance = service;
  }
}

/// 默认实现：把事件以 `debugPrint` 形式输出，方便本地与 CI 排查。
class DebugPrintAnalyticsService implements AnalyticsService {
  @override
  void track(String event, [Map<String, Object?> params = const {}]) {
    if (params.isEmpty) {
      debugPrint('[Analytics] $event');
      return;
    }
    debugPrint('[Analytics] $event $params');
  }
}
