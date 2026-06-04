# Calorie Snap V1.0 开发排期看板

关联文档：

- [Calorie Snap V1.0产品级PRD-整合版.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0%E4%BA%A7%E5%93%81%E7%BA%A7PRD-%E6%95%B4%E5%90%88%E7%89%88.md)
- [Calorie Snap V1.0-MVP开发任务清单.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0-MVP%E5%BC%80%E5%8F%91%E4%BB%BB%E5%8A%A1%E6%B8%85%E5%8D%95.md)
- [Calorie Snap V1.0-页面状态机.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0-%E9%A1%B5%E9%9D%A2%E7%8A%B6%E6%80%81%E6%9C%BA.md)

---

## 1. 目标

本看板把 MVP 任务按执行角色重新编排为四条主线：

- Flutter 前端
- 原生能力
- 数据 / 存储
- 埋点 / 分析

适合用于：

- 实际排期
- 每周推进会
- 风险跟踪
- 并行开发分工

---

## 2. 建议节奏

建议按 5 个 Sprint 或 5 个迭代包推进：

| Sprint | 目标 | 结果 |
| --- | --- | --- |
| `Sprint 1` | 骨架、模型、埋点底座 | 可进入 Nutrition / Coach，事件常量明确 |
| `Sprint 2` | Snapshot 主链路 | 可拍照 / 选图 / 进入结果页 |
| `Sprint 3` | 保存与 Dashboard | 可写入当天记录并展示汇总 |
| `Sprint 4` | Coach V1 闭环 | 可发消息、分类、返回 Mock Response |
| `Sprint 5` | 联调与验收 | 状态机稳定、埋点口径稳定、可完整演示 |

---

## 3. 按主线拆解

## 3.1 Flutter 前端主线

| 编号 | 任务 | Sprint | 优先级 | 前置依赖 | 交付标准 |
| --- | --- | --- | --- | --- | --- |
| FE-01 | Nutrition / Coach 页面路由与入口整理 | Sprint 1 | P0 | 无 | 能进入 Dashboard、Snapshot、Coach |
| FE-02 | Live Capture 页面骨架 | Sprint 2 | P0 | FE-01 | 可展示取景区、快门区、样本区 |
| FE-03 | Processing 页面状态 UI | Sprint 2 | P0 | FE-02 | 可展示 Locating / Disintegrating / Error |
| FE-04 | Result 页面 UI 与动作按钮 | Sprint 2 | P0 | FE-03 | 可展示食物主体、KCAL、Macro、按钮 |
| FE-05 | Diary / Calendar 反馈基础版 | Sprint 3 | P1 | FE-04 | 保存后有明确成功反馈 |
| FE-06 | Dashboard 基础页 | Sprint 3 | P0 | DATA-03 | 能展示 summary 和 timeline |
| FE-07 | Meal Detail 基础页 | Sprint 3 | P1 | FE-06 | 可查看单条 Meal |
| FE-08 | Coach 页面 UI | Sprint 4 | P0 | FE-01 | Suggestions / Tags / Input / Chat 可用 |
| FE-09 | Snapshot 错误态和空态补齐 | Sprint 5 | P0 | FE-02~FE-04 | 每个关键状态都有恢复路径 |
| FE-10 | Coach 错误态和空态补齐 | Sprint 5 | P0 | FE-08 | 分类失败、空回复可恢复 |

## 3.2 原生能力主线

| 编号 | 任务 | Sprint | 优先级 | 前置依赖 | 交付标准 |
| --- | --- | --- | --- | --- | --- |
| NA-01 | 相机能力选型与接入 | Sprint 1 | P0 | 无 | Flutter 层能调用拍照 |
| NA-02 | 相册导入能力接入 | Sprint 2 | P0 | NA-01 | 可从相册选择图片 |
| NA-03 | iOS 前景提取接口封装 | Sprint 2 | P0 | NA-01 | 提供统一返回结构 |
| NA-04 | Android 前景提取接口封装 | Sprint 2 | P0 | NA-01 | 提供统一返回结构 |
| NA-05 | Flutter MethodChannel 统一层 | Sprint 2 | P0 | NA-03, NA-04 | Flutter 侧只有单一调用入口 |
| NA-06 | 前景提取失败回退机制 | Sprint 5 | P0 | NA-05 | 失败时可回退或走 Mock 路径 |

## 3.3 数据 / 存储主线

