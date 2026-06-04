# Calorie Snap V1.0 接口字段清单

关联文档：

- [Calorie Snap V1.0产品级PRD-整合版.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0%E4%BA%A7%E5%93%81%E7%BA%A7PRD-%E6%95%B4%E5%90%88%E7%89%88.md)
- [Calorie Snap V1.0-埋点表.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0-%E5%9F%8B%E7%82%B9%E8%A1%A8.md)

---

## 1. 目标

本清单用于把 PRD 中的核心数据对象整理为可实现、可对接、可建模的字段契约，重点覆盖：

- Snapshot 分析结果
- Nutrition 入库模型
- Dashboard 汇总模型
- Coach 会话与消息事件模型
- Analytics 事件参数模型

本版本面向 MVP，因此优先保证：

- 字段语义清晰
- 跨页面传递稳定
- 与埋点口径一致
- 未来接入本地存储或云端服务时可扩展

---

## 2. 字段设计原则

- 每个字段只表达一个含义，避免一个字段承载多个语义。
- UI 展示字段与埋点字段尽量共用同一套命名。
- 业务实体与埋点参数分离，避免把埋点临时字段混进核心数据表。
- 可枚举字段尽量固定取值范围，避免上线后漂移。

---

## 3. FoodRecognitionResult

用途：

- Snapshot 分析完成后，从 Processing 传给 Result 页的中间结果对象
- 可作为后续保存 Meal / Nutrition 的上游输入

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `foodName` | string | 否 | `Chicken Rice` | 识别出的食物名 |
| `confidence` | double | 否 | `0.92` | 识别置信度，范围建议 `0.0 ~ 1.0` |
| `estimatedWeightGrams` | double | 否 | `280` | 估算重量，单位 `g` |
| `calories` | double | 否 | `520` | 估算热量 |
| `proteinGrams` | double | 否 | `38` | 蛋白质克数 |
| `carbsGrams` | double | 否 | `62` | 碳水克数 |
| `fatGrams` | double | 否 | `12` | 脂肪克数 |
| `fiberGrams` | double | 否 | `5` | 膳食纤维克数 |
| `ingredients` | List<string> | 否 | `["chicken", "rice"]` | 识别出的主要成分 |
| `mealType` | string | 否 | `lunch` | 餐次类型 |
| `imagePath` | string | 是 | `/local/path/a.jpg` | 原图路径 |
| `cutoutImagePath` | string | 否 | `/local/path/cutout.png` | 抠图后的主体图片路径 |
| `analysisDurationMs` | int | 否 | `420` | 分析总耗时 |

建议枚举：

- `mealType`: `breakfast / lunch / dinner / snack / unknown`

---

## 4. Meal

用途：

- 落库后的单条饮食记录主实体
- 用于 Timeline、Meal Detail、Dashboard 汇总

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `id` | string | 是 | `meal_20260603_001` | Meal 唯一标识 |
| `photoPath` | string | 是 | `/local/path/a.jpg` | 原图路径 |
| `thumbnailPath` | string | 否 | `/local/path/thumb.jpg` | 缩略图路径 |
| `foodName` | string | 否 | `Chicken Rice` | 食物名 |
| `confidence` | double | 否 | `0.92` | 识别置信度 |
| `mealType` | string | 否 | `lunch` | 餐次类型 |
| `createdAt` | DateTime / int | 是 | `2026-06-03T12:30:00Z` | 创建时间 |
| `source` | string | 否 | `camera` | 数据来源 |
| `isEdited` | bool | 否 | `true` | 是否被用户编辑过 |

建议枚举：

- `source`: `camera / gallery / sample / manual`

---

## 5. Nutrition

用途：

- 与 Meal 一对一关联的营养数据对象

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `mealId` | string | 是 | `meal_20260603_001` | 对应 Meal ID |
| `calories` | double | 否 | `520` | 热量 |
| `proteinGrams` | double | 否 | `38` | 蛋白质克数 |
| `carbsGrams` | double | 否 | `62` | 碳水克数 |
| `fatGrams` | double | 否 | `12` | 脂肪克数 |
| `fiberGrams` | double | 否 | `5` | 纤维克数 |
| `weightGrams` | double | 否 | `280` | 食物重量 |
| `updatedAt` | DateTime / int | 否 | `2026-06-03T12:31:00Z` | 最后更新时间 |

---

## 6. DailyNutritionSummary

用途：

- Dashboard 当天总览对象

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `date` | string | 是 | `2026-06-03` | 汇总日期 |
| `totalCalories` | double | 否 | `1850` | 今日总热量 |
| `totalProteinGrams` | double | 否 | `132` | 今日总蛋白质 |
| `totalCarbsGrams` | double | 否 | `180` | 今日总碳水 |
| `totalFatGrams` | double | 否 | `52` | 今日总脂肪 |
| `totalFiberGrams` | double | 否 | `18` | 今日总纤维 |
| `mealCount` | int | 是 | `3` | 今日餐次记录数 |
| `goalCalories` | double | 否 | `2400` | 热量目标 |
| `goalProteinGrams` | double | 否 | `160` | 蛋白目标 |
| `goalCarbsGrams` | double | 否 | `220` | 碳水目标 |
| `goalFatGrams` | double | 否 | `70` | 脂肪目标 |
| `lastMealAt` | DateTime / int | 否 | `2026-06-03T19:00:00Z` | 最后一餐时间 |

---

## 7. DashboardViewData

用途：

