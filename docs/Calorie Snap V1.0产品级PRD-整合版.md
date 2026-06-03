# Calorie Snap / Nutrition OS V1.0 产品级 PRD

Version: 1.0

Platform:
Flutter iOS / Android

Product Scope:
Nutrition OS + Food Snapshot + Fake AI Coach Loop

Priority:
P0

---

## 1. 产品定位

Calorie Snap V1.0 不是一个孤立的“拍照识别卡路里”工具，而是整个 `Nutrition OS` 的数据入口模块。

用户通过一次低成本拍照，完成：

```text
Food Snapshot
↓
Foreground Extraction
↓
Nutrition Analysis
↓
Diary / Calendar Log
↓
Nutrition Dashboard
↓
AI Coach / Future You / Progress 联动
```

V1.0 的核心价值不是“堆更多 AI 能力”，而是建立一个高频、低摩擦、可沉淀、可联动的数据闭环：

- 用 `Calorie Snap` 降低饮食记录成本。
- 用 `Nutrition Dashboard` 承接每日营养数据。
- 用 `Fake AI Coach + 完整埋点` 验证用户真正关心的问题与使用频率。
- 为 `Future You`、`MuscleMap`、`Progress` 提供可靠的营养输入数据。

---

## 2. 产品背景

当前 App 已具备：

- Muscle Map
- Workout Plan
- Progress
- Future You
- AI Coach

当前缺口主要有两类：

### 2.1 饮食记录成本过高

- 用户需要手动记录饮食，输入成本高。
- 营养数据长期缺失，无法形成稳定的成长数据资产。
- 训练、恢复、Future You 预测缺乏真实饮食输入。

### 2.2 Coach 方向不明确

- 当前并不缺一个“能回答问题的大模型入口”。
- 真正缺的是对用户需求的验证：用户到底在问什么、最常问什么、问得多频繁。
- 因此 V1 阶段，Coach 的优先级是“埋点验证 + 反馈闭环”，不是直接接入 GPT/Gemini/Claude。

---

## 3. 产品目标

### 3.1 核心业务目标

- 用户完成一次饮食记录时间 `<= 5 秒`
- 食物识别与营养估算感知流程足够快，点击 `ANALYZE` 后核心反馈延迟 `< 300ms`
- 前景提取流程目标耗时 `< 800ms`
- 日记录率提升 `+40%`
- 营养数据覆盖率提升 `+60%`
- 核心识别准确率目标 `>= 85%`

### 3.2 体验目标

- 以高保真、极简、拟纸感视觉呈现产品高级感。
- 核心转场和页面动效保持丝滑、克制、具有质量感。
- 在主流中端设备上稳定运行于 `60fps`，高刷设备尽量达到 `120fps`。

### 3.3 验证目标

- 明确 Coach Tab 是否被真实使用。
- 识别用户最关注的主题分布：`workout / nutrition / recovery / mindset`
- 验证 Food Snapshot 是否能成为日常高频入口，而不是一次性展示功能。

---

## 4. V1.0 核心原则

### 4.1 数据入口优先

Food Snapshot 是整个 Nutrition OS 的数据采集入口，不是单独页面功能。

### 4.2 本地端优先

- 食物主体提取与遮罩生成必须在端侧完成。
- 不允许依赖云端抠图 API。
- 即使未来接入云端营养分析，拍照后的关键视觉反馈依然必须由本地能力驱动。

### 4.3 体验优先于“假智能”

- V1 Coach 不追求复杂大模型能力。
- 先通过高质量 UI、合理的建议入口、Mock Response 和埋点来验证需求。

### 4.4 先闭环，再扩展

V1 只做最小但完整的闭环：

```text
拍照
→ 分析
→ 记录
→ 展示
→ 反馈
→ 埋点验证
```

---

## 5. 用户画像与核心场景

### 5.1 目标用户

- 正在增肌、减脂或重组体型的健身用户
- 已有训练习惯，但饮食记录不稳定的用户
- 需要快速判断“这顿吃得对不对”的用户
- 会查看 Progress / Future You / Coach 建议的成长型用户

### 5.2 核心场景

#### 场景 A：快速记录一餐

用户打开 Nutrition，拍下食物，系统完成主体提取、营养估算，并一键保存到当天日历和日记。

#### 场景 B：查看今天是否吃够

