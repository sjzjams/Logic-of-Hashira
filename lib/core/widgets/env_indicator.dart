// lib/core/widgets/env_indicator.dart
//
// 环境指示器 Widget
// 仅在开发环境显示，用于区分开发版本和正式版本

import 'package:flutter/material.dart';
import '../../core/config/env_config.dart';

/// 环境指示器
///
/// 功能：
/// - 仅在开发环境 (ENV=dev) 显示
/// - 显示在右上角
/// - 半透明橙色背景，显示 "DEV" 文字
/// - 不会影响用户操作（使用 [Positioned] + [IgnorePointer]）
class EnvIndicator extends StatelessWidget {
  const EnvIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // 生产环境不显示
    if (!EnvConfig.isDev) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 8,
      right: 8,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            'DEV',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// 环境标识（用于 AppBar 标题旁）
///
/// 使用方式：
/// ```dart
/// AppBar(
///   title: Row(
///     children: [
///       Text('首页'),
///       SizedBox(width: 8),
///       EnvBadge(),
///     ],
///   ),
/// )
/// ```
class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key});

  @override
  Widget build(BuildContext context) {
    if (!EnvConfig.isDev) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'DEV',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 环境信息面板（调试用）
///
/// 在开发环境显示一个可展开的信息面板，包含：
/// - 当前环境
/// - API 地址
/// - 构建时间
/// - Git 提交
///
/// 使用方式：
/// ```dart
/// if (EnvConfig.isDev) EnvInfoPanel(),
/// ```
class EnvInfoPanel extends StatefulWidget {
  const EnvInfoPanel({super.key});

  @override
  State<EnvInfoPanel> createState() => _EnvInfoPanelState();
}

class _EnvInfoPanelState extends State<EnvInfoPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!EnvConfig.isDev) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 60, // 避免遮挡底部导航
      left: 8,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🛠 DEV MODE',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_expanded) ...[
                const SizedBox(height: 4),
                Text(
                  'Env: ${EnvConfig.env}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  'API: ${EnvConfig.apiBaseUrl}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                if (EnvConfig.buildTime.isNotEmpty)
                  Text(
                    'Build: ${EnvConfig.buildTime}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                if (EnvConfig.gitCommit.isNotEmpty)
                  Text(
                    'Commit: ${EnvConfig.gitCommit}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
