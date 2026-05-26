# 首页 Muscle Map 改动参考文档

## 1. 文档目的

本文档用于记录本轮围绕首页 `Muscle Map` 区域所完成的代码修改，作为后续功能开发、问题排查与 UI 迭代的参考依据。

文档重点覆盖以下内容：

- 修改涉及的文件路径
- 每个文件的具体变更点
- 变更产生的原因
- 当前实现的功能逻辑
- 对原有代码结构和行为的影响
- 后续继续开发时需要注意的事项

## 2. 本次改动范围

本轮改动主要集中在首页 `Muscle Map` 展示区域，目标是将原型中的人体热力图区域接入 Flutter 首页，并逐步修正显示错乱、布局溢出、区域范围不准确等问题。

当前最终生效的实现，已经收敛为：

- 首页仅展示原型中目标区域
- 使用独立的 `MuscleMap` 组件承载页面逻辑
- 使用原型抽取出的完整 SVG 资源渲染前后人体
- 首页主体改为可滚动，避免小屏设备溢出

## 3. 涉及文件清单

### 3.1 代码文件

- `lib/features/home/home_screen.dart`
- `lib/core/widgets/muscle_map.dart`
- `pubspec.yaml`

### 3.2 新增资源文件

- `assets/muscle_map_front.svg`
- `assets/muscle_map_back.svg`

### 3.3 原型参考来源

- `prototype/个人健身成长记录app/index.html`
- `prototype/Sasha's Gym — App Store.html`

## 4. 变更明细

## 4.1 `lib/features/home/home_screen.dart`

### 修改原因

首页原本在中间区域使用静态图片 `home-body-cutout.png` 展示人体内容，无法承载新的 `Muscle Map` 交互区域。同时在接入较大组件后，页面在移动端高度不足时出现溢出。

### 具体修改点

#### 1. 接入 `MuscleMap` 组件

将原先居中的静态人体图片替换为独立组件 `MuscleMap`。

原有逻辑特征：

- 页面中部展示单张静态图片
- 无日期切换
- 无性别切换
- 无图例

当前逻辑特征：

- 页面中部展示完整 `MuscleMap` 区域
- 由单独组件负责渲染和状态控制

#### 2. 页面布局改为可滚动

将首页主体由固定 `Column + Expanded` 改为：

- `SafeArea`
- `SingleChildScrollView`
- `Padding`
- `Column(mainAxisSize: MainAxisSize.min)`

### 当前实现效果

- 首页顶部、习惯入口、问候语保留
- `MuscleMap` 作为首页中段独立模块插入
- 底部 `Today's Focus` 卡片继续保留
- 整页在小屏设备上可滚动，避免底部内容被挤压或遮挡

### 对原有代码的影响

- `home-body-cutout.png` 不再作为首页核心展示内容使用
- 页面不再依赖固定高度布局
- 首页组件树更适合继续插入复杂内容块

### 对后续开发的参考意义

- 后续首页若继续加入卡片模块，应优先兼容滚动布局
- 新模块尽量独立为组件，避免首页文件持续膨胀

## 4.2 `lib/core/widgets/muscle_map.dart`

### 修改原因

这是本轮改动的核心文件。开发过程中先尝试过基于 `CustomPainter + Path` 的方式还原人体热力图，但由于路径不完整、缩放坐标体系不一致，导致以下问题：

- 人体只显示部分区域
- 左右人体缩放错位
- 内容被遮挡或溢出
- 展示范围不符合原型要求

最终方案改为：

- 不再手工拼接不完整路径
- 直接使用从原型页面抽取出来的完整前后 SVG
- `MuscleMap` 只保留用户要求的那一块区域

### 当前文件承担的职责

`muscle_map.dart` 现在负责首页中 `Muscle Map` 区域的完整展示，包括：

- 日期卡片
- 周日期切换
- 性别切换
- 前后人体 SVG 展示
- 图例展示
- Replay 回放效果

### 具体修改点

#### 1. 新建独立组件 `MuscleMap`

新增：

- `class MuscleMap extends StatefulWidget`
- `class _MuscleMapState`

使用 `StatefulWidget` 的原因：

- 需要维护当前选中的日期
- 需要维护当前选中的性别
- 需要支持 Replay 的定时切换

#### 2. 增加本地状态管理

新增状态：

- `_selectedDayIndex`
- `_selectedGender`
- `_replayTimer`

