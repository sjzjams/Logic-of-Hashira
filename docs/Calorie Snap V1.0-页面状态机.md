# Calorie Snap V1.0 页面状态机

关联文档：

- [Calorie Snap V1.0产品级PRD-整合版.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0%E4%BA%A7%E5%93%81%E7%BA%A7PRD-%E6%95%B4%E5%90%88%E7%89%88.md)

---

## 1. 目标

本状态机文档用于明确 MVP 阶段关键页面的：

- 页面状态
- 状态切换条件
- 用户动作
- 系统副作用
- 失败恢复路径

目标是避免开发阶段出现：

- 页面状态定义不一致
- 埋点与 UI 触发时机错位
- 失败态没有回退路径

---

## 2. 状态机范围

本次仅覆盖 MVP 主链路页面：

1. Snapshot Live Capture
2. Processing / Extraction
3. Nutrition Result
4. Diary / Calendar Integration
5. Nutrition Dashboard
6. AI Coach V1

---

## 3. 全局状态约束

### 通用页面状态

建议各页面在业务状态外都支持以下通用态：

- `initial`：页面刚创建，尚未加载完成
- `ready`：页面可交互
- `loading`：页面内部存在进行中的异步动作
- `success`：一次关键动作成功完成
- `error`：发生错误，需要恢复动作

### 通用恢复动作

建议所有错误态至少具备以下之一：

- `retry`
- `back`
- `retake`
- `dismiss`

---

## 4. Snapshot Live Capture 状态机

### 页面职责

- 呈现相机实时取景
- 接收拍照、相册导入或样本选择
- 将图片流转到分析链路

### 状态定义

| 状态 | 说明 | 可见 UI |
| --- | --- | --- |
| `idle` | 页面已进入，等待用户输入 | Live 标识、取景框、快门、样本列表 |
| `capturing` | 正在拍照或读取图片 | 快门反馈、轻量 loading |
| `image_ready` | 已获得待分析图片 | 取景图预览或转场占位 |
| `transitioning` | 正在进入 Processing 页面 | 快门遮罩、页面转场 |
| `error` | 拍照或读取失败 | 错误提示、重试、返回 |

### 状态迁移

| 当前状态 | 触发事件 | 下一个状态 | 副作用 |
| --- | --- | --- | --- |
| `idle` | 点击快门 | `capturing` | 上报候选行为，可播放快门动效 |
| `idle` | 选择相册 | `capturing` | 调用图片选择器 |
| `idle` | 点击样本 | `image_ready` | 记录 `snapshot_capture`，`input_type=sample` |
| `capturing` | 获取图片成功 | `image_ready` | 记录 `snapshot_capture` |
| `capturing` | 获取图片失败 | `error` | 展示错误提示 |
| `image_ready` | 开始进入分析 | `transitioning` | 跳转 Processing |
| `transitioning` | 跳转完成 | 结束当前页面状态 | 交由 Processing 接管 |
| `error` | 点击重试 | `idle` | 清理失败上下文 |
| `error` | 点击返回 | 退出页面 | 返回上一级 |

### 退出条件

- 成功将图片交给 Processing 页面
- 用户主动返回

---

## 5. Processing / Extraction 状态机

### 页面职责

- 让用户感知系统正在定位并提取食物主体
- 负责前景提取、分析调用和结果生成

### 状态定义

| 状态 | 说明 | 可见 UI |
| --- | --- | --- |
| `locating` | 定位主体边界 | `PROCESSING`、`LOCATING...`、收缩框 |
| `disintegrating` | 背景消融与主体提取 | 发光边缘、背景溶解特效 |
| `analyzing` | 生成识别与营养结果 | 处理中状态文案 |
| `success` | 数据生成完成 | 准备跳转结果页 |
| `error` | 任一环节失败 | 错误提示、重试、重拍 |

### 状态迁移

| 当前状态 | 触发事件 | 下一个状态 | 副作用 |
| --- | --- | --- | --- |
| `locating` | 主体定位成功 | `disintegrating` | 启动背景消融动效 |
| `locating` | 主体定位失败 | `error` | 记录 `snapshot_analysis_fail`，`analysis_stage=segmentation` |
| `disintegrating` | 提取完成 | `analyzing` | 调用识别与营养分析 |
| `disintegrating` | 提取失败 | `error` | 记录失败事件 |
| `analyzing` | 分析成功 | `success` | 记录 `snapshot_analysis_success` |
| `analyzing` | 分析失败 | `error` | 记录 `snapshot_analysis_fail`，`analysis_stage=nutrition` |
| `error` | 点击重试 | `locating` | 重新发起处理 |
| `error` | 点击重拍 | 退出到 Live Capture | 返回拍照页 |
| `success` | 自动跳转 | 结束当前页面状态 | 进入 Result 页 |

