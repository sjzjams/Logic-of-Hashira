# Calorie Snap 原生层开发执行方案

> 文档版本：v1.0 | 创建日期：2026-06-05 | 作者：AI Assistant

---

## 1. 背景和目标

### 1.1 项目背景

Calorie Snap 是一个基于 Flutter + YOLO + RefineNet 技术路线的食物识别应用。当前项目已经完成了 Flutter/Dart 层的基础设施和功能体验层开发，包括：

- 8 幕 UI 流程的状态机实现
- 动画系统（Hero 转场、Interval 时序编排、Overlay 驱动动画等）
- 数据模型和营养计算逻辑
- 埋点系统

### 1.2 剩余工作目标

完成原生 Android 层（Kotlin/C++）的开发，实现以下功能：

1. **原生相机管线**：集成 CameraX，实现实时预览和帧捕获
2. **实时 YOLO 推理**：在相机预览过程中实时运行 YOLOv8-seg 推理
3. **掩码缓存优化**：优化掩码存储和复用机制
4. **AI 状态机**：实现完整的 8 幕状态机原生层对接
5. **时间投票稳定器**：通过 temporal voting 机制稳定识别结果
6. **实时 YOLO 高亮**：在预览上显示食物轮廓高亮

### 1.3 技术栈

- **Kotlin**：Android 原生代码
- **C++**：NCNN 推理引擎和 YOLOv8-seg 实现
- **CameraX**：相机预览和帧捕获
- **NCNN**：神经网络推理引擎
- **YOLOv8-seg**：实例分割模型

---

## 2. 当前状态分析

### 2.1 Flutter/Dart 层完成情况及技术栈

已完成的 Dart 层组件：

| 组件 | 文件路径 | 功能描述 |
|------|---------|----------|
| 状态机 | `lib/features/snapshot/snapshot_screen.dart` | 8 幕状态机驱动 UI |
| 分割引擎接口 | `lib/features/snapshot/segmentation_engine.dart` | 抽象分割引擎接口，目前 only YOLO 实现 |
| 相机预览页 | `lib/features/snapshot/live_capture_screen.dart` | 使用 `camera` 插件实现实时预览 |
| 动画组件 | `lib/core/widgets/` | 各种动画组件（FoodCollapse、ScanLine 等） |

**关键限制**：
- 当前 `SegmentationEngine.supportsRealtime` 返回 `false`，不支持实时推理
- `LiveCaptureScreen` 使用 `camera` 插件（Camera2 包装），没有集成 YOLO 实时推理
- 分割操作在拍照后异步执行，不支持预览帧实时处理

### 2.2 原生 Android 层当前实现状态

#### 2.2.1 Kotlin 层

`ForegroundSegmentationPlugin.kt`：
- 提供 `calorie_snap/segmentation` MethodChannel
- 使用单线程 Executor 处理分割
- 不支持实时相机帧处理
- 仅支持单次图片分割

#### 2.2.2 C++ 层

`food_segmenter.cpp`：
- YOLOv8-seg + NCNN 推理的 JNI 实现
- 单次分割流程：加载模型 → 推理 → 后处理 → 写盘
- 不支持实时逐帧处理
- 模型加载在首次调用时执行，之后复用

#### 2.2.3 构建配置

`android/app/build.gradle.kts`：
- 已配置 NDK 28.2.13676358
- 已配置 CMake 支持
- 已锁定 ABI 为 arm64-v8a
- 已集成 NCNN 预编译库

### 2.3 技术栈总结

| 技术 | 当前状态 | 需要改进 |
|------|----------|----------|
| CameraX | 未集成，使用 `camera` 插件 | 需要集成 CameraX 以实现更好的控制和性能 |
| NCNN | 已集成，单次推理 | 需要支持实时逐帧推理 |
| YOLOv8-seg | 已集成 | 需要优化以支持实时推理 |
| MethodChannel | 已建立 | 需要新增实时推理通道 |

---

## 3. 剩余工作清单

### 3.1 INF2 原生相机管线

**目标**：集成 CameraX，实现实时预览和帧捕获

**技术方案**：
1. 添加 CameraX 依赖
2. 实现 `CameraManager` 类，管理相机生命周期
3. 实现 `FrameAnalyzer` 类，分析每一帧
4. 将 CameraX 预览与 Flutter Texture 绑定

