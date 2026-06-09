import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Shader 预加载服务。
///
/// 在 App 启动时预编译 Fragment Shader，避免首次使用时延迟。
/// 支持失败重试（最多 3 次），GPU 驱动兼容性。
///
/// 使用方式：
/// ```dart
/// void main() {
///   ShaderPreloader.preloadAll().then((results) {
///     debugPrint('🎨 [ShaderPreload] Results: $results');
///   });
/// }
/// ```
class ShaderPreloader {
  static final ShaderPreloader instance = ShaderPreloader._();
  ShaderPreloader._();

  final Map<String, ui.FragmentProgram?> _cache = {};

  /// 预加载指定 Shader asset。
  /// 返回 true 表示加载成功，false 表示所有重试均失败。
  Future<bool> preload(String assetPath, {int maxRetries = 3}) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath] != null;
    }

    for (int i = 0; i < maxRetries; i++) {
      try {
        debugPrint(
          '🎨 [ShaderPreloader] Loading $assetPath '
          '(attempt ${i + 1}/$maxRetries)',
        );
        final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
          assetPath,
        );
        _cache[assetPath] = program;
        debugPrint('✅ [ShaderPreloader] $assetPath loaded');
        return true;
      } catch (e) {
        debugPrint('⚠️ [ShaderPreloader] $assetPath failed: $e');
        if (i < maxRetries - 1) {
          await Future<void>.delayed(Duration(milliseconds: 300 * (i + 1)));
        }
      }
    }

    _cache[assetPath] = null;
    return false;
  }

  /// 获取已缓存的 Shader Program（可能为 null）。
  ui.FragmentProgram? get(String assetPath) => _cache[assetPath];

  /// 检查指定 Shader 是否已成功加载。
  bool isLoaded(String assetPath) =>
      _cache.containsKey(assetPath) && _cache[assetPath] != null;

  /// 批量预加载所有业务 Shader。
  static Future<Map<String, bool>> preloadAll() async {
    final Map<String, bool> results = <String, bool>{};
    const List<String> assets = <String>[
      'shaders/edge_disintegrate.frag',
      'shaders/disintegrate_bg.frag',
    ];

    for (final String asset in assets) {
      results[asset] = await instance.preload(asset);
    }
    return results;
  }
}
