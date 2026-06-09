import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设备性能分级。
///
/// 首次启动通过 NCNN Benchmark 自动判定，结果缓存到 SharedPreferences；
/// 后续启动直接读取，不再耗时可推理。
enum DeviceTier {
  /// 旗舰：SD 8Gen1+ / Dimensity 9000+ / Exynos 2200+
  /// 全部特效开启：实时 Highlight + RefineNet + 全 Shader + 粒子 36
  flagship,

  /// 中端：SD 778G / 7s Gen2 / Helio G99 / Kirin 810
  /// YOLO + RefineNet + 低频 Highlight(300ms) + 粒子 20
  midrange,

  /// 低端：SD 665 / 660 / Helio P60 / MT6739
  /// 关闭实时 Mask Highlight；代替主体区域亮度增强
  budget,

  /// Benchmark 未完成或失败时的默认档位（保守:等同于 midrange）。
  unknown,
}

/// 设备特性开关映射，统一管理各 Tier 下的行为差异。
///
/// 使用方式：
/// ```dart
/// final tier = await DeviceTierService.instance.tier;
/// if (DeviceFlags.showRealtimeHighlight(tier)) { ... }
/// ```
class DeviceFlags {
  DeviceFlags._();

  static bool showRealtimeHighlight(DeviceTier t) =>
      t == DeviceTier.flagship || t == DeviceTier.midrange;

  static int highlightIntervalMs(DeviceTier t) =>
      t == DeviceTier.flagship ? 100 : 300;

  static bool useRefineNet(DeviceTier t) =>
      t == DeviceTier.flagship || t == DeviceTier.midrange;

  static bool refineNetOnlyOnCapture(DeviceTier t) => t == DeviceTier.budget;

  static int particleCount(DeviceTier t) {
    switch (t) {
      case DeviceTier.flagship:
        return 36;
      case DeviceTier.midrange:
        return 20;
      case DeviceTier.budget:
      case DeviceTier.unknown:
        return 12;
    }
  }

  static bool showScanLine(DeviceTier t) =>
      t == DeviceTier.flagship || t == DeviceTier.midrange;

  static bool showReceiptSpring(DeviceTier t) =>
      t == DeviceTier.flagship || t == DeviceTier.midrange;

  static bool showReceiptDirect(DeviceTier t) => t == DeviceTier.budget;

  static bool showCollapseAnim(DeviceTier t) =>
      t == DeviceTier.flagship || t == DeviceTier.midrange;
}

/// 设备分级服务。
///
/// 首次启动通过 NCNN 推理 5 次 Benchmark 自动分档，
/// 结果缓存到 SharedPreferences（key: `device_tier`）。
class DeviceTierService {
  DeviceTierService._();
  static final DeviceTierService instance = DeviceTierService._();

  static const String _key = 'device_tier';

  DeviceTier? _cached;

  /// 当前档位（必须先调用 [init]）。
  DeviceTier get tier => _cached ?? DeviceTier.unknown;

  /// 异步初始化：读缓存 → 无缓存则 Benchmark → 写入缓存。
  ///
  /// 应在 [main] 中 `runApp` 之前调用。
  Future<void> init() async {
    if (_cached != null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw != null) {
      _cached = _tierFromString(raw);
      return;
    }

    // 无缓存 → 执行轻量 Benchmark。

    try {
      // ignore: avoid_print
      print('🔬 DeviceTier: running benchmark...');
      final Stopwatch sw = Stopwatch()..start();

      // Lightweight benchmark: measure CPU-bound compute (no NCNN dependency).
      final double avgMs = _runCpuBenchmark();

      sw.stop();
      // ignore: avoid_print
      print(
        '🔬 DeviceTier: benchmark completed in ${sw.elapsedMilliseconds}ms, '
        'avg=$avgMs ms',
      );

      _cached = _classify(avgMs);
    } catch (e) {
      // ignore: avoid_print
      print('⚠ DeviceTier: benchmark failed ($e), defaulting to midrange');
      _cached = DeviceTier.midrange;
    }

    await prefs.setString(_key, _cached!.name);
  }

  /// Debug 模式下可手动覆盖档位（用于开发测试）。
  /// 仅在 `kDebugMode` 为 true 时生效，生产中忽略。
  void overrideForDebug(DeviceTier tier) {
    if (!kDebugMode) return;
    _cached = tier;
  }

  /// 清除缓存（下次启动重新 Benchmark）。
  Future<void> clearCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _cached = null;
  }

  // ---- private ----

  static DeviceTier _classify(double avgMs) {
    if (avgMs < 80) return DeviceTier.flagship;
    if (avgMs < 200) return DeviceTier.midrange;
    return DeviceTier.budget;
  }

  static DeviceTier _tierFromString(String s) {
    return DeviceTier.values.firstWhere(
      (DeviceTier t) => t.name == s,
      orElse: () => DeviceTier.unknown,
    );
  }

  /// 执行纯 CPU Benchmark（不依赖 NCNN，兼容所有平台）。
  ///
  /// 策略：重复 5 轮质数计算 + 列表排序，取平均耗时作为 CPU 性能指标。
  /// 这与 NCNN 推理的 CPU-bound 特性高度正相关。
  static double _runCpuBenchmark() {
    const int rounds = 5;
    double total = 0;

    for (int r = 0; r < rounds; r++) {
      final Stopwatch sw = Stopwatch()..start();

      // Simulate compute-heavy work: prime sieve + sort.
      final List<int> numbers = <int>[];
      for (int i = 2; i < 30000; i++) {
        bool prime = true;
        final int limit = sqrt(i.toDouble()).ceil();
        for (int j = 2; j <= limit; j++) {
          if (i % j == 0) {
            prime = false;
            break;
          }
        }
        if (prime) {
          numbers.add(i);
        }
      }
      numbers.sort();

      sw.stop();
      total += sw.elapsedMicroseconds / 1000.0; // µs → ms
    }

    return total / rounds;
  }
}
