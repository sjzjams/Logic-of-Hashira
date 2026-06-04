# Calorie Snap V1.0 MVP 开发任务清单

关联文档：

- [Calorie Snap V1.0产品级PRD-整合版.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0%E4%BA%A7%E5%93%81%E7%BA%A7PRD-%E6%95%B4%E5%90%88%E7%89%88.md)

---

## 1. 目标

本清单用于把整合版 PRD 收敛为可执行的 MVP 开发计划，目标是优先打通以下闭环：

```text
拍照 / 选图
→ 主体提取 / 分析反馈
→ 结果展示
→ 保存到 Diary / Calendar
→ Dashboard 展示
→ Coach V1 埋点与 Mock Response
```

原则：

- 先打通主链路，再补高阶动效。
- 先保证数据入库与埋点稳定，再扩展算法和 AI 能力。
- 所有任务都围绕 V1 MVP，严格排除 PRD 中标注的非 MVP 项。

---

## 2. 里程碑

### M1：基础骨架可运行

- Nutrition 模块页面路由打通
- Snapshot 基础页面可进入
- Coach V1 页面可进入
- AnalyticsService 骨架可用

### M2：Snapshot 主链路打通

- 拍照 / 选图可获得图片
- 分析态与结果页可跑通
- 基础 Meal / Nutrition 数据可保存

### M3：日志与 Dashboard 打通

- 结果页保存后可进入当天记录
- Dashboard 可看到当天汇总与餐次
- 关键 Snapshot 埋点完整

### M4：Coach V1 验证闭环打通

- Coach 建议卡、标签、输入发送全部可用
- 本地分类与 Mock Response 可返回
- 会话级埋点与消息级埋点完整

### M5：MVP 验收

- 核心状态机闭环无阻断
- 埋点字段稳定
- 关键路径可演示、可验证、可追踪

---

## 3. 任务拆解总览

| 编号 | 模块 | 任务 | 优先级 | 依赖 |
| --- | --- | --- | --- | --- |
| T01 | Foundation | Nutrition / Coach 模块路由与目录骨架 | P0 | 无 |
| T02 | Foundation | 数据模型定义：Meal / Nutrition / DailyNutritionSummary / CoachSession / CoachMessageEvent | P0 | T01 |
| T03 | Foundation | 本地存储方案接入与 Repository 骨架 | P0 | T02 |
| T04 | Foundation | `AnalyticsService`、事件常量、参数模型 | P0 | T01 |
| T05 | Snapshot | Live Capture 页面 UI 骨架 | P0 | T01 |
| T06 | Snapshot | 拍照 / 相册导入能力接入 | P0 | T05 |
| T07 | Snapshot | 样本演示入口接入 | P1 | T05 |
| T08 | Snapshot | Processing / Extraction 页面与状态切换 | P0 | T06 |
| T09 | Snapshot | 本地前景提取服务接口封装 | P0 | T08 |
| T10 | Snapshot | 营养分析结果模型与假数据 / Provider 流程 | P0 | T08 |
| T11 | Snapshot | 结果页 UI 与 Hero / 数字滚动基础动效 | P0 | T10 |
| T12 | Diary | `LOG TO TODAY` 保存链路 | P0 | T11, T03 |
| T13 | Diary | Calendar 收据卡落入动画基础版 | P1 | T12 |
| T14 | Dashboard | Dashboard 汇总与 Meal Timeline | P0 | T12 |
| T15 | Dashboard | Meal Detail 页面基础信息展示 | P1 | T14 |
| T16 | Coach | Coach 页面 UI：Suggestions / Tags / Input / Chat | P0 | T01 |
| T17 | Coach | 本地关键词分类器 | P0 | T16 |
| T18 | Coach | Mock Response Provider | P0 | T17 |
| T19 | Coach | 会话开始 / 结束 / 发送消息埋点 | P0 | T04, T16 |
| T20 | Coach | Suggestion / Tag 点击埋点 | P0 | T04, T16 |
| T21 | Integration | Nutrition 到 Coach / Future You 的数据接口预留 | P1 | T12, T18 |
| T22 | Quality | 页面状态兜底、错误恢复与空态处理 | P0 | T11, T14, T18 |
| T23 | Quality | 埋点校验与指标核对 | P0 | T19, T20 |
| T24 | Quality | MVP 联调验收与演示脚本 | P0 | 全部主链路 |

