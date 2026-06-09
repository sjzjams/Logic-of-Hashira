# 项目记忆

## 核心约定

- **项目名**: Logic-of-Hashira，Flutter 健身记录应用
- **包名**: `com.hashira.logic.fitness_log_app`
- **Android minSdk**: 24, ABI: arm64-v8a
- **代码风格**: 写 Flutter/Dart 代码，不做只读分析
- **Trellis 工作流**: 新功能应先建任务目录（trellis-brainstorm → PRD → implement/check jsonl → task.py start）

## Calorie Snap 功能

### 当前能力
- NCNN YOLOv8-seg 前景分割（~870ms），输出 .mag mask
- DisintegrateView Shader + EdgeGlowImage Shader + ParticleEmitter
- ProcessingViewV2 双阶段动效（locating → disintegrating）
- Hero 转场至 MealDetailScreen
- _AnimatedCount 数字滚动、45+ 食物营养数据库
- 相机预览 camera 插件 + 快门物理动画

### 已完成 Batch 0-5（2026-06-05）
- **Batch 0**: INF7(FoodEntity+CalorieConfidence) + INF10(SegmentationEngine) + INF8(SnapshotEvents埋点)
- **Batch 1**: INF1(DeviceTier+Benchmark) + INF6(置信度集成) + INF9(模型懒加载)
- **Batch 2**: T1(FoodCollapse保存动画) + T2(扫描线+打字机+置信度跳动) + T5(数字滚动600ms)
- **Batch 3**: T3(收据折叠展开) + T6(AI Coach区域)
- **Batch 4**: T4(Home SNAP入口+CalorieRing+RecentMeals重构)
- **Batch 5**: T8(History时间轴页面按日期+餐次分组+Hero转场)
- dart analyze 全绿通过，dart fix 0 issues
- 剩余：INF2(Native Camera Pipeline) + T7(实时YOLO高亮) 需原生层改动

## Shader 排坑
- SkSL (Android 9) 不允许 `sampler2D` 类型作为函数参数
- 所有 sampler 必须绑定 `setImageSampler()`，即使 mask==null 也要 bind image