**关键文件**：
- 新增：`android/app/src/main/kotlin/com/hashira/logic/fitness_log_app/camera/CameraManager.kt`
- 新增：`android/app/src/main/kotlin/com/hashira/logic/fitness_log_app/camera/FrameAnalyzer.kt`
- 修改：`android/app/src/main/kotlin/com/hashira/logic/fitness_log_app/MainActivity.kt`

### 3.2 INF3 掩码缓存

**目标**：优化掩码存储和复用机制

**技术方案**：
1. 实现 `MaskCache` 类，管理掩码缓存
2. 使用 LRU 策略管理缓存大小
3. 支持掩码的快速查询和复用
4. 优化掩码存储格式（当前是 .mag 二进制格式）

**关键文件**：
- 新增：`android/app/src/main/kotlin/com/hashira/logic/fitness_log_app/cache/MaskCache.kt`
- 修改：`android/app/src/main/cpp/food_segmenter.cpp`（优化掩码输出）

### 3.3 INF4 AI 状态机

**目标**：实现完整的 8 幕状态机原生层对接

**技术方案**：
1. 在原生层实现状态机
2. 通过 MethodChannel 与 Dart 层同步状态
3. 实现状态转换的逻辑
4. 处理异常状态和恢复

**关键文件**：
- 新增：`android/app/src/main/kotlin/com/hashira/logic/fitness_log_app/state/AIStateMachine.kt`
- 修改：`lib/features/snapshot/snapshot_screen.dart`（对接原生状态机）

### 3.4 INF5 时间投票稳定器

**目标**：通过 temporal voting 机制稳定识别结果

**技术方案**：
1. 实现 `TemporalVoter` 类，管理时间序列上的识别结果
2. 使用投票机制稳定识别结果
3. 实现置信度衰减和刷新机制
4. 优化投票窗口大小

**关键文件**：
- 新增：`android/app/src/main/kotlin/com/hashira/logic/fitness_log_app/voting/TemporalVoter.kt`
- 修改：`android/app/src/main/cpp/food_segmenter.cpp`（接入投票结果）

### 3.5 T7 实时 YOLO 高亮

**目标**：在预览上显示食物轮廓高亮

**技术方案**：
1. 在 C++ 层实现实时 YOLO 推理
2. 将推理结果（检测框、掩码）传回 Dart 层
3. 在 Flutter UI 上绘制高亮轮廓
4. 优化渲染性能

**关键文件**：
- 修改：`android/app/src/main/cpp/food_segmenter.cpp`（新增实时推理接口）
- 修改：`android/app/src/main/kotlin/com/hashira/logic/fitness_log_app/segmentation/ForegroundSegmentationPlugin.kt`（新增 MethodChannel 方法）
- 新增：`lib/features/snapshot/realtime_overlay.dart`（实时高亮覆盖层）

---

## 4. 技术方案详解

### 4.1 INF2 原生相机管线技术方案

#### 4.1.1 添加 CameraX 依赖

在 `android/app/build.gradle.kts` 中添加：

```kotlin
dependencies {
    val cameraxVersion = "1.3.0"
    implementation("androidx.camera:camera-core:${cameraxVersion}")
    implementation("androidx.camera:camera-camera2:${cameraxVersion}")
    implementation("androidx.camera:camera-lifecycle:${cameraxVersion}")
    implementation("androidx.camera:camera-view:${cameraxVersion}")
}
```

#### 4.1.2 CameraManager 类

```kotlin
class CameraManager(private val context: Context) {
    private var cameraProvider: ProcessCameraProvider? = null
    private var camera: Camera? = null
    private var preview: Preview? = null
    private var imageAnalyzer: ImageAnalysis? = null
    
    fun initialize(onInitialized: (Success) -> Unit, onError: (Throwable) -> Unit) {
        // 1. 获取 CameraProvider
        // 2. 配置 Preview 用例
        // 3. 配置 ImageAnalysis 用例
        // 4. 绑定到生命周期
    }
    
    fun startPreview(surfaceProvider: Preview.SurfaceProvider) {
        // 启动预览
    }
    
    fun startAnalysis(analyzer: ImageAnalysis.Analyzer) {
        // 启动帧分析
    }
    
    fun release() {
        // 释放资源
    }
}
```

#### 4.1.3 FrameAnalyzer 类

