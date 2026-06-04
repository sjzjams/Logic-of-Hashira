# Calorie Snap V1.0 埋点表

关联文档：

- [Calorie Snap V1.0产品级PRD-整合版.md](file:///d:/Logic-of-Hashira/docs/Calorie%20Snap%20V1.0%E4%BA%A7%E5%93%81%E7%BA%A7PRD-%E6%95%B4%E5%90%88%E7%89%88.md)

---

## 1. 目标

本埋点表用于统一 Calorie Snap V1.0 与 Coach V1 的事件定义、参数契约、触发时机和指标用途，确保：

- 开发接入口径一致
- 产品看板可以直接消费
- 后续替换 Firebase / Mixpanel / PostHog / Amplitude 时不改业务语义

---

## 2. 通用规则

### 事件命名规则

- 全部使用小写下划线命名
- 事件名表达“动作结果”或“关键行为”
- 同一语义不重复造词

### 通用公共参数

建议所有事件默认附带以下公共字段：

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `platform` | string | 是 | `ios` / `android` |
| `app_version` | string | 是 | 当前 App 版本 |
| `session_id` | string | 是 | 当前应用会话 ID |
| `user_id` | string | 否 | 已登录时传递 |
| `timestamp` | int | 是 | 事件触发时间戳 |
| `source` | string | 否 | 事件入口来源 |

### 参数设计原则

- 只传对指标计算有价值的字段
- 同一含义只保留一个命名
- 枚举值尽量稳定，避免上线后频繁修改

---

## 3. Snapshot 埋点表

| 事件名 | 模块 | 触发时机 | 页面 | 核心参数 | 指标用途 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `snapshot_open` | Snapshot | 用户进入 Food Snapshot 页面时 | Live Capture | `source` | Snapshot 打开率 | `source` 例：`dashboard_cta` / `home` |
| `snapshot_capture` | Snapshot | 用户完成拍照或选择相册图片后 | Live Capture | `input_type`, `sample_name` | 拍照完成率、图片来源分布 | `input_type`：`camera` / `gallery` / `sample` |
| `snapshot_analysis_success` | Snapshot | 分析成功并进入结果页 | Processing / Result | `food_name`, `confidence`, `analysis_duration_ms` | 分析成功率、分析耗时 | `food_name` 可为空字符串以兼容未知识别 |
| `snapshot_analysis_fail` | Snapshot | 分析失败时 | Processing | `error_code`, `analysis_stage` | 分析失败率、失败原因分布 | `analysis_stage`：`capture` / `segmentation` / `nutrition` |
| `snapshot_save` | Snapshot | 用户成功保存 Meal 到当天记录 | Result / Calendar | `meal_type`, `calories`, `save_duration_ms` | 保存率、记录耗时 | 保存成功后才发送 |
| `snapshot_edit` | Snapshot | 用户在结果页点击编辑并确认修改时 | Result | `edited_fields` | 编辑率、字段修正分布 | `edited_fields` 例：`calories,meal_type` |
| `snapshot_delete` | Snapshot | 用户删除一条 Meal 记录时 | Meal Detail | `meal_id`, `meal_type` | 删除率、异常记录判断 | 仅删除成功后发送 |
| `nutrition_dashboard_open` | Nutrition | 用户进入 Dashboard 页面时 | Dashboard | `source`, `has_data` | Dashboard 打开率、空态占比 | `has_data`：`true` / `false` |

### Snapshot 事件参数说明

| 参数名 | 类型 | 适用事件 | 必填 | 说明 |
| --- | --- | --- | --- | --- |
| `input_type` | string | `snapshot_capture` | 是 | `camera` / `gallery` / `sample` |
| `sample_name` | string | `snapshot_capture` | 否 | 使用样本时传递 |
| `food_name` | string | `snapshot_analysis_success` | 否 | 识别出的食物名 |
| `confidence` | number | `snapshot_analysis_success` | 否 | 识别置信度 |
| `analysis_duration_ms` | int | `snapshot_analysis_success` | 是 | 分析耗时 |
| `error_code` | string | `snapshot_analysis_fail` | 是 | 失败错误码 |
| `analysis_stage` | string | `snapshot_analysis_fail` | 是 | 失败阶段 |
| `meal_type` | string | `snapshot_save`, `snapshot_delete` | 否 | `breakfast` / `lunch` / `dinner` / `snack` |
| `calories` | number | `snapshot_save` | 否 | 最终保存热量 |
| `save_duration_ms` | int | `snapshot_save` | 否 | 从结果页点击保存到成功完成耗时 |
| `edited_fields` | string | `snapshot_edit` | 否 | 逗号分隔字段列表 |
| `meal_id` | string | `snapshot_delete` | 是 | 被删除记录的唯一 ID |
| `has_data` | bool | `nutrition_dashboard_open` | 是 | Dashboard 是否已有记录 |

---

## 4. Coach 埋点表

| 事件名 | 模块 | 触发时机 | 页面 | 核心参数 | 指标用途 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `coach_open` | Coach | 用户进入 Coach 页面时 | AiCoachScreen | `source` | Coach 打开率 | `source` 建议默认 `tab` |
| `coach_chat_start` | Coach | 当前页面的第一条消息发送时 | AiCoachScreen | `first_message` | 首次发言率 | 仅会话首条发送一次 |
| `coach_message_send` | Coach | 用户点击发送并消息入队后 | AiCoachScreen | `message_length`, `length_bucket`, `category` | 消息量、长度分布、主题分布 | 分类在本地完成后再发送 |
| `coach_suggestion_click` | Coach | 用户点击建议卡时 | AiCoachScreen | `suggestion` | 建议卡点击率、兴趣方向 | 点击后再决定是否自动发问 |
| `coach_tag_click` | Coach | 用户点击快捷标签时 | AiCoachScreen | `tag` | 标签点击率、主题偏好 | `tag` 应与分类枚举对齐 |
| `coach_session_start` | Coach | 页面进入并开始有效会话时 | AiCoachScreen | `source` | 会话数统计 | 建议在进入页面或首个交互时触发，产品口径需固定 |
| `coach_session_end` | Coach | 页面离开或会话结束时 | AiCoachScreen | `duration`, `message_count` | 平均会话时长、活跃度 | 与 `coach_session_start` 成对出现 |

### Coach 事件参数说明

| 参数名 | 类型 | 适用事件 | 必填 | 说明 |
| --- | --- | --- | --- | --- |
| `first_message` | bool | `coach_chat_start` | 是 | 是否会话首条消息 |
| `message_length` | int | `coach_message_send` | 是 | 原始字符长度 |
| `length_bucket` | string | `coach_message_send` | 是 | `0_20` / `20_100` / `100_plus` |
| `category` | string | `coach_message_send` | 是 | `workout` / `nutrition` / `recovery` / `mindset` / `unknown` |
| `suggestion` | string | `coach_suggestion_click` | 是 | 具体建议标识，例如 `sleep` |
| `tag` | string | `coach_tag_click` | 是 | `workout` / `nutrition` / `recovery` / `mindset` |
| `duration` | int | `coach_session_end` | 是 | 会话持续秒数 |
| `message_count` | int | `coach_session_end` | 否 | 本次会话消息数 |

---

## 5. 指标映射关系

### Snapshot 指标

| 指标 | 计算方式 | 依赖事件 |
| --- | --- | --- |
| Snapshot 打开率 | `snapshot_open / 页面曝光用户数` | `snapshot_open` |
| 拍照完成率 | `snapshot_capture / snapshot_open` | `snapshot_capture`, `snapshot_open` |
| 分析成功率 | `snapshot_analysis_success / snapshot_capture` | `snapshot_analysis_success`, `snapshot_capture` |
| 分析失败率 | `snapshot_analysis_fail / snapshot_capture` | `snapshot_analysis_fail`, `snapshot_capture` |
| 保存率 | `snapshot_save / snapshot_analysis_success` | `snapshot_save`, `snapshot_analysis_success` |
| 重拍率 | `重拍按钮点击数 / snapshot_analysis_success` | 建议后续补 `snapshot_retake_click` |
| 单次记录完成时长 | `snapshot_save.timestamp - snapshot_open.timestamp` | `snapshot_open`, `snapshot_save` |

### Nutrition 指标

| 指标 | 计算方式 | 依赖事件 |
| --- | --- | --- |
| Dashboard 打开率 | `nutrition_dashboard_open / 活跃用户数` | `nutrition_dashboard_open` |
| 日记录率 | `发生 snapshot_save 的日活用户数 / 日活用户数` | `snapshot_save` |
| 日均餐次记录数 | `snapshot_save 总数 / 记录用户数` | `snapshot_save` |

### Coach 指标

| 指标 | 计算方式 | 依赖事件 |
| --- | --- | --- |
| Coach 打开率 | `coach_open / 活跃用户数` | `coach_open` |
| 首次发言率 | `coach_chat_start / coach_open` | `coach_chat_start`, `coach_open` |
| 建议卡点击率 | `coach_suggestion_click / coach_open` | `coach_suggestion_click`, `coach_open` |
| 平均会话时长 | `coach_session_end.duration` 平均值 | `coach_session_end` |
| 消息长度分布 | `coach_message_send.length_bucket` 分布 | `coach_message_send` |
| 类别分布排行榜 | `coach_message_send.category` 分布 | `coach_message_send` |

---

## 6. 参数枚举建议

### `source`

建议值：

- `tab`
- `home`
- `dashboard_cta`
- `push`
- `deep_link`

### `input_type`

建议值：

- `camera`
- `gallery`
- `sample`

### `analysis_stage`

建议值：

- `capture`
- `segmentation`
- `nutrition`
- `save`

### `category`

建议值：

- `workout`
- `nutrition`
- `recovery`
- `mindset`
- `unknown`

### `length_bucket`

建议值：

- `0_20`
- `20_100`
- `100_plus`

---

## 7. 推荐补充事件

以下事件未被整合版 PRD 强制要求，但对后续优化很有价值，可作为 P1 补充：

| 事件名 | 价值 |
| --- | --- |
| `snapshot_retake_click` | 明确重拍率，不依赖 UI 推算 |
| `snapshot_result_view` | 统计结果页到达率 |
| `calendar_add_success` | 区分保存成功与动画完成成功 |
| `meal_detail_open` | 衡量用户是否深入查看单餐 |
| `coach_mock_response_shown` | 判断本地回复是否稳定返回 |

---

## 8. 实施注意事项

- 所有事件必须在“行为已发生”后再发送，避免乐观上报污染数据。
- 失败事件必须包含稳定错误码，不能只传自然语言文案。
- `coach_session_start` 口径需在开发前锁定：是页面进入即算会话，还是首个交互才算会话。
- `snapshot_save` 与入库成功必须保持一致，不能在点击按钮时提前上报。
- 埋点字段名一旦上线，非必要不要修改。
