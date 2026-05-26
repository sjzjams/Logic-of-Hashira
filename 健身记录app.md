# 健身 App 设计图 — 元素拆解与 1:1 Flutter 还原规范

## 目标

基于提供的设计稿图片 `ChatGPT Image 2026年5月9日 08_56_13.png`，进行：

1. **Flutter Android 应用 1:1 还原**：将设计图中的 10 个界面在 Android 平台上进行精确还原。
2. **极简线稿风模块化拆分**：将所有插画与视觉元素进行矢量化拆分，主要采用 Flutter `CustomPainter` 与 `Path` 绘制，实现细腻的手绘边框和路径动画。
3. **字体应用**：全局手写文字均采用 Google Fonts 中的 `Pangolin` 字体。
4. **配色体系统一**：复刻设计图中的深紫蓝（Ink Blue）手绘风格。

---

# 一、全局视觉风格分析

## 1. 风格关键词

* **手绘线稿风 (Hand-drawn Line-Art)**：所有卡片、插画、图标均由粗细均匀（约 1.5px 至 2px）的深紫蓝线描绘，带有自然的极简白底留白。
* **深紫蓝墨水点缀 (Ink Blue & Violet Accent)**：纯白或微带灰白的背景，搭配高饱和度的深紫蓝色作为主按钮和高亮指标色。
* **手写温度 (Pangolin Handwriting)**：页面标题、励志语录、AI 对话使用 `Pangolin` 字体，呈现手写日记般的亲和力与 AI 陪伴感。
* **轻量卡片化 (Soft Cards)**：卡片使用极浅的灰色边框，配以微弱的圆角阴影，形成干净整洁的阅读界面。

---

## 2. 全局配色 (Color Palette)

| 用途 | 颜色值 (HEX) | 对应 Flutter Color | 描述 |
| :--- | :--- | :--- | :--- |
| **主背景 (Canvas)** | `#FFFFFF` | `Colors.white` | 纯白画布底色 |
| **主墨水蓝 (Ink Blue)** | `#4C36E3` | `Color(0xFF4C36E3)` | 主线稿色、主按钮、高亮标签及激活图标 |
| **次级墨水蓝 (Light Ink)** | `#E2DFFF` | `Color(0xFFE2DFFF)` | 激活项背景、用户对话气泡、快速回复选项卡 |
| **细边框线 (Border)** | `#E2E8F0` | `Color(0xFFE2E8F0)` | 卡片外框线、分割线 |
| **主文字 (Ink Text)** | `#1E1B4B` | `Color(0xFF1E1B4B)` | 标题文字、主文本颜色 |
| **次级文字 (Gray Text)** | `#6E7191` | `Color(0xFF6E7191)` | 说明文字、副标题、未激活状态 |
| **低对比底色 (Soft Gray)**| `#F8FAFC` | `Color(0xFFF8FAFC)` | 页面局部衬底、未激活卡片背景 |
| **数据高亮线 (Active Gauge)** | `#6366F1` | `Color(0xFF6366F1)` | 进度条高亮部分 |

---

## 3. 字体系统 (Typography)

* **手写感标题与语录**：使用 **Pangolin** (Google Fonts)
  * 适用场景：屏幕大标题、名言卡片、AI 聊天气泡文本、卡片说明。
  * Flutter 配置：通过 `GoogleFonts.pangolin()` 引入。
* **正文与数字数据**：使用 **Nunito** 或系统默认无衬线字体（如 Inter / Roboto）
  * 适用场景：数据指标 (例如 "72%"、"6.5h"、"1680 kcal")、列表标签、选项按钮。
  * Flutter 配置：保证数字与小字号文本的清晰易读。

---

# 二、核心元素 Flutter 实现方案

### 1. 手绘线稿插画 (Vector Hand-drawn Illustrations)
为了保证在 Android 设备上无损缩放，以下插画必须使用 Flutter `CustomPainter` 绘制或配置为高精度 `SvgPicture`：
* **人像轮廓 (Chest-up / Full-body Human Outline)**：采用平滑贝塞尔曲线描绘人物线条。
* **山峰与小人 (Mountain Trail & Walker)**：绘制山峰的锯齿折线，以及曲折上升的登山路径和山顶的小旗子。
* **月亮与星星 (Crescent Moon & Stars)**：手绘感的不规则弯月，搭配十字星与小圆点粒子。
* **睡眠小人 (Peeking Bed Character)**：在 Sleep 页底部露出半个脑袋的可爱线稿插画。