新增方法：

- `_selectDay(int index)`
- `_selectGender(BodyGender gender)`
- `_replayWeek()`
- `dispose()`

实现逻辑说明：

- 点击日期后，更新当前选中状态
- 点击性别后，更新切换按钮高亮
- 点击 `Week` 按钮时，触发定时器回放日期状态变化
- 页面销毁时释放定时器，避免内存泄漏和状态异常

#### 3. 抽取周视图数据结构

新增：

- `enum BodyGender`
- `_LegendItemData`
- `_MuscleMapDay`
- `_legendItems`
- `_weekDays`

作用说明：

- 将图例和日期展示数据结构化
- 后续若需要接入真实训练数据，可直接扩展这一层

#### 4. 只保留原型目标区域

当前 `build()` 中只保留以下结构：

- 顶部月份/日期卡片
- 性别切换按钮
- 前后人体区域
- 底部图例

本次明确移除或不再继续保留的内容：

- 顶部标题 `Muscle Map`
- 说明文案
- 顶部 `Play with settings`
- 顶部 `Replay` 胶囊按钮

原因：

- 用户已明确要求“只要原型图片1这个区域”
- 该区域之外的内容会造成首页信息冗余，并与设计目标不一致

#### 5. SVG 渲染方案改为 `flutter_svg`

新增：

- `import 'package:flutter_svg/flutter_svg.dart';`
- `_BodySvgView`

渲染方式：

- `SvgPicture.asset('assets/muscle_map_front.svg')`
- `SvgPicture.asset('assets/muscle_map_back.svg')`

这样做的原因：

- 避免继续手工维护大量路径数据
- 直接复用原型中的完整矢量结构
- 降低错位、裁切和缩放错误的概率

#### 6. 保留原型中的核心交互视觉

当前组件保留了原型中的以下视觉特征：

- 浅灰背景日期卡片
- `Week` 胶囊按钮
- 训练日绿色圆环与闪电图标
- `Male / Female` 切换胶囊
- 五段图例

### 对原有代码的影响

#### 正向影响

- `MuscleMap` 已独立，首页职责更清晰
- 热力图区域结构更接近设计原型
- 使用完整 SVG 后，渲染稳定性高于早期路径拼接方案

#### 结构影响

- 当前文件已经成为一个较完整的展示组件
- 若后续继续增加真实训练数据绑定，推荐以当前状态层为基础扩展，而不要再回到散乱的路径拼接方式

#### 已知影响

- 目前 `Male / Female` 切换主要影响按钮状态，前后人体 SVG 仍为同一组原型抽取资源
- 这意味着视觉切换还不是“男女完全不同两套人体”
- 如后续有该需求，需要继续增加女性版本 SVG 资源和映射逻辑

## 4.3 `pubspec.yaml`

### 修改原因

为支持新的资源和渲染能力，需要补充依赖和资源声明。

### 具体修改点

#### 1. 新增依赖

- `flutter_svg: ^2.0.10-hotfix.1`
- `path_drawing: ^1.0.1`

说明：

- `flutter_svg` 当前已实际用于渲染 `MuscleMap` 前后人体 SVG
- `path_drawing` 是上一阶段尝试 `CustomPainter + SVG Path` 方案时加入的依赖，当前最终实现中未继续使用

#### 2. 注册新增资源

新增资源声明：

- `assets/muscle_map_front.svg`
- `assets/muscle_map_back.svg`

### 对原有代码的影响

- 项目资源清单扩大
- `flutter pub get` 后可正常打包新的人体 SVG 资源
- `path_drawing` 当前属于保留依赖，后续可评估是否清理

## 4.4 `assets/muscle_map_front.svg`

### 修改原因

用于承载原型中前视图人体的完整矢量内容。

### 内容来源

从 `prototype/Sasha's Gym — App Store.html` 中抽取整理得到。

### 当前作用

- 作为 `MuscleMap` 左侧前视图人体展示资源
- 由 `SvgPicture.asset` 直接渲染

### 对原有代码的影响

- 将前视图人体从代码硬编码路径改为资源化管理
- 后续如需替换样式或重新抽取原型，可直接替换资源文件

## 4.5 `assets/muscle_map_back.svg`

### 修改原因

用于承载原型中后视图人体的完整矢量内容。

### 内容来源

从 `prototype/Sasha's Gym — App Store.html` 中抽取整理得到。