```kotlin
class FrameAnalyzer(private val segmentationPlugin: ForegroundSegmentationPlugin) : ImageAnalysis.Analyzer {
    private var lastAnalysisTime = 0L
    private val analysisInterval = 500L // 每 500ms 分析一次
    
    override fun analyze(imageProxy: ImageProxy) {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastAnalysisTime < analysisInterval) {
            imageProxy.close()
            return
        }
        lastAnalysisTime = currentTime
        
        // 1. 将 ImageProxy 转换为 Bitmap
        // 2. 调用分割插件进行分析
        // 3. 将结果传回 Flutter 层
    }
}
```

#### 4.1.4 与 Flutter 集成

在 `MainActivity.kt` 中：

```kotlin
class MainActivity : FlutterActivity() {
    private lateinit var cameraManager: CameraManager
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册 CameraPlugin
        flutterEngine.plugins.add(CameraPlugin(cameraManager))
    }
}
```

### 4.2 INF3 掩码缓存技术方案

#### 4.2.1 MaskCache 类

```kotlin
class MaskCache(private val cacheDir: File) {
    private val cache = LruCache<String, Mask>(100) // 最多缓存 100 个掩码
    private val diskCacheDir = File(cacheDir, "mask_cache")
    
    init {
        diskCacheDir.mkdirs()
    }
    
    fun getMask(key: String): Mask? {
        // 1. 尝试从内存缓存获取
        // 2. 如果内存中没有，尝试从磁盘缓存加载
        // 3. 返回掩码或 null
    }
    
    fun putMask(key: String, mask: Mask) {
        // 1. 存入内存缓存
        // 2. 异步写入磁盘缓存
    }
    
    fun clear() {
        // 清空内存和磁盘缓存
    }
}
```

#### 4.2.2 优化掩码存储格式

当前掩码存储为 .mag 二进制格式（bit plane）。可以考虑：

1. **压缩优化**：使用 zlib 压缩 bit plane
2. **增量存储**：只存储变化的部分
3. **预缩放**：存储多个分辨率的掩码

### 4.3 INF4 AI 状态机技术方案

#### 4.3.1 AIStateMachine 类

```kotlin
enum class AIState {
    IDLE,
    CAMERA_READY,
    CAPTURE,
    FREEZE_FRAME,
    FOOD_EXTRACT,
    AI_ANALYZING,
    RESULT_REVEAL,
    FOOD_DETAIL,
    SAVE_MEAL,
    HISTORY
}

class AIStateMachine {
    private var currentState: AIState = AIState.IDLE
    private val stateListeners = mutableListOf<(AIState, AIState) -> Unit>()
    
    fun transitionTo(newState: AIState) {
        val oldState = currentState
        currentState = newState
        stateListeners.forEach { it(oldState, newState) }
    }
    
    fun getCurrentState(): AIState = currentState
    
    fun addStateListener(listener: (AIState, AIState) -> Unit) {
        stateListeners.add(listener)
    }
    
    fun removeStateListener(listener: (AIState, AIState) -> Unit) {
        stateListeners.remove(listener)
    }
}
```

#### 4.3.2 与 Dart 层同步

通过 MethodChannel 同步状态：

```kotlin
class StateSyncPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null
    private lateinit var stateMachine: AIStateMachine
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getState" -> result.success(stateMachine.getCurrentState().name)
            "transitionTo" -> {
                val newState = AIState.valueOf(call.arguments as String)
                stateMachine.transitionTo(newState)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
```

### 4.4 INF5 时间投票稳定器技术方案

#### 4.4.1 TemporalVoter 类

```kotlin
class TemporalVoter(private val windowSize: Int = 10) {
    private val results = mutableListOf<RecognitionResult>()
    
    fun addResult(result: RecognitionResult) {
        results.add(result)
        if (results.size > windowSize) {
            results.removeAt(0)
        }
    }
    
    fun getStableResult(): RecognitionResult? {
        if (results.isEmpty()) return null
        
        // 1. 统计每个食物类别的出现次数
        // 2. 选择出现次数最多的类别
        // 3. 计算平均置信度
        // 4. 返回稳定的结果
    }
    
    fun clear() {
        results.clear()
    }
}
```

#### 4.4.2 接入分割流程

在 `FrameAnalyzer` 中接入 `TemporalVoter`：