| 编号 | 任务 | Sprint | 优先级 | 前置依赖 | 交付标准 |
| --- | --- | --- | --- | --- | --- |
| DATA-01 | 定义 Meal / Nutrition / Summary / CoachSession / CoachMessageEvent 模型 | Sprint 1 | P0 | 无 | 字段与接口清单一致 |
| DATA-02 | 本地存储方案接入 | Sprint 1 | P0 | DATA-01 | 可读写 Meal / Nutrition |
| DATA-03 | 保存 Meal -> Nutrition -> Summary 更新链路 | Sprint 3 | P0 | DATA-02, FE-04 | 保存一次后 Dashboard 可见变化 |
| DATA-04 | Dashboard 查询聚合层 | Sprint 3 | P0 | DATA-03 | UI 可读 summary + meals |
| DATA-05 | Coach Session 与 Message 记录结构 | Sprint 4 | P1 | DATA-01 | 可记录会话元信息 |
| DATA-06 | Nutrition 对 Coach / Future You 的读取接口预留 | Sprint 5 | P1 | DATA-04 | 可对外获取 summary 或最近 meals |

## 3.4 埋点 / 分析主线

| 编号 | 任务 | Sprint | 优先级 | 前置依赖 | 交付标准 |
| --- | --- | --- | --- | --- | --- |
| AN-01 | 事件常量与参数模型落地 | Sprint 1 | P0 | 无 | `event_names.dart` 与参数模型可用 |
| AN-02 | AnalyticsService 骨架 | Sprint 1 | P0 | AN-01 | 可统一 track 事件 |
| AN-03 | Snapshot 事件接入 | Sprint 2 | P0 | AN-02, FE-02~FE-04 | 打通 open / capture / analysis 成败 |
| AN-04 | Save / Dashboard 事件接入 | Sprint 3 | P0 | AN-02, DATA-03 | 打通 save / dashboard_open |
| AN-05 | Coach 事件接入 | Sprint 4 | P0 | AN-02, FE-08 | 打通 open / chat_start / message_send / suggestion / tag / session_end |
| AN-06 | 指标口径校验 | Sprint 5 | P0 | AN-03~AN-05 | 事件参数完整，能支持看板计算 |

---

## 4. 推荐并行方式

### Sprint 1 并行

- 前端：做页面入口与骨架
- 数据：做核心模型
- 埋点：做事件常量和 AnalyticsService

### Sprint 2 并行

- 前端：做 Snapshot 页面与状态流
- 原生：做相机与前景提取接口
- 埋点：同步接入 Snapshot 事件

### Sprint 3 并行

- 数据：做保存链路与汇总逻辑
- 前端：做 Dashboard 与保存反馈
- 埋点：接入 save / dashboard 事件

### Sprint 4 并行

- 前端：做 Coach UI
- 数据：做会话和消息结构
- 埋点：做 Coach 事件

### Sprint 5 并行

- 全线联调
- 修状态机错误路径
- 校验埋点与指标口径

---

## 5. 关键依赖图

```text
AN-01 -> AN-02 -> AN-03 -> AN-04 -> AN-05 -> AN-06
DATA-01 -> DATA-02 -> DATA-03 -> DATA-04 -> DATA-06
FE-01 -> FE-02 -> FE-03 -> FE-04 -> FE-06
NA-01 -> NA-02
NA-01 -> NA-03 -> NA-05
NA-01 -> NA-04 -> NA-05
FE-08 -> Coach 闭环
DATA-05 -> Coach 会话沉淀
```

---

## 6. 每周推进检查项

### 产品检查

- 本周是否打通了一个完整用户动作闭环
- 是否有非 MVP 内容混入开发
- 页面状态机是否与交付一致

### 开发检查

- 每条主线是否存在阻塞项
- 模型字段是否与文档一致
- 埋点是否先于或同步于功能接入

### 验证检查

- 当前版本是否可演示
- 失败态是否可恢复
- 埋点日志是否可观察

---

## 7. 主要风险

| 风险 | 影响 | 缓解方案 |
| --- | --- | --- |
| 原生前景提取接入慢 | Snapshot 主链路延后 | Sprint 2 先用 Mock segmentation 打通 UI |
| 结果数据结构反复变动 | Dashboard / 埋点口径漂移 | 先锁字段清单，再落模型 |
| Coach 方案与现有 Firebase 聊天冲突 | 改动范围失控 | V1 草案先独立，不直接替换当前实现 |
| 动效实现成本过高 | Sprint 拖延 | MVP 先保证状态正确，复杂特效后补 |
| 埋点口径不统一 | 后续数据不可用 | Sprint 1 固化事件名与参数模型 |

---

## 8. MVP 出包门槛

- Snapshot 主链路可端到端完成一次记录
- Dashboard 可看到数据变化
- Coach 可完成一次提问和本地回复
- 关键事件都有日志或测试环境验证
- 页面状态机中的错误态至少有一个恢复路径
- 不包含 PRD 中明确排除的非 MVP 能力
