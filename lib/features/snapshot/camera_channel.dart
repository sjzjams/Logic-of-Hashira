/// CameraChannel：Dart 层与原生 CameraPlugin 的通信接口。
///
/// 功能：
/// 1. 使用 MethodChannel 与原生 CameraPlugin 通信
/// 2. 提供 initialize、startPreview、startAnalysis、switchCamera、release 等方法
/// 3. 处理原生层返回的结果
///
/// MethodChannel 名称：`com.hashira.logic.fitness_log_app/camera`
library;

import 'dart:async';

import 'package:flutter/services.dart';

/// 相机操作异常。
class CameraChannelException implements Exception {
  const CameraChannelException(this.message);

  final String message;

  @override
  String toString() => 'CameraChannelException: $message';
}

/// CameraChannel：管理与原生相机管线的通信。
class CameraChannel {
  const CameraChannel._();

  static const CameraChannel _instance = CameraChannel._();

  factory CameraChannel() => _instance;

  static const String _channelName = 'com.hashira.logic.fitness_log_app/camera';
  static const MethodChannel _channel = MethodChannel(_channelName);

  /// 初始化相机。
  Future<bool> initialize() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('initialize');
      return result ?? false;
    } on PlatformException catch (e) {
      throw CameraChannelException('Failed to initialize camera: ${e.message}');
    }
  }

  /// 启动预览。
  ///
  /// [surfaceProvider] 在 CameraX 中不直接使用，因为预览表面由 CameraX 管理。
  /// 这个方法主要用于通知原生层开始预览。
  Future<bool> startPreview() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('startPreview');
      return result ?? false;
    } on PlatformException catch (e) {
      throw CameraChannelException('Failed to start preview: ${e.message}');
    }
  }

  /// 启动帧分析。
  Future<bool> startAnalysis() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('startAnalysis');
      return result ?? false;
    } on PlatformException catch (e) {
      throw CameraChannelException('Failed to start analysis: ${e.message}');
    }
  }

  /// 切换前后摄像头。
  Future<bool> switchCamera() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('switchCamera');
      return result ?? false;
    } on PlatformException catch (e) {
      throw CameraChannelException('Failed to switch camera: ${e.message}');
    }
  }

  /// 释放相机资源。
  Future<bool> release() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('release');
      return result ?? false;
    } on PlatformException catch (e) {
      throw CameraChannelException('Failed to release camera: ${e.message}');
    }
  }

  /// 设置分析结果回调。
  ///
  /// 当原生层完成一帧的分析后，会通过这个方法回调结果。
  void setAnalysisCompleteHandler(Future<void> Function(String?) handler) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onAnalysisComplete') {
        final String? resultJson = call.arguments as String?;
        await handler(resultJson);
      }
    });
  }
}