### 2. 卡片与按钮规范
* **卡片框 (HandDrawnCard)**:
  ```dart
  Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4C36E3).withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: child,
  )
  ```
* **主按钮 (Primary Button)**:
  圆角胶囊形，深紫蓝底色，白色文字，字形采用粗体 Pangolin。
* **次级按钮 / 胶囊标签 (Secondary Chip)**:
  白底或浅紫蓝底（`#E2DFFF`），深紫蓝细边框。

---

# 三、10 个核心页面布局结构

## 1. 首页 (Home Screen)
* **状态栏与顶部导航**：左侧年份选择器（"2026"），右侧带红点的线稿铃铛图标。
* **分类导航栏**：横向滑动组件，包含 Strength, Cardio, Sleep, Nutrition, Mindset, Recovery 6 个手绘图标。
* **每日问候语**："Good morning, Alex. Your future is in progress."
* **核心半身像插画**：居中放置男性胸像线稿，以极简线条勾勒。
* **今日专注卡片**："Today's Focus: Build consistency"，右侧带有一个 "Start" 动作按钮。

## 2. 习惯与未来投影页 (Your Future You)
* **顶部导航**：返回键、标题 "Your Future You"、副标题 "Built by your habits today"。
* **半身人像对比图**：居中人像左半侧为实线（代表已完成的习惯），右半侧为虚线或灰色（代表待塑形的部分）。
* **四大指标环绕**：
  * **Consistency** (持续度): `72%` (`+8%` 向上小箭头)
  * **Workouts** (训练次数): `18` (`+3`)
  * **Sleep** (睡眠时长): `6.5h` (`+0.5h`)
  * **Progress** (总体进度): `58%` (`+5%`)
* **底部寄语卡片**："Keep going, your future self is rooting for you." 带有心形线稿。

## 3. 进度山峰页 (Progress Screen)
* **顶部标题**："Progress"，右侧为 "This Month" 下拉筛选。
* **爬山图组件**：
  * 使用 `CustomPainter` 绘制三角形山峰，山顶插有胜利旗帜。
  * 从山脚到山顶有一条发光的紫蓝色虚线曲折路径，一个小人线稿正在半山腰向上行走。
* **指标数据（分布在山体两侧）**：
  * 左侧：Training (`+12%`), Strength (`+8%`), Endurance (`+6%`)。
  * 右侧：Body Fat (`-4%`), Fat loss detected (带勾选框)。
* **底部寄语卡片**："Small steps. Big future." 带有闪烁星星线稿。

## 4. 训练计划页 (Workout Plan Screen)
* **顶部标题**："Workout Plan"、副标题 "Week 3 of 8"，右侧为线稿日历图标。
* **周历选择器 (Mon - Sun)**：横向排列的圆圈，Mon (周一) 处于激活状态（底色 `#4C36E3`，文字白色）。
* **每日训练卡片列表**：
  * **Mon**: Push Day (Chest, Shoulders, Triceps) - 右侧配有肩推推举动作的线稿小图。
  * **Tue**: Pull Day (Back, Biceps) - 引体向上线稿。
  * **Wed**: Leg Day (Quads, Hamstrings, Calves) - 深蹲线稿。
  * **Thu**: Active Recovery (Mobility & Stretching) - 泡沫轴/瑜伽垫线稿。
  * **Fri**: Full Body (Strength & Core) - 举重线稿。
  * **Sat**: Cardio (HIIT / Endurance) - 跑步线稿。
  * **Sun**: Rest Day (Recharge & Reflect) - 躺椅/水面线稿。

## 5. 训练详情页 (Workout Detail Screen)
* **顶部导航**：返回按钮、右侧分享图标与三点菜单。
* **训练主题**："Push Day (Chest, Shoulders, Triceps)"，配以大勾选圆形图标。
* **数据估算行**：预计时间 `60 min`，消耗能量 `420 kcal`。
* **动作列表 (Exercises)**：
  1. **Bench Press**: 4 x 8-10 (配卧推小线稿)
  2. **Incline Dumbbell Press**: 4 x 8-10 (配斜板哑铃推举小线稿)
  3. **Shoulder Press**: 3 x 10-12 (配坐姿推举小线稿)
  4. **Tricep Pushdown**: 3 x 12-15 (配三头下拉小线稿)
* **底部固定的主操作按钮**：宽度撑满的 "Start Workout" 按钮。