用户进入 Nutrition Dashboard，查看今日热量剩余、蛋白质完成度、餐次分布和每餐详情。

#### 场景 C：拿饮食结果触发 Coach 反馈

用户记录完饮食后，进入 Coach，看到快捷建议或继续提问。系统不依赖真实大模型，先记录问题分布与会话行为。

#### 场景 D：作为未来预测的数据输入

营养数据进入 Future You、MuscleMap 与 Progress 系统，成为训练恢复、趋势判断和未来预测的重要输入。

---

## 6. 核心用户流程

### 6.1 主流程

```text
Home / Nutrition
↓
Food Snapshot
↓
Live Capture
↓
Processing & Extraction
↓
Nutrition Result
↓
Log To Today
↓
Add To Calendar
↓
Nutrition Dashboard
↓
Coach / Future You / Progress 联动
```

### 6.2 Coach 验证流程

```text
Coach Tab
↓
AiCoachScreen
↓
Suggestion / Quick Tag / MessageInput
↓
Event Tracking
↓
Keyword Category Classification
↓
Local Mock Response
↓
Chat UI
```

---

## 7. 信息架构

```text
Nutrition
├── Dashboard
├── Food Snapshot
│   ├── Camera
│   ├── Extraction
│   ├── Analysis
│   └── Result
├── Meal Timeline
├── Meal Detail
├── Weekly Trends
└── Analytics

Coach
├── AiCoachScreen
├── Suggestions
├── Quick Tags
├── Message Input
└── Session Analytics
```

---

## 8. 页面与体验设计

### 8.1 设计语言

### 视觉基调

- 背景色：`#F5F3EF`
- 主文字色：`#1C1C1C`
- 高亮状态色：`#FF6F59`
- 卡片底色：`#FFFFFF`
- 阴影建议：`blurRadius: 20`，黑色不透明度 `3%`

### 动效原则

- 放弃传统线性或普通 `easeOut` 曲线。
- 全量采用弹性物理模拟（Spring Physics）。
- 核心参数对标：`Stiffness = 180`，`Damping Ratio = 0.75`

---

### 8.2 Food Snapshot - Live Capture

### 页面布局

- 顶部状态栏：左侧 `BACK`，中间 `LIVE • CAPTURE` 状态灯，右侧版本号或时间。
- 中部：正方形相机 Viewport，边缘为四个 L 型定位角。
- 底部：可横滑的样本区域 `OR TEST A SAMPLE`，每个 Item 包含缩略图、名称与分量标签。

### 动效要求

- 进入相机或切换样本时，触发快门遮罩开合动画。
- `LIVE` 状态灯需带缓慢呼吸动效。

### 关键价值

- 让拍照行为本身具备仪式感和高级感。
- 样本入口可用于演示、测试和冷启动体验。

---

### 8.3 Processing & Food Extraction

### 状态一：Locating

- 顶部显示 `PROCESSING`
- 底部显示 `LOCATING...`
- 定位框收缩并贴合食物主体边界框

### 状态二：Disintegrating

- 食物主体边缘出现柔和白色高光
- 主体外背景发生像素级消融和解构
- 过渡结束后，背景转为纯白卡片，仅保留食物主体

### 体验目标

- 用户必须清晰感知“系统正在理解食物主体”
- 动效不仅是装饰，而是对 AI 分析过程的可视化解释

---

### 8.4 Nutrition Analysis Result

### 页面内容

- 顶部居中显示抠出的食物主体
- 中部大字号显示热量数值与 `KCAL`
- 底部展示营养素卡片：蛋白质、碳水、脂肪、纤维

### 动效要求

- 卡路里数字从 `0` 滚动到目标值
- 食物图片使用共享元素转场从上一页进入
- 营养卡片以渐入和轻量上移方式出现

### 页面动作

- `LOG TO TODAY`
- `EDIT`
- `RETAKE`

---

### 8.5 Diary / Calendar Integration

### 状态一：Dynamic Island Transition

- 点击 `LOG TO TODAY` 后，分析页向上收缩
- 顶部区域模拟灵动岛拉伸形变并吞入食物图片与关键数据
- 随后从顶部区域吐出一张白色收据卡片

### 状态二：Receipt To Calendar

- 点击 `ADD TO CALENDAR` 后，收据卡片缩小并抛物线下落
- 卡片精准落入当天日历格中
- 日期格闪烁，总卡路里数值无缝递增