```kotlin
class FrameAnalyzer(private val segmentationPlugin: ForegroundSegmentationPlugin) : ImageAnalysis.Analyzer {
    private val temporalVoter = TemporalVoter()
    
    override fun analyze(imageProxy: ImageProxy) {
        // ... 执行分割
        
        // 将结果加入投票器
        temporalVoter.addResult(result)
        
        // 获取稳定结果
        val stableResult = temporalVoter.getStableResult()
        if (stableResult != null) {
            // 将稳定结果传回 Flutter 层
        }
    }
}
```

### 4.5 T7 实时 YOLO 高亮技术方案

#### 4.5.1 新增实时推理接口

在 `food_segmenter.cpp` 中新增：

```cpp
extern "C" JNIEXPORT jobjectArray JNICALL
Java_com_hashira_logic_fitness_1log_1app_segmentation_NcnnBridge_nativeAnalyzeFrame(
    JNIEnv* env, jobject /*thiz*/,
    jobject jBitmap) {
    
    // 1. 将 Bitmap 转换为 ncnn::Mat
    // 2. 执行 YOLOv8-seg 推理
    // 3. 返回检测结果（检测框、掩码等）
}
```

#### 4.5.2 新增 MethodChannel 方法

在 `ForegroundSegmentationPlugin.kt` 中新增：

```kotlin
class ForegroundSegmentationPlugin : FlutterPlugin, MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "analyzeFrame" -> handleAnalyzeFrame(call, result)
            // ... 其他方法
        }
    }
    
    private fun handleAnalyzeFrame(call: MethodCall, result: Result) {
        val bitmap = ... // 从 call.arguments 中获取 Bitmap
        executor.execute {
            val results = NcnnBridge.nativeAnalyzeFrame(bitmap)
            mainHandler.post {
                result.success(results)
            }
        }
    }
}
```

#### 4.5.3 实时高亮覆盖层

在 Dart 层新增 `RealtimeOverlay` 组件：

```dart
class RealtimeOverlay extends StatelessWidget {
  final List<DetectionResult> detections;
  
  const RealtimeOverlay({required this.detections});
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HighlightPainter(detections),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  final List<DetectionResult> detections;
  
  _HighlightPainter(this.detections);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final detection in detections) {
      // 绘制检测框
      // 绘制掩码轮廓
    }
  }
  
  @override
  bool shouldRepaint(covariant _HighlightPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}
```

---

## 5. 执行计划

### 5.1 分批执行计划

#### 批次 1：INF2 原生相机管线（预计 3 天）

**任务**：
1. 添加 CameraX 依赖
2. 实现 `CameraManager` 类
3. 实现 `FrameAnalyzer` 类
4. 与 Flutter 集成测试

**预期产出**：
- 相机预览正常运行
- 能够捕获预览帧
- 帧分析流程打通

#### 批次 2：INF3 掩码缓存（预计 2 天）

**任务**：
1. 实现 `MaskCache` 类
2. 优化掩码存储格式
3. 集成到分割流程

**预期产出**：
- 掩码缓存功能正常
- 缓存命中率提升
- 磁盘占用优化

#### 批次 3：T7 实时 YOLO 高亮（预计 4 天）

**任务**：
1. 在 C++ 层新增实时推理接口
2. 在 Kotlin 层新增 MethodChannel 方法
3. 实现 Dart 层实时高亮覆盖层
4. 端到端测试

**预期产出**：
- 实时 YOLO 推理正常运行
- 高亮轮廓正确显示
- 性能满足要求（≥ 15 FPS）

#### 批次 4：INF5 时间投票稳定器（预计 2 天）

**任务**：
1. 实现 `TemporalVoter` 类
2. 接入分割流程
3. 优化投票参数

**预期产出**：
- 识别结果稳定
- 置信度合理
- 响应延迟低

#### 批次 5：INF4 AI 状态机（预计 3 天）

**任务**：
1. 实现 `AIStateMachine` 类
2. 与 Dart 层对接
3. 实现状态同步机制

**预期产出**：
- 状态机正常运行
- 状态同步准确
- 异常处理完善

### 5.2 关键路径

```
INF2 (相机管线) → T7 (实时高亮) → INF5 (投票稳定) → INF4 (状态机)
```