### 退出条件

- 成功进入 Result 页面
- 用户在错误态选择重拍并返回上游

---

## 6. Nutrition Result 状态机

### 页面职责

- 展示识别结果和营养数据
- 允许用户保存、编辑、重拍

### 状态定义

| 状态 | 说明 | 可见 UI |
| --- | --- | --- |
| `displaying` | 正常展示结果 | 食物主体、KCAL、Macro 卡片、操作按钮 |
| `editing` | 用户正在调整结果 | 可编辑字段、确认 / 取消 |
| `saving` | 正在保存到今天记录 | 按钮 loading、禁用重复点击 |
| `saved` | 保存成功 | 准备进入 Calendar / Dashboard 反馈 |
| `error` | 保存或编辑失败 | 错误提示、重试、返回 |

### 状态迁移

| 当前状态 | 触发事件 | 下一个状态 | 副作用 |
| --- | --- | --- | --- |
| `displaying` | 点击 `EDIT` | `editing` | 打开编辑表单 |
| `displaying` | 点击 `RETAKE` | 退出到 Live Capture | 返回拍照页 |
| `displaying` | 点击 `LOG TO TODAY` | `saving` | 发起保存 |
| `editing` | 确认修改 | `displaying` | 记录 `snapshot_edit` |
| `editing` | 取消修改 | `displaying` | 丢弃临时修改 |
| `saving` | 保存成功 | `saved` | 记录 `snapshot_save` |
| `saving` | 保存失败 | `error` | 展示失败提示 |
| `error` | 点击重试保存 | `saving` | 重新发起保存 |
| `error` | 点击返回结果 | `displaying` | 保留当前结果 |
| `saved` | 自动进入下一反馈流程 | 结束当前页面状态 | 交由 Calendar 接管 |

### 关键约束

- `snapshot_save` 只能在入库成功后触发
- `RETAKE` 不得保留脏数据到当前结果会话

---

## 7. Diary / Calendar Integration 状态机

### 页面职责

- 给保存成功提供强反馈
- 把“保存动作”可视化为“已入库”

### 状态定义

| 状态 | 说明 | 可见 UI |
| --- | --- | --- |
| `island_transition` | 顶部区域收纳与吐出收据 | 顶部拉伸、收据卡出现 |
| `receipt_display` | 收据卡已展开，等待用户确认 | 收据卡、`ADD TO CALENDAR` |
| `dropping` | 收据卡缩放并下落到日期格 | 卡片飞入动画 |
| `completed` | 动画完成，日历更新完成 | 日期格闪烁、总热量递增 |
| `error` | 动画或页面状态异常 | 弱提示、直接跳转 Dashboard |

### 状态迁移

| 当前状态 | 触发事件 | 下一个状态 | 副作用 |
| --- | --- | --- | --- |
| `island_transition` | 收据卡展开完成 | `receipt_display` | 等待下一步操作 |
| `receipt_display` | 点击 `ADD TO CALENDAR` | `dropping` | 计算目标格位置并开始动画 |
| `dropping` | 动画完成 | `completed` | 更新日历视觉状态 |
| `dropping` | 动画失败 | `error` | 降级为直接进入 Dashboard |
| `error` | 点击继续 | 结束当前页面状态 | 进入 Dashboard |
| `completed` | 自动跳转 | 结束当前页面状态 | 进入 Dashboard |

### MVP 降级策略

- 若复杂 Overlay 或精准坐标尚未完成，MVP 允许退化为“保存成功 Toast + Dashboard 跳转”
- 但状态命名仍保持一致，避免未来重构成本

---

## 8. Nutrition Dashboard 状态机

### 页面职责

- 展示今日摄入总览
- 承接 Snapshot 保存后的结果查看
- 提供下一次 Snapshot 入口

### 状态定义

| 状态 | 说明 | 可见 UI |
| --- | --- | --- |
| `empty` | 当天没有 Meal 数据 | 空态说明、CTA |
| `loading` | 正在拉取今日汇总 | 骨架屏或 loading |
| `populated` | 有数据可展示 | Ring、Macros、Timeline |
| `refreshing` | 新数据写入后刷新 | 轻量过渡反馈 |
| `error` | 数据加载失败 | 错误提示、重试 |

### 状态迁移