## 6. 营养摄入页 (Nutrition Screen)
* **顶部双页签 (Tab Bar)**：Nutrition / Sleep，当前选中 Nutrition，底部有手绘感的粗紫蓝横线指示。
* **宏量营养素进度条**：
  * **Calories**: 1680 / 2200 kcal (圆角柱状进度条，已填满 76%)
  * **Protein**: 120 / 160g (已填满 75%)
  * **Carbs**: 180 / 250g (已填满 72%)
  * **Fat**: 60 / 80g (已填满 75%)
* **底部食物分类线稿图标**：碗装沙拉、牛油果、烤鸡、西兰花 4 个线稿小图横向排列。
* **今日餐食记录汇总卡片**："Today's Meals: 3 / 3 logged" 带勾选图标。

## 7. 睡眠监测页 (Sleep Screen)
* **顶部双页签 (Tab Bar)**：当前选中 Sleep。
* **睡眠概述**："Sleep well. Recover better."，右侧为火焰恢复图标。
* **睡眠质量插图**：中央绘制大弯月与星星粒子图，下方显示 "Last night: 6h 30m" 及 "Sleep quality: Good (78%)"。
* **睡眠阶段分布图 (Sleep Stages)**：
  * 横向堆叠图表，展示 Awake (0h 30m), REM (1h 30m), Light (3h 10m), Deep (1h 00m)。
  * 采用不同深浅的紫蓝色条块拼接。
* **底部趣味插图**：Sleep 页面最下方露出一张正在被窝里睡觉的人脸线稿。

## 8. AI 运动教练对话页 (AI Coach Screen)
* **顶部标题**："AI Coach"，副标题 "Build the chain"，右侧为可爱的线稿机器人图标。
* **聊天消息列表**：
  * **Coach 气泡** (居左，白色底，带细框线，文字使用 Pangolin 字体)："You crushed it yesterday! 💪"
  * **User 气泡** (居右，浅紫色底 `#E2DFFF`，无框线)："Your future self thanks you."
  * **Coach 气泡**："Want a challenge for tomorrow?"
* **快捷回复卡片 (Quick Reply Chips)**：横向排列的三个小胶囊按钮："Yes, give me one", "Surprise me", "Maybe later"。
* **底部输入栏**：圆角输入框，左侧提示词 "Ask me anything..."，右侧为线稿纸飞机发送图标。

## 9. 洞察页 (Insights Screen)
* **顶部标题**："Insights"、副标题 "Understand. Improve. Grow."，右侧带有一个向上的迷你趋势折线图。
* **条目化洞察列表**：
  * 💪 "You're getting stronger (+8% strength this week)"
  * 😴 "Great sleep consistency (Keep it up!)"
  * 🔥 "Fat loss in progress (-4% this month)"
  * 📝 "You're building discipline (14 day streak 🔥)"
* **底部寄语卡片**："You don't need to be perfect, just consistent." 下方带有一颗小红心线稿。

## 10. 个人中心页 (Profile Screen)
* **顶部标题**："Profile"，右侧为线稿设置齿轮图标。
* **头像组件**：手写圆形边框，内部为 Alex 的素描头像线稿，右下方带有一支画笔（编辑）图标。
* **身体基础信息栏**：
  * Age: `28` | Height: `180 cm` | Weight: `75 kg`
* **个人设置菜单项 (List Item with Chevron)**：
  * Goals
  * Personal Info
  * Measurements
  * Settings

---

# 四、Flutter 建议开发顺序

### Phase 1: 基础建设
1. 初始化项目结构，将 Pangolin 字体添加到 `pubspec.yaml` 中，配置 `ThemeData`。
2. 编写全局自定义组件：`HandDrawnCard`、`HandDrawnButton`。
3. 建立底部导航结构 (`Scaffold` 与 `BottomNavigationBar`)。

### Phase 2: 精准还原绘制 (CustomPaint & SVGs)
1. 用 Flutter 代码手工绘制弯月、山峰路径以及两张人像的贝塞尔曲线 Path。
2. 实现睡眠阶段的横向堆叠条状图与 Insights 页的迷你折线图。

### Phase 3: 路由与页面组装
1. 完成 Home -> Workout Detail、Home -> Future You、Nutrition/Sleep 切换等子路由。
2. 给 AI Coach 编写简单的打字效果与对话列表滚动。
3. 优化卡片边缘的微小阴影与呼吸发光动效。
