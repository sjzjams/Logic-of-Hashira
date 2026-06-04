package com.hashira.logic.fitness_log_app.segmentation

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.concurrent.Executors

/**
 * Sprint 2.2-C Phase D:Android 前景分割原生实现(已切到 YOLOv8-seg + ncnn)。
 *
 * 通道名 `calorie_snap/segmentation` 与 Dart 侧
 * `PlatformForegroundSegmentationService.channelName` 保持一致。
 *
 * 协议:
 * - method: `segment`
 * - 入参: `{ "imagePath": String }`
 * - 出参: `{ "originalPath": String, "foregroundPath": String }`
 * - 错误码: `INVALID_ARGUMENT` / `NO_CONTEXT` / `NCNN_UNAVAILABLE` /
 *          `DECODE_FAILED` / `NCNN_FAILED`
 *
 * Phase D 修订:segment 整段(bmp 解码 + ncnn 推理 + mask 合成 + PNG 写盘)
 * 移到单线程 Executor,避免在 main thread 阻塞 3-5s 触发 Android 5s ANR。
 * `result.success/error` 仍需在 main thread 调,用 Handler 切回。
 */
class ForegroundSegmentationPlugin : FlutterPlugin, MethodCallHandler {

    private var channel: MethodChannel? = null
    private var context: android.content.Context? = null
    private var assetManager: AssetManager? = null
    private val executor = Executors.newSingleThreadExecutor { r ->
        Thread(r, "food-segmenter").apply { isDaemon = true }
    }
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
        context = binding.applicationContext
        assetManager = binding.applicationContext.assets
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        assetManager = null
        context = null
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "segment" -> handleSegment(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleSegment(call: MethodCall, result: Result) {
        val imagePath = call.argument<String>("imagePath")
        if (imagePath.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "imagePath is required", null)
            return
        }
        val ctx = context
        val am = assetManager
        if (ctx == null || am == null) {
            result.error("NO_CONTEXT", "Plugin context or assetManager is not available", null)
            return
        }
        if (!NcnnBridge.isAvailable()) {
            result.error(
                "NCNN_UNAVAILABLE",
                "ncnn native library failed to load at app start (see logcat NcnnBridge)",
                null,
            )
            return
        }

        // 全部重活(解码 + 推理 + 写盘)挪到 worker,主线程只做参数校验和 result 分发。
        executor.execute {
            val decoded: Bitmap? = decodeBoundedBitmap(imagePath, maxEdge = 1024)
            if (decoded == null) {
                postError(result, "DECODE_FAILED", "Cannot decode bitmap from $imagePath", null)
                return@execute
            }
            try {
                val modelDir = File(ctx.cacheDir, "ncnn-cache").apply { mkdirs() }.absolutePath
                val rawResult = NcnnBridge.segment(
                    assetManager = am,
                    modelDir = modelDir,
                    cacheDir = ctx.cacheDir.absolutePath,
                    bitmap = decoded,
                )
                val parsed = parseSegmentResult(rawResult)
                postSuccess(
                    result,
                    imagePath,
                    parsed.foregroundPath,
                    parsed.maskPath,
                )
            } catch (t: Throwable) {
                postError(result, "NCNN_FAILED", t.message ?: "ncnn segment failed", null)
            } finally {
                decoded.recycle()
            }
        }
    }

    private fun postSuccess(
        result: Result,
        originalPath: String,
        foregroundPath: String,
        maskPath: String?,
    ) {
        mainHandler.post {
            val payload = HashMap<String, Any>(3)
            payload["originalPath"] = originalPath
            payload["foregroundPath"] = foregroundPath
            if (maskPath != null) {
                payload["maskPath"] = maskPath
            }
            result.success(payload)
        }
    }

    /**
     * 解析 native 返回的 `::` 分隔字符串。
     * V1.2-C 协议:
     *   - 三段式 `<fg>::<mask>::<label>:<prob>`
     *   - 兼容旧两段式 `<fg>::<label>:<prob>`
     */
    private data class SegmentResultParts(
        val foregroundPath: String,
        val maskPath: String?,
    )

    private fun parseSegmentResult(raw: String): SegmentResultParts {
        val parts = raw.split("::")
        return when (parts.size) {
            3 -> {
                // 0=fg, 1=mask, 2="<label>:<prob>"
                SegmentResultParts(parts[0], parts[1])
            }
            2 -> {
                // 0=fg, 1="<label>:<prob>"
                SegmentResultParts(parts[0], null)
            }
            else -> SegmentResultParts(raw, null)
        }
    }

    private fun postError(result: Result, code: String, message: String, details: Any?) {
        mainHandler.post { result.error(code, message, details) }
    }

    companion object {
        const val CHANNEL_NAME = "calorie_snap/segmentation"

        /**
         * 按最长边约束解码图片,避免大图 OOM。
         * YOLOv8 输入固定 640,这里上限取 1024 平衡精度与内存,再交给 native
         * 端做 letterbox。
         */
        private fun decodeBoundedBitmap(path: String, maxEdge: Int): Bitmap? {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, bounds)
            if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

            val longestEdge = maxOf(bounds.outWidth, bounds.outHeight)
            var sample = 1
            while (longestEdge / sample > maxEdge) {
                sample *= 2
            }

            val opts = BitmapFactory.Options().apply { inSampleSize = sample }
            return BitmapFactory.decodeFile(path, opts)
        }
    }
}
