package com.hashira.logic.fitness_log_app.camera

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.util.Log
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * FrameAnalyzer：分析相机预览的每一帧。
 *
 * 功能：
 * 1. 控制帧分析频率（避免过于频繁）
 * 2. 将 ImageProxy (NV21 YUV) 转换为 Bitmap
 * 3. 通过回调将 Bitmap 传递给上层处理
 *
 * 使用方式：
 * 1. 创建 FrameAnalyzer 实例，传入分析回调
 * 2. 将其设置为 ImageAnalysis 的分析器
 * 3. 在 onFrameAnalyzed 回调中处理 Bitmap
 */
class FrameAnalyzer(
    private val onFrameAnalyzed: (Bitmap) -> Unit,
) : ImageAnalysis.Analyzer {

    companion object {
        private const val TAG = "FrameAnalyzer"
        private const val ANALYSIS_INTERVAL_MS = 500L // 每 500ms 分析一次
    }

    private var lastAnalysisTimeMs = 0L
    private val executor: ExecutorService = Executors.newSingleThreadExecutor { r ->
        Thread(r, "frame-analyzer").apply { isDaemon = true }
    }

    @Volatile
    private var isAnalyzing = false

    override fun analyze(imageProxy: ImageProxy) {
        val currentTime = System.currentTimeMillis()

        // 控制分析频率
        if (currentTime - lastAnalysisTimeMs < ANALYSIS_INTERVAL_MS) {
            imageProxy.close()
            return
        }

        // 防止重复分析（上一帧还在处理中）
        if (isAnalyzing) {
            imageProxy.close()
            return
        }

        lastAnalysisTimeMs = currentTime
        isAnalyzing = true

        // 在后台线程处理图像转换，避免阻塞相机管道
        executor.execute {
            try {
                val bitmap = imageProxyToBitmap(imageProxy)
                if (bitmap != null) {
                    onFrameAnalyzed(bitmap)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error analyzing frame", e)
            } finally {
                isAnalyzing = false
                imageProxy.close()
            }
        }
    }

    /**
     * 将 ImageProxy (NV21 YUV_420_888) 转换为 Bitmap。
     *
     * CameraX 默认输出 YUV_420_888 格式，需要先转为 NV21，
     * 再通过 YuvImage 编码为 JPEG，最后解码为 Bitmap。
     */
    private fun imageProxyToBitmap(imageProxy: ImageProxy): Bitmap? {
        return try {
            val yBuffer = imageProxy.planes[0].buffer
            val uBuffer = imageProxy.planes[1].buffer
            val vBuffer = imageProxy.planes[2].buffer

            val ySize = yBuffer.remaining()
            val uSize = uBuffer.remaining()
            val vSize = vBuffer.remaining()

            val nv21 = ByteArray(ySize + uSize + vSize)

            // Y
            yBuffer.get(nv21, 0, ySize)

            // VU (NV21 格式要求 V 在前 U 在后)
            vBuffer.get(nv21, ySize, vSize)
            uBuffer.get(nv21, ySize + vSize, uSize)

            val yuvImage = YuvImage(
                nv21,
                ImageFormat.NV21,
                imageProxy.width,
                imageProxy.height,
                null
            )

            val out = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, imageProxy.width, imageProxy.height), 90, out)
            val jpegBytes = out.toByteArray()
            BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size)
        } catch (e: Exception) {
            Log.e(TAG, "Error converting ImageProxy to Bitmap", e)
            null
        }
    }

    /** 释放资源。 */
    fun shutdown() {
        executor.shutdown()
        Log.i(TAG, "FrameAnalyzer shutdown")
    }
}