### 产品意义

- 把“保存记录”从普通确认动作升级为强反馈行为
- 帮助用户建立“记录已入库”的心理确定性

---

### 8.6 Nutrition Dashboard

### 顶部

- Calories Ring
- Goal / Consumed / Remaining

### 中部

- Macro Completion
- Protein / Carbs / Fat / Fiber

### 底部

- Meal Timeline
- Breakfast / Lunch / Dinner / Snack
- 每餐可进入详情页

### 浮动入口

- `Take Food Snapshot`

---

### 8.7 AI Coach V1

### 产品定位

AI Coach V1 是一个“需求验证器”，不是完整智能问答系统。

### 页面组成

- 建议卡片 Suggestions
- 快捷标签 Quick Tags
- 输入框 MessageInput
- 消息流 Chat UI

### 快捷标签建议

- Workout
- Nutrition
- Recovery
- Mindset

### V1 响应策略

- 用户发出消息后立即记录埋点
- 系统对关键词做基础分类
- 返回本地 Mock Response
- 暂不以真实 LLM 质量作为上线门槛

---

## 9. 功能需求

### 9.1 Snapshot 功能需求

- 支持拍照与相册导入
- 支持样本演示入口
- 支持主体提取与营养分析
- 支持结果页编辑、重拍、保存
- 支持写入当天日记与日历
- 支持 Dashboard 展示今日汇总与历史餐次

### 9.2 Coach 功能需求

- 进入 Coach 页面记录打开事件
- 第一条消息触发会话开始事件
- 支持建议卡片点击
- 支持快捷标签点击
- 支持消息发送时的长度统计
- 支持基于关键词的消息主题分类
- 支持会话开始与结束的时长统计
- 支持本地 Mock Response 返回

### 9.3 跨模块联动需求

- Food Snapshot 保存后更新当天 Nutrition Summary
- Nutrition 数据可被 Future You 读取
- Nutrition 数据可作为 Coach 上下文输入来源
- Workout Day / Rest Day 可影响营养目标推荐

---

## 10. AI 与分析能力定义

### 10.1 Food Snapshot 输入输出

### 输入

- Food Image

### 输出

`FoodRecognitionResult`

```text
foodName
confidence
estimatedWeight
calories
protein
carbs
fat
fiber
ingredients
mealType
```

### 10.2 Coach 分类定义

基于消息关键词做初步分类：

- `workout`
- `nutrition`
- `recovery`
- `mindset`

用于回答：

- 用户最常问什么
- 用户是在搜索，还是在倾诉
- Coach V2 应优先接入什么能力

---

## 11. 数据模型

### 11.1 Meal

```text
id
photoPath
thumbnailPath
foodName
confidence
mealType
createdAt
```

### 11.2 Nutrition

```text
mealId
calories
protein
carbs
fat
fiber
weight
```

### 11.3 DailyNutritionSummary

```text
date
totalCalories
totalProtein
totalCarbs
totalFat
mealCount
```

### 11.4 CoachSession

```text
sessionId
startedAt
endedAt
duration
source
messageCount
firstCategory
```

### 11.5 CoachMessageEvent

```text
messageLength
messageLengthBucket
category
suggestion
tag
createdAt
```

---

## 12. 埋点设计

### 12.1 Snapshot 事件

```text
snapshot_open
snapshot_capture
snapshot_analysis_success
snapshot_analysis_fail
snapshot_save
snapshot_edit
snapshot_delete
nutrition_dashboard_open
```

### 12.2 Coach 事件

```text
coach_open
coach_chat_start
coach_message_send
coach_suggestion_click
coach_tag_click
coach_session_start
coach_session_end
```

### 12.3 Coach 关键参数

### `coach_open`

```json
{
  "source": "tab"
}
```

### `coach_chat_start`

```json
{
  "first_message": true
}
```

### `coach_message_send`

```json
{
  "message_length": 42,
  "length_bucket": "20_100",
  "category": "nutrition"
}
```

### `coach_suggestion_click`

```json
{
  "suggestion": "sleep"
}
```

### `coach_tag_click`

```json
{
  "tag": "nutrition"
}
```

### `coach_session_end`

```json
{
  "duration": 185
}
```

---

## 13. 关键指标

### 13.1 Snapshot 指标