### 当前作用

- 作为 `MuscleMap` 右侧后视图人体展示资源
- 由 `SvgPicture.asset` 直接渲染

### 对原有代码的影响

- 将后视图人体从代码硬编码路径改为资源化管理
- 与前视图资源形成清晰分工，便于后续按性别或训练状态扩展

## 5. 关键实现逻辑说明

## 5.1 首页布局逻辑

当前首页结构可概括为：

1. 顶部栏
2. 六个习惯入口
3. 问候区
4. `MuscleMap`
5. `Today's Focus`

布局从“固定高度挤压”改为“整体可滚动”，这是保证复杂中段模块能够稳定显示的前提。

## 5.2 Muscle Map 逻辑

当前 `MuscleMap` 的交互逻辑为：

1. 顶部显示月份和一周日期
2. 点击不同日期，更新当前选中项
3. 点击 `Week` 按钮，触发逐日回放动画
4. 点击性别切换按钮，仅改变当前切换状态显示
5. 中部展示前后两张完整人体 SVG
6. 底部展示五级图例说明

## 5.3 为什么最终选择 SVG 资源方案

### 原因 1：原型本身就是完整 SVG

网页原型中的人体并不是 Flutter 原生形状，而是完整矢量结构。直接抽取原型 SVG 更接近设计源。

### 原因 2：避免路径拼接错误

早期路径方案的主要问题是：

- 坐标系复杂
- 路径量大
- 很难保证完整性
- 很容易在缩放时错位

### 原因 3：后续维护成本更低

SVG 资源方案允许后续开发者：

- 直接替换资源
- 直接增加女版资源
- 直接进行版本对比

无需再手工维护大量 Dart 路径数据。

## 6. 对原有代码和功能的整体影响

## 6.1 首页展示方式变化

原先：

- 首页中心是单张静态人体图片

现在：

- 首页中心是结构化的 `MuscleMap` 组件

影响：

- 页面视觉表达更丰富
- 组件复杂度上升
- 需要依赖额外资源文件

## 6.2 资源管理方式变化

原先：

- 主要依赖 PNG 资源

现在：

- 同时使用 PNG 与 SVG 资源

影响：

- 资源管理更灵活
- 需要在 `pubspec.yaml` 中维护资源清单

## 6.3 状态逻辑引入

原先：

- 首页中部区域几乎无状态

现在：

- `MuscleMap` 内部引入日期状态、性别状态、回放状态

影响：

- 后续接入真实训练数据有了状态入口
- 也意味着后续修改应避免将状态再分散回首页

## 7. 开发过程中的关键决策记录

## 7.1 已放弃方案：`CustomPainter + 手工路径拼接`

### 放弃原因

- 路径抽取不完整
- 缩放定位不稳定
- 小屏下更容易出现残缺和错位
- 调试成本高

### 当前结论

如非必须，不建议再回退到该方案。

## 7.2 最终采用方案：独立组件 + 完整 SVG 资源

### 采用原因

- 更接近网页原型
- 渲染稳定
- 结构清晰
- 更适合后续维护

## 8. 当前已知限制与后续建议

## 8.1 当前已知限制

### 1. 性别切换仅影响按钮状态

当前切换 `Male / Female` 时，人体显示资源未切换为两套不同 SVG。

### 2. `path_drawing` 依赖暂未清理

该依赖是上一阶段尝试方案留下的，目前可视为保留项。

### 3. 当前文档基于“最终生效代码”

文档主要描述当前项目里实际存在并生效的实现，不用于逐行复盘所有中间临时代码。

## 8.2 后续建议

### 建议 1：如需完整复刻男女差异，新增女版 SVG 资源

建议新增：

- `assets/muscle_map_front_female.svg`
- `assets/muscle_map_back_female.svg`

然后在 `muscle_map.dart` 中根据 `_selectedGender` 切换资源。

### 建议 2：如需接入真实训练数据，可扩展 `_weekDays`

当前 `_weekDays` 为静态演示数据，后续可替换为：

- API 返回数据
- 本地训练记录聚合数据
- 日期维度的训练热力状态

### 建议 3：评估清理 `path_drawing`

若后续不再使用 `CustomPainter + Path`，可移除该依赖，减少无效依赖残留。

## 9. 后续任务开发参考入口

后续如需继续开发该区域，建议优先从以下文件入手：