---

## 4. 分阶段任务清单

### 阶段 A：Foundation

#### T01. Nutrition / Coach 模块路由与目录骨架

目标：

- 建立 `nutrition` 与 `coach` 的 Feature First 目录结构
- 打通从主入口到 Nutrition、Snapshot、Coach 的访问路径

交付物：

- 页面入口文件
- 路由配置
- 模块目录结构

验收标准：

- 可以从 App 入口进入 Nutrition Dashboard、Snapshot、Coach 页面
- 页面可先使用占位内容，但路由不可断

#### T02. 数据模型定义

目标：

- 建立 MVP 所需核心数据模型

范围：

- `Meal`
- `Nutrition`
- `DailyNutritionSummary`
- `CoachSession`
- `CoachMessageEvent`

验收标准：

- 模型字段与整合版 PRD 一致
- 字段命名可直接支持后续埋点与本地存储

#### T03. 本地存储与 Repository 骨架

目标：

- 为 Nutrition 和 Coach 的本地数据沉淀提供统一入口

验收标准：

- 可保存 Meal 和 Nutrition
- 可更新 DailyNutritionSummary
- Coach 会话和消息事件可本地记录或缓存

#### T04. 埋点服务骨架

目标：

- 统一封装 Analytics 调用，避免业务层直接依赖具体平台 SDK

范围：

- `AnalyticsService`
- `AnalyticsEvent`
- 参数模型或参数构建器

验收标准：

- Snapshot 和 Coach 事件均有统一出口
- 开发阶段可先使用日志打印验证

---

### 阶段 B：Snapshot 主链路

#### T05. Live Capture 页面 UI 骨架

目标：

- 落地 `LIVE • CAPTURE` 页面结构

范围：

- 顶部状态栏
- 中央 Viewport
- 底部快门区
- 样本入口区

验收标准：

- 页面布局接近 PRD
- 支持 Idle 状态渲染

#### T06. 拍照 / 相册导入能力接入

目标：

- 让用户可以从相机或相册获得待分析图片

验收标准：

- 拍照成功后可进入分析流程
- 相册导入成功后可进入分析流程
- 失败时有可恢复提示

#### T07. 样本演示入口接入

目标：

- 为演示和调试提供样本图片选择能力

验收标准：

- 选择样本后与真实拍照走相同处理流程

#### T08. Processing / Extraction 状态切换

目标：

- 建立 `Locating` 与 `Disintegrating` 的基础状态机

验收标准：

- 进入分析后可看到明确状态反馈
- 失败时可回退到拍照页或重试

#### T09. 本地前景提取服务接口封装

目标：

- 屏蔽 iOS / Android 差异，暴露统一的前景提取入口

验收标准：

- Flutter 层只有一个统一调用接口
- 若原生能力暂未完成，可先提供 Mock 实现占位

#### T10. 营养分析结果模型与 Provider 流程

目标：

- 把图片输入转成结果页可消费的数据结构

验收标准：

- 至少能稳定产出 `foodName / calories / macros / confidence`
- 结果页可在无真实云端模型的情况下完成演示

#### T11. 结果页 UI 与基础动效

目标：

- 落地 Result 页面核心信息和关键视觉反馈

范围：

- Hero 食物主体
- 热量数字
- Macro 卡片
- `LOG TO TODAY / EDIT / RETAKE`

验收标准：

- 页面信息完整
- 支持重拍和返回分析结果

---

### 阶段 C：Diary / Dashboard

#### T12. `LOG TO TODAY` 保存链路

目标：

- 将结果页数据写入 Meal / Nutrition / DailyNutritionSummary

验收标准：

- 保存成功后可确认入库
- 当天汇总被正确更新

#### T13. Calendar 收据卡动画基础版

目标：

- 实现从结果页到 Calendar 的基础保存反馈

说明：

- MVP 先实现“可感知的保存完成反馈”
- 高级 3D 透视和精细轨迹可延后迭代

验收标准：

- 用户保存后能明确看到成功反馈
- 页面状态与数据状态一致