INF2 是基础，必须最先完成。T7 依赖 INF2 的帧捕获能力。INF5 和 INF4 可以并行开发，但建议在 T7 完成后开始。

---

## 6. 依赖关系

### 6.1 外部依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| CameraX | 1.3.0 | 相机预览和帧捕获 |
| NCNN | 20231024 | 神经网络推理引擎 |
| Kotlin | 2.2.20 | Android 原生开发 |
| NDK | 28.2.13676358 | C++ 编译 |

### 6.2 内部依赖

| 组件 | 依赖组件 | 说明 |
|------|----------|------|
| T7 实时高亮 | INF2 相机管线 | 需要帧捕获能力 |
| INF5 投票稳定 | T7 实时高亮 | 需要实时识别结果 |
| INF4 状态机 | INF2/INF3/INF5/T7 | 需要所有原生功能就绪 |

---

## 7. 验证和测试方案

### 7.1 单元测试

| 组件 | 测试内容 | 测试框架 |
|------|----------|----------|
| CameraManager | 相机初始化、预览、释放 | JUnit |
| MaskCache | 缓存命中、LRU 策略 | JUnit |
| TemporalVoter | 投票逻辑、窗口管理 | JUnit |
| AIStateMachine | 状态转换、监听通知 | JUnit |

### 7.2 集成测试

| 测试场景 | 测试步骤 | 预期结果 |
|----------|----------|----------|
| 相机预览 | 打开相机页面 → 检查预览 | 预览正常显示 |
| 实时识别 | 对准食物 → 检查高亮 | 高亮轮廓正确显示 |
| 状态转换 | 执行完整流程 → 检查状态 | 状态正确转换 |
| 掩码缓存 | 重复识别同一食物 → 检查缓存 | 缓存命中率 > 50% |

### 7.3 性能测试

| 指标 | 目标值 | 测试方法 |
|------|--------|----------|
| 相机预览帧率 | ≥ 30 FPS | 使用 `adb shell dumpsys gfxinfo` |
| 实时推理帧率 | ≥ 15 FPS | 使用 `System.currentTimeMillis()` 计时 |
| 内存占用 | < 200 MB | 使用 Android Profiler |
| 电池消耗 | < 10%/小时 | 使用 Android Profiler |

---

## 8. 风险和建议

### 8.1 风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| CameraX 与现有 `camera` 插件冲突 | 高 | 逐步迁移，先在新页面测试 |
| NCNN 实时推理性能不足 | 高 | 优化模型、降低输入分辨率、使用 GPU 加速 |
| 内存泄漏 | 中 | 使用 Android Profiler 定期检查 |
| 设备兼容性 | 中 | 在多种设备上测试 |

### 8.2 建议

1. **逐步迁移**：不要一次性替换所有相机相关代码，先在新页面测试 CameraX，验证稳定后再迁移旧页面。

2. **性能优化**：
   - 降低 YOLO 输入分辨率（从 640 降到 416 或 320）
   - 使用 NCNN Vulkan GPU 加速
   - 减少推理频率（每 500ms 一次而不是每帧都推理）

3. **异常处理**：
   - 所有原生代码都要有完善的异常处理
   - 使用 try-catch 包装 JNI 调用
   - 在 Dart 层实现降级逻辑

4. **测试覆盖**：
   - 为每个原生组件编写单元测试
   - 在多种设备上运行集成测试
   - 使用 Firebase Test Lab 进行云端测试

---

## 9. 附录

### 9.1 相关文件清单

| 文件路径 | 用途 |
|----------|------|
| `lib/features/snapshot/snapshot_screen.dart` | Dart 层状态机 |
| `lib/features/snapshot/segmentation_engine.dart` | 分割引擎接口 |
| `lib/features/snapshot/live_capture_screen.dart` | 相机预览页 |
| `android/app/src/main/kotlin/.../ForegroundSegmentationPlugin.kt` | 分割插件 |
| `android/app/src/main/cpp/food_segmenter.cpp` | NCNN 推理实现 |
| `android/app/build.gradle.kts` | 构建配置 |

### 9.2 参考资料

- CameraX 官方文档：https://developer.android.com/training/camerax
- NCNN 官方文档：https://github.com/Tencent/ncnn/wiki
- YOLOv8-seg 文档：https://docs.ultralytics.com/tasks/segment/

---

**文档结束**