- 页面挂载入口：`lib/features/home/home_screen.dart`
- 组件主体逻辑：`lib/core/widgets/muscle_map.dart`
- 资源声明：`pubspec.yaml`
- 前视图资源：`assets/muscle_map_front.svg`
- 后视图资源：`assets/muscle_map_back.svg`

## 10. 结论

本轮改动已经完成了首页 `Muscle Map` 区域从静态图片展示向独立结构化组件的迁移，并将最终实现稳定在“原型目标区域 + 完整 SVG 资源渲染”的方案上。

这一结果为后续开发提供了以下基础：

- 首页中段复杂模块的稳定挂载方式
- 可扩展的 `MuscleMap` 组件结构
- 明确的资源化管理方式
- 后续接入真实训练数据和性别差异资源的扩展入口

后续开发人员可基于本文档快速理解当前修改背景、结构现状与后续可扩展方向，避免重复走回路径不完整、布局错位等旧问题。

## 11. 关键代码片段参考

本节用于给后续开发人员提供可以直接定位实现思路的关键代码片段。片段不追求完整复刻整个文件，只保留最有代表性的部分。

## 11.1 首页接入 `MuscleMap`

文件：

- `lib/features/home/home_screen.dart`

说明：

- 首页主体改为 `SingleChildScrollView`
- `MuscleMap` 作为中段模块插入
- 为复杂内容块保留了可滚动空间

代码片段：

```dart
return Scaffold(
  body: CustomPaint(
    painter: const HomeBackgroundPainter(),
    child: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22.0, 14.0, 22.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ...
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: MuscleMap(),
              ),
              // ...
            ],
          ),
        ),
      ),
    ),
  ),
);
```

参考位置：

