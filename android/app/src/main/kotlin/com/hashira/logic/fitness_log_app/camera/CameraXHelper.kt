package com.hashira.logic.fitness_log_app.camera

import android.content.Context
import androidx.camera.lifecycle.ProcessCameraProvider
import com.google.common.util.concurrent.ListenableFuture
/**
 * CameraX 辅助工具：获取 ProcessCameraProvider。
 */
object CameraXHelper {
    /**
     * 获取 ProcessCameraProvider（阻塞调用，应在后台线程使用）。
     */
    fun getProcessCameraProvider(context: Context): ProcessCameraProvider? {
        return try {
            val future: ListenableFuture<ProcessCameraProvider> =
                ProcessCameraProvider.getInstance(context)
            future.get()
        } catch (e: Exception) {
            android.util.Log.e("CameraXHelper", "Failed to get ProcessCameraProvider", e)
            null
        }
    }
}