- 面向 UI 的聚合展示对象
- 用于避免 Dashboard 页面直接拼装多个底层实体

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `summary` | DailyNutritionSummary | 是 | - | 今日汇总 |
| `meals` | List<MealWithNutrition> | 是 | - | 餐次列表 |
| `hasData` | bool | 是 | `true` | 是否存在记录 |
| `remainingCalories` | double | 否 | `550` | 剩余热量 |
| `proteinProgress` | double | 否 | `0.82` | 蛋白目标完成度 |
| `carbsProgress` | double | 否 | `0.81` | 碳水目标完成度 |
| `fatProgress` | double | 否 | `0.74` | 脂肪目标完成度 |

---

## 8. MealWithNutrition

用途：

- Timeline 与 Detail 页面展示用聚合对象

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `meal` | Meal | 是 | - | 主记录 |
| `nutrition` | Nutrition | 是 | - | 营养记录 |
| `displayTitle` | string | 否 | `Chicken Rice` | UI 展示标题 |
| `displaySubtitle` | string | 否 | `Lunch · 520 kcal` | UI 副标题 |

---

## 9. CoachSession

用途：

- 表达一次 Coach 页会话
- 支撑会话时长、消息数、首类目统计

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `sessionId` | string | 是 | `coach_20260603_01` | 会话唯一标识 |
| `startedAt` | DateTime / int | 是 | `2026-06-03T20:00:00Z` | 会话开始时间 |
| `endedAt` | DateTime / int | 否 | `2026-06-03T20:05:12Z` | 会话结束时间 |
| `durationSeconds` | int | 否 | `312` | 会话时长 |
| `source` | string | 否 | `tab` | 页面来源 |
| `messageCount` | int | 否 | `4` | 会话消息数 |
| `firstCategory` | string | 否 | `nutrition` | 首条消息分类 |

---

## 10. CoachMessageEvent

用途：

- 记录用户消息及分类元信息
- 为埋点和后续消息分析提供统一结构

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `sessionId` | string | 是 | `coach_20260603_01` | 对应会话 ID |
| `messageId` | string | 是 | `msg_001` | 消息唯一标识 |
| `messageText` | string | 否 | `How can I sleep better?` | 原始消息 |
| `messageLength` | int | 是 | `24` | 消息长度 |
| `messageLengthBucket` | string | 是 | `20_100` | 长度桶 |
| `category` | string | 是 | `recovery` | 关键词分类 |
| `createdAt` | DateTime / int | 是 | `2026-06-03T20:01:00Z` | 创建时间 |
| `suggestion` | string | 否 | `sleep` | 若由建议卡触发则传值 |
| `tag` | string | 否 | `recovery` | 若由快捷标签触发则传值 |

建议枚举：

- `category`: `workout / nutrition / recovery / mindset / unknown`
- `messageLengthBucket`: `0_20 / 20_100 / 100_plus`

---

## 11. Analytics 公共参数

用途：

- 所有埋点事件默认附带的上下文字段

| 字段名 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| `platform` | string | 是 | `android` | 平台 |
| `appVersion` | string | 是 | `1.0.0+1` | App 版本 |
| `sessionId` | string | 是 | `app_session_001` | 应用会话 ID |
| `userId` | string | 否 | `alex_001` | 用户 ID |
| `timestamp` | int | 是 | `1780000000` | 事件时间戳 |
| `source` | string | 否 | `tab` | 行为入口来源 |

---

## 12. Snapshot 事件参数模型

### SnapshotOpenParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `source` | string | 否 | 打开入口 |

### SnapshotCaptureParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `inputType` | string | 是 | `camera / gallery / sample` |
| `sampleName` | string | 否 | 样本名 |

### SnapshotAnalysisSuccessParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `foodName` | string | 否 | 食物名 |
| `confidence` | double | 否 | 识别置信度 |
| `analysisDurationMs` | int | 是 | 分析耗时 |

### SnapshotAnalysisFailParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `errorCode` | string | 是 | 错误码 |
| `analysisStage` | string | 是 | `capture / segmentation / nutrition / save` |

### SnapshotSaveParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `mealType` | string | 否 | 餐次 |
| `calories` | double | 否 | 保存热量 |
| `saveDurationMs` | int | 否 | 保存耗时 |

---

## 13. Coach 事件参数模型

### CoachOpenParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `source` | string | 否 | 入口来源，建议默认 `tab` |

### CoachChatStartParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `firstMessage` | bool | 是 | 是否首条消息 |

### CoachMessageSendParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `messageLength` | int | 是 | 消息长度 |
| `lengthBucket` | string | 是 | 长度桶 |
| `category` | string | 是 | 本地分类结果 |

### CoachSuggestionClickParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `suggestion` | string | 是 | 建议卡标识 |

### CoachTagClickParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | string | 是 | 标签标识 |

### CoachSessionEndParams

| 字段名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `duration` | int | 是 | 会话时长秒数 |
| `messageCount` | int | 否 | 会话消息数 |

---

## 14. 推荐代码落点

结合当前项目结构，建议后续实现时按以下落点组织：

```text
lib/
├── core/
│   └── analytics/
│       ├── event_names.dart
│       └── event_models.dart
├── models/
│   ├── meal.dart
│   ├── nutrition.dart
│   ├── daily_nutrition_summary.dart
│   └── coach_session.dart
└── features/
    ├── coach/
    └── nutrition/
```

说明：

- `core/analytics/` 适合放跨模块共享事件常量与参数模型。
- `models/` 适合承接未来从 `Map` 向 typed model 的迁移。
- MVP 若暂不引入完整 `models/` 目录，也可先在 feature 内局部落地，再二次抽离。