| 当前状态 | 触发事件 | 下一个状态 | 副作用 |
| --- | --- | --- | --- |
| `loading` | 加载成功且无数据 | `empty` | 记录 `nutrition_dashboard_open`，`has_data=false` |
| `loading` | 加载成功且有数据 | `populated` | 记录 `nutrition_dashboard_open`，`has_data=true` |
| `loading` | 加载失败 | `error` | 展示错误提示 |
| `empty` | 点击 `Take Food Snapshot` | 退出到 Snapshot | 进入拍照页 |
| `populated` | 新 Meal 保存完成 | `refreshing` | 重新计算今日汇总 |
| `refreshing` | 刷新成功 | `populated` | UI 数字更新 |
| `refreshing` | 刷新失败 | `error` | 展示弱失败提示 |
| `error` | 点击重试 | `loading` | 重新拉取 |

### 关键约束

- Dashboard 是 Snapshot 保存后的默认承接页之一
- 空态与有数据态都必须可进入 Snapshot

---

## 9. AI Coach V1 状态机

### 页面职责

- 承接建议卡、标签点击和自由输入
- 对消息进行分类并返回本地 Mock Response
- 记录完整会话与消息行为

### 状态定义

| 状态 | 说明 | 可见 UI |
| --- | --- | --- |
| `initial` | 页面刚进入，会话尚未开始 | 建议卡、标签、输入框 |
| `idle` | 页面可交互但当前无发送中消息 | 消息流、建议卡、输入框 |
| `classifying` | 正在做本地关键词分类 | 发送态反馈 |
| `responding` | 正在生成或显示 Mock Response | 打字中或占位反馈 |
| `active` | 会话正常进行中 | 消息流更新后稳定状态 |
| `error` | 分类或响应异常 | 错误提示、重试、重新输入 |
| `closed` | 页面离开 | 会话结束 |

### 状态迁移

| 当前状态 | 触发事件 | 下一个状态 | 副作用 |
| --- | --- | --- | --- |
| `initial` | 页面进入完成 | `idle` | 记录 `coach_open`，可触发 `coach_session_start` |
| `idle` | 点击建议卡 | `active` | 记录 `coach_suggestion_click` |
| `idle` | 点击标签 | `active` | 记录 `coach_tag_click` |
| `idle` | 发送首条消息 | `classifying` | 记录 `coach_chat_start`、`coach_message_send` |
| `active` | 发送新消息 | `classifying` | 记录 `coach_message_send` |
| `classifying` | 分类成功 | `responding` | 选择对应 Mock Response |
| `classifying` | 分类失败 | `error` | 使用默认分类或提示失败 |
| `responding` | 返回成功 | `active` | 将 Mock Response 插入消息流 |
| `responding` | 返回失败 | `error` | 展示可恢复提示 |
| `error` | 点击重试 | `classifying` 或 `idle` | 视是否保留输入内容而定 |
| `idle` | 页面离开 | `closed` | 记录 `coach_session_end` |
| `active` | 页面离开 | `closed` | 记录 `coach_session_end` |
| `error` | 页面离开 | `closed` | 记录 `coach_session_end` |

### 关键约束

- `coach_chat_start` 仅首条消息触发一次
- `coach_message_send` 必须带 `message_length / length_bucket / category`
- 页面离开时必须尝试发送 `coach_session_end`

---

## 10. 页面间主状态流转

```text
Dashboard.empty / Dashboard.populated
→ Snapshot.LiveCapture.idle
→ Snapshot.LiveCapture.image_ready
→ Processing.locating
→ Processing.disintegrating
→ Processing.analyzing
→ Result.displaying
→ Result.saving
→ Calendar.receipt_display
→ Calendar.completed
→ Dashboard.refreshing / Dashboard.populated
```

Coach 独立流转：

```text
Coach.initial
→ Coach.idle
→ Coach.classifying
→ Coach.responding
→ Coach.active
→ Coach.closed
```

---

## 11. 失败态与恢复策略

| 页面 | 失败态 | 必备恢复动作 |
| --- | --- | --- |
| Live Capture | 相机不可用、选图失败 | `retry`, `back` |
| Processing | 主体提取失败、分析失败 | `retry`, `retake` |
| Result | 保存失败、编辑失败 | `retry`, `back` |
| Calendar | 动画异常、页面状态不同步 | `continue`, `dashboard` |
| Dashboard | 数据拉取失败 | `retry` |
| Coach | 分类失败、Mock Response 失败 | `retry`, `edit_message`, `back` |

---

## 12. 开发建议

- 先实现“业务状态正确”，再逐步补视觉细节。
- 页面状态建议用显式枚举，不要只靠布尔变量组合。
- 埋点触发应绑定状态迁移成功点，而不是按钮点击瞬间。
- 所有页面的 `error` 态都要能回到一个稳定态，不能卡死在中间状态。
