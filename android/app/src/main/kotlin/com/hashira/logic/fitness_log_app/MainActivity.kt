package com.hashira.logic.fitness_log_app

import com.hashira.logic.fitness_log_app.segmentation.ForegroundSegmentationPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Sprint 2.2-B：注册 [ForegroundSegmentationPlugin]，向 Dart 侧
 * 暴露 `calorie_snap/segmentation` 通道。
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ForegroundSegmentationPlugin())
    }
}