- Snapshot 打开率
- 拍照完成率
- 分析成功率
- 保存率
- 重拍率
- 单次记录完成时长

### 13.2 Nutrition 指标

- 日记录率
- 日均餐次记录数
- 蛋白质目标达成率
- 周活跃营养用户数

### 13.3 Coach 指标

- Coach 打开率
- 首次发言率
- 建议卡点击率
- 平均会话时长
- 消息长度分布
- 类别分布排行榜

---

## 14. 技术方案建议

### 14.1 Flutter 架构

- 采用 Feature First 组织 Nutrition 与 Coach 模块
- 推荐逐步引入 `flutter_riverpod` 做跨页面状态共享
- 数据层与 UI 层保持分离，便于未来替换 AI Provider 与 Analytics Provider

### 14.2 相机与图像处理

- 相机推荐 `camerawesome`，兼顾闪光灯、缩放、对焦能力
- iOS 前景提取可基于 `VisionKit`
- Android 前景提取可基于 `ML Kit Subject Segmentation`
- Flutter 侧通过 `MethodChannel` 暴露统一的前景提取服务

### 14.3 动效与视觉

- 基础转场可使用 `flutter_animate`
- 高级解构效果与发光边缘使用 `CustomPainter + Fragment Shader`
- 关键页面使用 `Hero` 做连续空间转场

### 14.4 数据与埋点

- 本地存储推荐 `isar`
- 埋点能力独立为 `AnalyticsService`
- 事件常量统一维护，业务层不直接耦合具体平台 SDK

### 14.5 Coach V1 技术策略

- 使用本地关键词分类
- 使用 `Map<String, String>` 或等价结构维护 Mock Responses
- 通过 Provider 抽象未来的真实 AI 接入，不在 V1 阶段引入复杂后端依赖

---

## 15. 模块联动关系

### 15.1 与 MuscleMap 联动

- Workout Day：提高蛋白与碳水目标
- Rest Day：降低碳水目标
- 根据训练肌群和恢复阶段提供饮食建议方向

### 15.2 与 Future You 联动

输入维度：

- Training
- Nutrition
- Sleep
- Weight
- Body Fat

输出维度：

- 30 Days
- 90 Days
- 180 Days

### 15.3 与 Coach 联动

- 饮食数据为 Coach 提供可解释上下文
- Coach 用来承接用户对训练、恢复、饮食的即时追问
- V1 先验证需求分布，V2 再决定是否引入真实 LLM

---

## 16. MVP 范围

### 16.1 包含

- Food Snapshot 拍照 / 相册导入
- 前景提取与分析态动效
- 结果页展示热量与营养素
- 保存到日记 / 日历
- Nutrition Dashboard 基础汇总
- Fake AI Coach
- Coach 完整埋点系统
- Nutrition 到 Coach / Future You 的数据联动接口预留

### 16.2 不包含

- 视频识别
- 连续扫描
- 条形码识别
- 语音输入
- 多人食物识别
- 真实 LLM 回答质量优化
- 高复杂云端营养推理编排

---

## 17. 非功能性要求

- 核心高频动画在中端设备上稳定 `60fps`
- 高刷设备尽量达到 `120fps`
- 关键分析反馈需快速出现，避免用户认为页面卡死
- 关键路径允许本地优先降级，不因单个外部能力失败而完全阻塞体验
- 埋点数据结构必须稳定，便于后续更换 Firebase / Mixpanel / PostHog / Amplitude

---

## 18. 上线后验证问题

- Food Snapshot 是否成为 Nutrition 的主入口
- 哪一类页面转化流失最大：拍照、分析、结果、保存
- 用户在 Coach 中最关心的主题是什么
- Nutrition 数据接入后，Coach 使用率是否提升
- 饮食数据是否显著提升 Future You 与 Progress 的使用价值

---

## 19. 版本结论

Calorie Snap V1.0 的本质，是用一条高完成度的拍照记录链路，把 `Nutrition OS`、`Coach`、`Future You` 和 `Progress` 串成一个真正可增长的数据系统。

V1 成功的标准不是“AI 回答看起来有多聪明”，而是：

- 用户是否愿意每天记录饮食
- 系统是否能稳定沉淀营养数据
- 我们是否能知道用户最在意什么
- 这些数据是否开始反向提升整个产品矩阵的价值
