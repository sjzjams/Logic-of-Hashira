这是一个非常正确的阶段性选择。

根据你上传的项目架构，目前 Coach 已经有：

```text
Coach Tab
↓
AiCoachScreen
↓
LlmChatView
↓
FirebaseProvider / EchoProvider
```

而你现在真正缺的不是 AI。

而是：

```text
用户到底在问什么
用户最关心什么
用户使用频率如何
```

所以我建议：

## V1

不要接 GPT

不要接 Gemini

不要接 Claude

直接做：

```text
Fake AI Coach
+
完整埋点系统
```

---

# 产品目标

先验证：

```text
Coach 是否有人用

用户最关心什么

未来应该接什么能力
```

而不是：

```text
AI回答准不准
```

---

# Coach V1 架构

```text
AiCoachScreen

↓

MessageInput

↓

Event Tracking

↓

Local Mock Response

↓

Chat UI
```

---

# 埋点事件设计

## 页面级

```dart
coach_open
```

参数：

```json
{
  "source":"tab"
}
```

---

## 会话开始

```dart
coach_chat_start
```

参数：

```json
{
  "first_message":true
}
```

---

## 用户发送消息

```dart
coach_message_send
```

参数：

```json
{
  "message_length":42,
  "category":"workout"
}
```

---

# 分类非常重要

发送后做关键词分类

例如：

```text
bench
squat
deadlift
```

↓

```json
{
  "category":"workout"
}
```

---

```text
protein
diet
calories
```

↓

```json
{
  "category":"nutrition"
}
```

---

```text
sleep
recovery
rest
```

↓

```json
{
  "category":"recovery"
}
```

---

```text
motivation
lazy
discipline
```

↓

```json
{
  "category":"mindset"
}
```

---

最终你会得到：

```text
用户问了什么
```

排行榜。

例如：

```text
Workout 45%

Nutrition 30%

Recovery 15%

Mindset 10%
```

---

# 建议新增埋点

## 建议卡片点击

你现在已经有：

```dart
aiCoachSuggestions
```

```text
Help me improve bench press

How can I sleep better?

What should I do on recovery days?
```

点击：

```dart
coach_suggestion_click
```

参数：

```json
{
  "suggestion":"sleep"
}
```

---

# 消息长度统计

```dart
coach_message_send
```

增加：

```json
{
  "length":128
}
```

区分：

```text
0~20
20~100
100+
```

可以判断：

```text
用户在搜索
还是在倾诉
```

---

# 会话时长

进入页面：

```dart
coach_session_start
```

离开页面：

```dart
coach_session_end
```

计算：

```json
{
  "duration":185
}
```

---

# 快捷标签系统

在输入框上面增加：

```text
🏋 Workout

🍗 Nutrition

😴 Recovery

🧠 Mindset
```

点击：

```dart
coach_tag_click
```

参数：

```json
{
  "tag":"nutrition"
}
```

---

# Mock Response 策略

暂时不要 AI。

直接：

```dart
Map<String,String>
```

例如：

```dart
workout
→
"Consistency beats intensity. Focus on progressive overload this week."

nutrition
→
"Prioritize protein intake and maintain a calorie target."

sleep
→
"Try maintaining a consistent bedtime and reducing screen exposure."

mindset
→
"Small habits repeated daily create long-term transformation."
```

随机返回。

用户体验已经足够。

---

# 结合你当前项目

我建议把埋点统一抽出来。

新增：

```text
lib/

core/

analytics/

├── analytics_service.dart
├── event_names.dart
└── event_models.dart
```

---

# EventNames

```dart
class AnalyticsEvent {

  static const coachOpen =
      'coach_open';

  static const coachMessageSend =
      'coach_message_send';

  static const coachSuggestionClick =
      'coach_suggestion_click';

  static const coachSessionStart =
      'coach_session_start';

  static const coachSessionEnd =
      'coach_session_end';
}
```

---

# AnalyticsService

先打印日志即可：

```dart
class AnalyticsService {

  static void track(
    String event,
    Map<String,dynamic> params,
  ) {

    debugPrint(
      '[Analytics] $event $params'
    );
  }
}
```

未来替换成：

```text
Firebase Analytics

Mixpanel

PostHog

Amplitude
```

都不影响业务代码。

---

# 对 Future You 的价值

当你积累几千条 Coach 消息后，你会知道：

```text
用户最关心什么

训练？
饮食？
睡眠？
恢复？
减脂？
增肌？
```

然后 Future You、Food Snapshot、MuscleMap 的优先级就能用真实数据决定，而不是靠猜测。

所以现阶段：

```text
Fake AI Coach
+
完整埋点
```

比接入任何大模型都更有价值。
