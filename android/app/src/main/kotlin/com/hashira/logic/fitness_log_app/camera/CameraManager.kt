package com.hashira.logic.fitness_log_app.camera

import android.content.Context
import android.util.Log
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.lifecycle.LifecycleOwner
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * CameraManager：管理 CameraX 相机生命周期和用例。
 *
 * 功能：
 * 1. 初始化 CameraX，获取 CameraProvider（后台线程同步等待）
 * 2. 配置和绑定 Preview 用例
 * 3. 配置和绑定 ImageAnalysis 用例
 * 4. 管理相机资源释放
 */
class CameraManager(private val context: Context) {
    companion object {
        private const val TAG = "CameraManager"
    }

    private var cameraProvider: ProcessCameraProvider? = null
    private var camera: Camera? = null
    private var preview: Preview? = null
    private var imageAnalyzer: ImageAnalysis? = null
    private var cameraSelector: CameraSelector? = null
    
    private val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor { r ->
        Thread(r, "camera-executor").apply { isDaemon = true }
    }

    /**
     * 初始化 CameraX。
     *
     * 在后台线程同步获取 ProcessCameraProvider，避免 ListenableFuture 依赖问题。
     */
    fun initialize(
        lifecycleOwner: LifecycleOwner,
        onInitialized: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        cameraExecutor.execute {
            try {
                val provider = CameraXHelper.getProcessCameraProvider(context)
                
                if (provider != null) {
                    android.os.Handler(android.os.Looper.getMainLooper()).post {
                        cameraProvider = provider
                        cameraSelector = CameraSelector.Builder()
                            .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                            .build()
                        Log.i(TAG, "CameraProvider initialized successfully")
                        onInitialized()
                    }
                } else {
                    android.os.Handler(android.os.Looper.getMainLooper()).post {
                        onError(RuntimeException("ProcessCameraProvider is null"))
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to initialize CameraProvider", e)
                android.os.Handler(android.os.Looper.getMainLooper()).post {
                    onError(e)
                }
            }
        }
    }

    /**
     * 启动相机预览。
     */
    fun startPreview(
        lifecycleOwner: LifecycleOwner,
        surfaceProvider: Preview.SurfaceProvider
    ) {
        val provider = cameraProvider ?: run {
            Log.e(TAG, "CameraProvider is not initialized")
            return
        }
        
        val selector = cameraSelector ?: run {
            Log.e(TAG, "CameraSelector is not initialized")
            return
        }

        provider.unbindAll()

        preview = Preview.Builder()
            .setTargetRotation(android.view.Surface.ROTATION_0)
            .build()
            .apply { setSurfaceProvider(surfaceProvider) }

        try {
            camera = provider.bindToLifecycle(lifecycleOwner, selector, preview)
            Log.i(TAG, "Preview started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start preview", e)
        }
    }

    /**
     * 启动帧分析。
     */
    fun startAnalysis(
        lifecycleOwner: LifecycleOwner,
        analyzer: ImageAnalysis.Analyzer
    ) {
        val provider = cameraProvider ?: run {
            Log.e(TAG, "CameraProvider is not initialized")
            return
        }
        
        val selector = cameraSelector ?: run {
            Log.e(TAG, "CameraSelector is not initialized")
            return
        }

        imageAnalyzer = ImageAnalysis.Builder()
            .setTargetResolution(android.util.Size(640, 480))
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()
            .apply { setAnalyzer(cameraExecutor, analyzer) }

        try {
            // 如果已有 preview 绑定，同时绑定 analysis
            val useCases = mutableListOf<androidx.camera.core.UseCase>()
            preview?.let { useCases.add(it) }
            useCases.add(imageAnalyzer!!)
            
            camera = provider.bindToLifecycle(lifecycleOwner, selector, *useCases.toTypedArray())
            Log.i(TAG, "Frame analysis started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start frame analysis", e)
        }
    }

    /**
     * 切换前后摄像头。
     */
    fun switchCamera(lifecycleOwner: LifecycleOwner, surfaceProvider: Preview.SurfaceProvider? = null) {
        val current = cameraSelector ?: return
        val newFacing = if (current.lensFacing == CameraSelector.LENS_FACING_BACK) {
            CameraSelector.LENS_FACING_FRONT
        } else {
            CameraSelector.LENS_FACING_BACK
        }
        
        cameraSelector = CameraSelector.Builder()
            .requireLensFacing(newFacing)
            .build()
        
        if (surfaceProvider != null) {
            startPreview(lifecycleOwner, surfaceProvider)
        }
        
        Log.i(TAG, "Switched camera to ${if (newFacing == CameraSelector.LENS_FACING_BACK) "back" else "front"}")
    }

    /** 获取当前 ProcessCameraProvider。 */
    fun getCameraProvider(): ProcessCameraProvider? = cameraProvider

    /**
     * 释放相机资源。
     */
    fun release() {
        try {
            cameraProvider?.unbindAll()
            cameraProvider = null
            camera = null
            preview = null
            imageAnalyzer = null
            Log.i(TAG, "Camera resources released")
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing camera resources", e)
        }
    }

    /** 关闭执行器。 */
    fun shutdown() {
        release()
        cameraExecutor.shutdown()
        Log.i(TAG, "CameraExecutor shutdown")
    }
}