#### T14. Dashboard 汇总与 Timeline

目标：

- 展示今日营养总览和餐次列表

范围：

- Goal / Consumed / Remaining
- Protein / Carbs / Fat / Fiber
- Meal Timeline

验收标准：

- 保存一条 Meal 后，Dashboard 可见变化
- 空态和有数据态均可显示

#### T15. Meal Detail 基础页

目标：

- 展示单条餐次的原图、识别结果、营养信息和时间

验收标准：

- 可从 Timeline 进入详情页

---

### 阶段 D：Coach V1

#### T16. Coach 页面 UI

目标：

- 落地 Coach V1 的基础聊天与建议界面

范围：

- Suggestions
- Quick Tags
- Message Input
- Chat UI

验收标准：

- 页面可正常进入
- 可点击建议与标签
- 可发送消息

#### T17. 本地关键词分类器

目标：

- 对用户消息做基础分类

分类：

- `workout`
- `nutrition`
- `recovery`
- `mindset`

验收标准：

- 对典型关键词可稳定分类
- 无命中时有默认分类策略

#### T18. Mock Response Provider

目标：

- 基于消息分类返回本地占位回复

验收标准：

- 用户发送消息后可快速看到响应
- 响应内容可按分类扩展

#### T19. 会话与发送消息埋点

目标：

- 打通 `coach_open / coach_chat_start / coach_message_send / coach_session_start / coach_session_end`

验收标准：

- 第一条消息会触发会话开始
- 页面离开会触发会话结束并记录时长

#### T20. Suggestion / Tag 点击埋点

目标：

- 打通 `coach_suggestion_click / coach_tag_click`

验收标准：

- 参数字段稳定
- 点击后日志或测试环境可验证

---

### 阶段 E：联动与质量

#### T21. Nutrition 到 Coach / Future You 的接口预留

目标：

- 预留 Nutrition 数据对外读取能力

验收标准：

- Coach 和 Future You 后续可以读取 Nutrition Summary 或最近 Meal 数据

#### T22. 页面状态兜底与错误恢复

目标：

- 为所有核心状态增加最小恢复路径

范围：

- 相机失败
- 分析失败
- 保存失败
- Coach 空响应

验收标准：

- 每个失败态都有明确恢复动作：`重试 / 重拍 / 返回 / 关闭`

#### T23. 埋点校验与指标核对

目标：

- 确保事件、参数、指标口径一致

验收标准：

- 埋点事件名与 PRD、埋点表一致
- 指标计算所需字段无缺失

#### T24. MVP 联调验收与演示脚本

目标：

- 形成完整演示路径，支持产品验收与后续开发交接

验收标准：

- 可完成从拍照到 Dashboard 再到 Coach 的端到端演示

---

## 5. 推荐开发顺序

### P0 必做顺序

1. T01-T04：骨架、模型、存储、埋点服务
2. T05-T11：Snapshot 获取图片、分析态、结果页
3. T12-T14：保存、Dashboard、基础展示
4. T16-T20：Coach V1 与核心埋点
5. T22-T24：状态兜底、埋点校验、联调验收

### P1 可后补

- T07：样本演示入口优化
- T13：Calendar 动效增强
- T15：Meal Detail 深化
- T21：跨模块对外接口优化

---

## 6. MVP 验收清单

- 用户可以通过拍照或相册导入完成一次食物记录
- 系统可以展示分析态、结果页和保存反馈
- 保存后 Dashboard 可看到当天数据变化
- Coach 页面可以发送消息并返回本地 Mock Response
- Coach 与 Snapshot 关键埋点完整可验证
- 失败态均有恢复路径
- 非 MVP 项未混入当前开发范围

---

## 7. 明确不做

- 真实大模型接入与 Prompt 优化
- 视频识别与连续扫描
- 条形码识别
- 语音输入
- 多食物多人场景
- 高复杂 3D / Shader 效果的完整精修版

---

## 8. 建议交付顺序

建议以 5 个 PR 或 5 个迭代包推进：

1. Foundation + Analytics 骨架
2. Snapshot 主链路
3. Diary + Dashboard
4. Coach V1 + 埋点
5. 联调、状态机修正与验收
