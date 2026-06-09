Calorie Snap UI 流程设计应该围绕：

```text
拍摄
↓
识别
↓
解析
↓
展示
↓
记录
```

五个阶段构建。

---

# 整体体验节奏

```text
Home
 ↓
Camera
 ↓
Capture
 ↓
AI Analysis
 ↓
Result Reveal
 ↓
Food Detail
 ↓
History
```

用户感知时间：

```text
打开相机
0s

拍照
0.1s

AI分析
0.3~0.8s

结果展开
0.5s

完成
≈1秒
```

整个过程不能出现：

```text
Loading...
```

而应该：

```text
永远有动画
```

---

# 第一幕：首页

视觉状态：

```text
极简留白
```

类似：

```text
Apple Health
+
Notion
+
Muji
```

风格。

---

页面：

```text
┌─────────────┐
│ Good Morning │
│ Jason        │
│              │
│ 2350 kcal    │
│ Today        │
│              │
│   [ SNAP ]   │
│              │
│ Recent Meals │
└─────────────┘
```

---

点击：

```text
SNAP
```

进入相机。

---

动画：

```text
Hero Transition
```

按钮放大：

```text
scale

1.0
↓
20.0
```

覆盖全屏。

---

# 第二幕：Camera

这是核心。

---

相机界面不要像系统相机。

而是：

```text
科技扫描仪
```

感觉。

---

UI：

```text
┌─────────────┐
│             │
│             │
│   CAMERA    │
│             │
│             │
│             │
│             │
│      ○      │
└─────────────┘
```

---

实时运行：

```text
YOLO
```

但不要显示检测框。

---

而是显示：

```text
Subtle Highlight
```

轻微轮廓。

类似：

```text
苹果边缘
出现白色呼吸光
```

---

用户感觉：

```text
AI已经看见食物
```

---

# 第三幕：Capture

用户点击：

```text
Shutter
```

---

不要：

```text
咔嚓
```

结束。

---

要做：

## 冻结画面

```text
Camera Preview
↓
Freeze Frame
```

---

时间：

```text
100ms
```

---

随后：

```text
Mask Reveal
```

启动。

---

# 第四幕：AI Analysis

这是最重要的视觉设计。

很多产品：

```text
Loading...
```

非常廉价。

---

你应该做：

```text
Food Extraction
```

动画。

---

步骤：

## Step1

背景变暗

```text
100%
↓
20%
```

---

食物保留：

```text
100%
```

亮度。

---

视觉：

```text
聚焦主体
```

---

## Step2

Mask Outline

边缘出现：

```text
扫描线
```

效果。

```text
─────────
/////////
─────────
```

从上到下扫过。

---

时间：

```text
300ms
```

---

## Step3

AI识别

出现：

```text
ANALYZING
```

不要直接显示结果。

---

而是：

```text
APPLE
96%
```

逐步生成。

---

数字：

```text
0
↓
34
↓
72
↓
96
```

跳动。

---

# 第五幕：Result Reveal

这一幕决定产品高级感。

---

不要：

```text
弹窗
```

---

推荐：

```text
Receipt Reveal
```

收据展开。

---

食物仍然悬浮：

```text
顶部
```

---

底部：

```text
卡片折叠展开
```

```text
╭───────╮
│Food   │
╰───────╯

↓

╭──────────────╮
│ Apple        │
│ 182 kcal     │
│ Protein 2g   │
│ Carb 25g     │
│ Fat 0g       │
╰──────────────╯
```

---

动画：

```text
Spring
```

不是：

```text
EaseInOut
```

---

# 第六幕：数字动画

卡路里不能瞬间出现。

---

例如：

```text
182 kcal
```

动画：

```text
0
↓
24
↓
57
↓
101
↓
182
```

---

时长：

```text
600ms
```

---

配合：

```text
Ticker
```

声音。

---

用户感知：

```text
AI正在计算
```

---

# 第七幕：Food Detail

点击食物。

进入详情。

---

顶部：

```text
抠图后的食物
```

悬浮。

---

中间：

```text
营养信息
```

---

底部：

```text
AI Coach
```

例如：

```text
This meal is high in carbs.
Try adding protein.
```

---

这里不用真正请求 AI。

先埋点即可。

---

# 第八幕：保存记录

点击：

```text
Save Meal
```

---

不要：

```text
Toast
```

---

推荐：

```text
Food Collapse
```

动画。

---

食物：

```text
缩小
```

---

飞入：

```text
Timeline
```

卡片。

类似：

```text
Apple Wallet
```

加卡动画。

---

# History页面

时间轴。

---

今天：

```text
Breakfast
Lunch
Dinner
Snack
```

---

每个卡片：

```text
抠图食物
+
卡路里
+
时间
```

---

点击：

```text
Hero Transition
```

返回详情。

---

# 整个动画状态机

```text
Idle
 ↓
CameraReady
 ↓
Capture
 ↓
FreezeFrame
 ↓
FoodExtract
 ↓
AIAnalyzing
 ↓
ResultReveal
 ↓
FoodDetail
 ↓
SaveMeal
 ↓
History
```

---

对于你的 **Flutter + YOLO + RefineNet** 技术路线，我会把整个产品的核心卖点定义为：

> **“用户看到的不是 AI 在识别食物，而是 AI 把食物从现实世界中提取出来，并即时生成一张营养收据。”**