- [home_screen.dart](file:///d:/Logic-of-Hashira/lib/features/home/home_screen.dart#L17-L27)
- [home_screen.dart](file:///d:/Logic-of-Hashira/lib/features/home/home_screen.dart#L142-L146)

## 11.2 `MuscleMap` 主体结构

文件：

- `lib/core/widgets/muscle_map.dart`

说明：

- 组件结构已经收敛为图片1对应区域
- 主体由日期卡片、性别切换、双人体 SVG、图例组成

代码片段：

```dart
return Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 380),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildCalendarCard(),
        const SizedBox(height: 14),
        _GenderSwitch(
          selectedGender: _selectedGender,
          onChanged: _selectGender,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Expanded(
                child: _BodySvgView(
                  assetPath: 'assets/muscle_map_front.svg',
                  semanticLabel: 'Front muscle map',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _BodySvgView(
                  assetPath: 'assets/muscle_map_back.svg',
                  semanticLabel: 'Back muscle map',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
```

参考位置：

- [muscle_map.dart](file:///d:/Logic-of-Hashira/lib/core/widgets/muscle_map.dart#L105-L155)

## 11.3 日期状态与回放逻辑

文件：

- `lib/core/widgets/muscle_map.dart`

说明：

- 这是当前组件最核心的状态逻辑入口
- 后续如接入真实训练记录，通常从这里改起

代码片段：

```dart
int _selectedDayIndex = 4;
BodyGender _selectedGender = BodyGender.male;
Timer? _replayTimer;

void _selectDay(int index) {
  _replayTimer?.cancel();
  setState(() {
    _selectedDayIndex = index;
  });
}

void _replayWeek() {
  _replayTimer?.cancel();
  int nextIndex = 0;
  _replayTimer = Timer.periodic(_replayStepDuration, (Timer timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }
    setState(() {
      _selectedDayIndex = nextIndex;
    });
    nextIndex += 1;
    if (nextIndex >= _weekDays.length) {
      timer.cancel();
    }
  });
}
```

参考位置：

- [muscle_map.dart](file:///d:/Logic-of-Hashira/lib/core/widgets/muscle_map.dart#L57-L103)

## 11.4 SVG 渲染入口

文件：

- `lib/core/widgets/muscle_map.dart`

说明：

- 当前人体显示不再来自 `CustomPainter`
- 而是来自原型抽取后的 SVG 资源

代码片段：

```dart
return SvgPicture.asset(
  assetPath,
  fit: BoxFit.contain,
  alignment: Alignment.topCenter,
  semanticsLabel: semanticLabel,
);
```

参考位置：

- [muscle_map.dart](file:///d:/Logic-of-Hashira/lib/core/widgets/muscle_map.dart#L203-L223)

## 11.5 资源注册

文件：

- `pubspec.yaml`

代码片段：

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/home-body-cutout.png
    - assets/muscle_map_front.svg
    - assets/muscle_map_back.svg
    - assets/spritesheet.png
```

参考位置：

- [pubspec.yaml](file:///d:/Logic-of-Hashira/pubspec.yaml#L59-L71)

## 12. 修改时间线

本节用于帮助后续开发人员理解“本轮改动是如何一步步收敛到当前方案的”，避免只看到最终结果却忽略中间关键决策。

## 12.1 第一阶段：首页从静态人体图切换为动态区域

阶段目标：

- 替换首页原有的 `home-body-cutout.png`
- 将中间区域升级为更接近原型的 `Muscle Map`

阶段动作：

- 首页中部从图片改为组件挂载
- 页面开始承载更复杂的中段内容

阶段结果：

- 完成了静态图到组件化区域的第一步迁移

## 12.2 第二阶段：尝试使用 `CustomPainter + Path` 复刻人体

阶段目标：

- 通过路径绘制方式复刻原型肌肉热力图

阶段动作：

- 引入路径解析相关能力
- 尝试使用代码渲染人体区域

阶段问题：

- 路径不完整
- 坐标系不统一
- 左右人体错位
- 页面中部出现遮挡和溢出

阶段结论：

- 该方案维护成本高且稳定性不足，不适合作为当前首页最终实现

## 12.3 第三阶段：首页布局改为滚动结构

阶段目标：

- 解决中部模块变高后页面溢出的问题

阶段动作：

- 将首页主体改为 `SingleChildScrollView`
- 去掉依赖固定高度的中段布局方式

阶段结果：

- 页面在小屏设备上可以完整滚动
- 为后续复杂模块扩展提供了更稳的容器

## 12.4 第四阶段：需求收敛为“只保留图片1区域”

阶段目标：

- 只保留原型目标区域，不显示额外标题、描述和按钮

阶段动作：

- 去除早期额外增加的标题与说明块
- 去除不属于目标区域的顶部交互元素
- 将组件结构收敛为日期卡片、性别切换、双人体和图例

阶段结果：

- 显示范围与用户要求一致

## 12.5 第五阶段：切换为完整 SVG 资源方案

阶段目标：

- 从根本上解决人体渲染不完整的问题

阶段动作：

- 从原型 HTML 中抽取完整前后 SVG
- 写入 `assets/muscle_map_front.svg` 和 `assets/muscle_map_back.svg`
- 使用 `flutter_svg` 直接渲染

阶段结果：

- 当前方案稳定成型
- 组件结构明确
- 渲染方式更接近原型源数据

## 13. 后续任务拆分建议

本节用于将当前实现自然拆分成后续可以独立推进的任务，方便继续排期或交接。

## 13.1 任务 A：补齐男女两套人体资源切换

目标：

- 让 `Male / Female` 切换不仅改变按钮状态，还真正切换两套不同人体图

建议改动点：

- 新增女性版前后 SVG 资源
- 在 `muscle_map.dart` 中根据 `_selectedGender` 切换 `assetPath`

预期收益：

- 与原型行为更一致
- 视觉表现更完整

## 13.2 任务 B：接入真实训练数据

目标：

- 用真实训练记录替换当前 `_weekDays` 静态数据

建议改动点：

- 将 `_weekDays` 替换为数据模型
- 接入本地记录或接口返回数据
- 让日期卡片与人体热力图状态真正受业务数据驱动

预期收益：

- `MuscleMap` 从静态演示组件升级为真实业务模块

## 13.3 任务 C：整理和清理遗留依赖

目标：

- 清理当前最终实现未再使用的依赖与历史尝试残留

建议改动点：

- 评估是否移除 `path_drawing`
- 检查是否还存在与旧路径渲染方案相关的无用代码或说明

预期收益：

- 项目依赖更干净
- 降低后续误判和维护成本

## 13.4 任务 D：完善文档与交付材料

目标：

- 让后续开发、测试和产品都能快速理解该区域

建议改动点：

- 在本文档基础上持续更新每次迭代内容
- 如后续迭代较多，可再拆分一份“任务开发记录”文档
- 为每次资源替换记录来源、差异和影响范围

预期收益：

- 交接效率更高
- 代码迭代更可追溯
