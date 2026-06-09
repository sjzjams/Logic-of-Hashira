package com.hashira.logic.fitness_log_app.camera

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor
import java.util.concurrent.Executors

/**
 * CameraPlugin：Flutter 插件，提供相机功能给 Dart 层。
 *
 * MethodChannel 名称：`com.hashira.logic.fitness_log_app/camera`
 *
 * 支持的方法：
 * - `initialize`：初始化相机（异步）
 * - `startPreview`：启动预览（需 surface texture entry）
 * - `release`：释放相机资源
 * - `switchCamera`：切换前后摄像头
 */
class CameraPlugin(
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "CameraPlugin"
        const val CHANNEL_NAME = "com.hashira.logic.fitness_log_app/camera"

        /**
         * 注册 CameraPlugin 到 Flutter 引擎。
         */
        fun registerWith(flutterEngine: FlutterEngine, context: Context): CameraPlugin {
            val plugin = CameraPlugin(context)
            plugin.channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            plugin.channel?.setMethodCallHandler(plugin)
            return plugin
        }
    }

    private var channel: MethodChannel? = null
    private var cameraManager: CameraManager? = null
    private var lifecycleOwner: LifecycleOwner? = null
    private val mainExecutor: Executor = Executors.newSingleThreadExecutor { r ->
        Thread(r, "camera-plugin-main").apply { isDaemon = true }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> handleInitialize(result)
            "startPreview" -> {
                // 预览绑定需要 TextureEntry，暂返回 notImplemented
                result.notImplemented()
            }
            "release" -> handleRelease(result)
            "switchCamera" -> handleSwitchCamera(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(result: MethodChannel.Result) {
        val lifecycleOwner = this.lifecycleOwner
        if (lifecycleOwner == null) {
            result.error("NO_LIFECYCLE", "LifecycleOwner is not set. Call setLifecycleOwner first.", null)
            return
        }
        if (cameraManager != null) {
            result.success(true) // 已初始化，直接成功
            return
        }
        cameraManager = CameraManager(context)
        cameraManager?.initialize(
            lifecycleOwner = lifecycleOwner,
            onInitialized = {
                android.util.Log.i(TAG, "Camera initialized successfully")
                result.success(true)
            },
            onError = { e ->
                android.util.Log.e(TAG, "Camera initialization failed", e)
                result.error("INIT_ERROR", e.message ?: "Unknown error", null)
            }
        ) ?: run {
            result.error("INIT_ERROR", "Failed to create CameraManager", null)
        }
    }

    private fun handleRelease(result: MethodChannel.Result) {
        try {
            cameraManager?.release()
            result.success(true)
        } catch (e: Exception) {
            result.error("RELEASE_ERROR", e.message ?: "Release failed", null)
        }
    }

    private fun handleSwitchCamera(result: MethodChannel.Result) {
        val lifecycleOwner = this.lifecycleOwner
        if (lifecycleOwner == null) {
            result.error("NO_LIFECYCLE", "LifecycleOwner is not set", null)
            return
        }
        try {
            cameraManager?.switchCamera(lifecycleOwner)
            result.success(true)
        } catch (e: Exception) {
            result.error("SWITCH_ERROR", e.message ?: "Switch camera failed", null)
        }
    }

    /**
     * 设置 LifecycleOwner，用于绑定相机生命周期。
     * 必须在 initialize 之前调用。
     */
    fun setLifecycleOwner(owner: LifecycleOwner?) {
        this.lifecycleOwner = owner
    }

    /**
     * 获取 CameraManager 实例（用于外部组件如 DetectionOverlayView 绑定）。
     */
    fun getCameraManager(): CameraManager? = cameraManager

    /** 获取 MethodChannel（用于向 Dart 层推送事件）。 */
    fun getChannel(): MethodChannel? = channel

    /**
     * 释放资源。
     */
    fun release() {
        cameraManager?.shutdown()
        cameraManager = null
        channel?.setMethodCallHandler(null)
        channel = null
        lifecycleOwner = null
    }
}
