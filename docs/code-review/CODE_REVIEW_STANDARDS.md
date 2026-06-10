# Logic-of-Hashira 代码审查标准

> 版本: 1.0 | 更新日期: 2026-06-10 | 适用项目: Flutter 健身记录应用

---

## 📋 目录

1. [审查原则](#审查原则)
2. [审查清单](#审查清单)
3. [优先级定义](#优先级定义)
4. [Flutter 专项检查](#flutter-专项检查)
5. [性能指标](#性能指标)
6. [审查模板](#审查模板)

---

## 🎯 审查原则

### 核心目标
1. **正确性** - 代码是否实现了预期功能？
2. **可维护性** - 6个月后能否轻松理解？
3. **性能** - 是否存在内存泄漏或不必要的重绘？
4. **安全性** - 用户输入是否验证？敏感数据是否保护？

### 审查文化
- ✅ **教学式审查** - 每条意见都是学习机会
- ✅ **建设性反馈** - 解释"为什么"，不只是"怎么做"
- ✅ **质疑代码，而非人** - 对事不对人
- ✅ **及时响应** - 24小时内完成审查（工作日）
- ❌ 不纠结格式问题（交给 linter）
- ❌ 不要求完美（追求进步，不是完美）

---

## ✅ 审查清单

### 🔴 必须修复（Blockers）

#### 功能性
- [ ] 核心功能是否按需求实现？
- [ ] 边界情况是否处理？（空值、空列表、网络异常）
- [ ] 状态管理是否正确？（避免状态不一致）
- [ ] 导航逻辑是否合理？（避免导航栈混乱）

#### 安全性
- [ ] 用户输入是否验证和清理？
- [ ] 敏感数据是否加密存储？（SharedPreferences 不应存明文密码）
- [ ] 网络请求是否使用 HTTPS？
- [ ] 是否避免硬编码 API Key/Secret？

#### 数据安全
- [ ] 数据库操作是否有事务保护？
- [ ] 文件操作是否检查权限？
- [ ] 是否正确处理用户数据删除（GDPR 合规）？

#### 崩溃风险
- [ ] 是否有未捕获的异常？
- [ ] 空安全是否严格执行？（避免使用 `!` 除非确定非空）
- [ ] 异步操作是否正确处理错误？

---

### 🟡 应该修复（Suggestions）

#### 代码质量
- [ ] 命名是否清晰？（变量、函数、类）
- [ ] 函数是否单一职责？（不超过 30 行）
- [ ] 类是否职责明确？（不超过 300 行）
- [ ] 是否避免深层嵌套？（不超过 3 层）
- [ ] 是否提取重复代码？

#### 性能优化
- [ ] 是否避免不必要的 `setState`？
- [ ] 列表是否使用 `ListView.builder`？（超过 10 项）
- [ ] 图片是否适当缓存和压缩？
- [ ] 是否避免在 `build` 方法中创建对象？
- [ ] 动画是否使用 `AnimatedBuilder` 或 `TweenAnimationBuilder`？

#### 状态管理
- [ ] 是否选择合适的状态管理方式？（Provider/Riverpod/Bloc）
- [ ] 是否避免滥用 `GlobalKey`？
- [ ] 是否正确清理资源？（dispose controllers, streams）

#### 测试覆盖
- [ ] 核心业务逻辑是否有单元测试？
- [ ] UI 组件是否有 widget 测试？
- [ ] 关键用户流程是否有集成测试？

---

### 💭 建议改进（Nits）

#### 代码风格
- [ ] 是否遵循 Dart 风格指南？
- [ ] 注释是否解释"为什么"而非"是什么"？
- [ ] 是否删除废弃代码和注释掉的代码？
- [ ] 国际化字符串是否提取到 `l10n`？

#### 文档
- [ ] 复杂逻辑是否有注释说明？
- [ ] 公共 API 是否有 dartdoc 注释？
- [ ] README 是否更新（如添加新依赖或功能）？

---

## 🏷️ 优先级定义

### 🔴 Blockers（必须修复）
**定义**: 合并后会引入 bug、安全漏洞或数据丢失的问题。

**处理方式**: 
- 必须在合并前修复
- 审查者应提供具体修复建议
- 可考虑配对编程解决

**示例**:
```
🔴 **Null Safety Violation**
Line 45: Using `!` on potentially null value.

**Why:** Will cause runtime crash if `user` is null.

**Suggestion:**
- Use `user?.name ?? 'Guest'` or add null check before.
```

---

### 🟡 Suggestions（应该修复）
**定义**: 影响代码质量或性能，但不阻塞合并的问题。

**处理方式**:
- 建议修复，但可由作者决定是否采纳
- 可创建 follow-up issue 跟踪
- 新代码应遵守，旧代码可逐步改进

**示例**:
```
🟡 **Performance: Rebuild Optimization**
Line 89: `setState` rebuilds entire widget tree.

**Why:** Causes unnecessary rebuilds of `HeavyWidget`.

**Suggestion:**
- Extract `HeavyWidget` into separate widget with `const` constructor.
- Or use `ValueNotifier` + `ValueListenableBuilder`.
```

---

### 💭 Nits（建议改进）
**定义**: 主观偏好或微小改进，不影响功能。

**处理方式**:
- 可选修复
- 不阻塞合并
- 用于分享知识和最佳实践

**示例**:
```
💭 **Readability: Variable Naming**
Line 23: Consider renaming `data` to `exerciseRecords`.

**Why:** More specific names improve readability.

**Note:** This is a suggestion, not a requirement.
```

---

## 📱 Flutter 专项检查

### Widget 设计
- [ ] 是否优先使用 `StatelessWidget`？（除非需要状态）
- [ ] 是否使用 `const` 构造函数？（减少重建）
- [ ] 是否避免在 `build` 方法中做重计算？
- [ ] 是否正确使用 `Key`？（用于保留状态）
- [ ] 是否避免 `mounted` 检查后再 `setState`？

### 布局性能
- [ ] 是否避免嵌套过深的布局？（超过 5 层考虑重构）
- [ ] 是否使用 `Expanded`/`Flexible` 正确处理约束？
- [ ] 是否避免在滚动视图中使用 `AspectRatio`？
- [ ] 是否使用 `SliverList`/`SliverGrid` 优化长列表？

### 内存管理
- [ ] 是否清理 `TextEditingController`？
- [ ] 是否取消 `StreamSubscription`？
- [ ] 是否清理 `AnimationController`？
- [ ] 是否避免在 `dispose` 中访问 `context`？

### 平台交互
- [ ] 原生代码（Kotlin/C++）是否正确管理内存？
- [ ] 是否正确处理生命周期？（`WidgetsBindingObserver`）
- [ ] 是否检查权限后再使用敏感 API？

---

## ⚡ 性能指标

### 渲染性能
| 指标 | 目标 | 警告 | 严重 |
|------|------|------|------|
| FPS | 60 | < 55 | < 45 |
| 帧构建时间 | < 8ms | 8-16ms | > 16ms |
| 内存占用 | < 100MB | 100-150MB | > 150MB |

### 启动性能
| 指标 | 目标 | 警告 |
|------|------|------|
| 冷启动时间 | < 2s | > 3s |
| 热启动时间 | < 1s | > 1.5s |

### 包体积
| 指标 | 目标 | 警告 |
|------|------|------|
| APK 大小 | < 50MB | > 100MB |
| 方法数 | < 65K | > 100K |

**测量工具**:
```bash
# 性能分析
flutter run --profile
# 打开 DevTools
flutter devtools

# 包体积分析
flutter build apk --analyze-size
```

---

## 📝 审查模板

### PR 描述模板

```markdown
## 📋 变更说明
<!-- 简要描述本次变更的目的 -->

## 🎯 变更类型
- [ ] ✨ Feature（新功能）
- [ ] 🐛 Bug Fix（错误修复）
- [ ] ♻️ Refactor（重构）
- [ ] 📝 Docs（文档）
- [ ] ⚡ Performance（性能优化）
- [ ] 🧪 Test（测试）

## 📱 测试设备
- 设备: [e.g., Pixel 7, iPhone 14]
- 系统: [e.g., Android 14, iOS 17]
- 模式: [Debug/Profile/Release]

## ✅ 自查清单
- [ ] 代码通过 `flutter analyze`
- [ ] 所有测试通过（`flutter test`）
- [ ] 手动测试关键流程
- [ ] 性能无明显退化
- [ ] 无新的 warnings 或 errors

## 📸 截图/录屏
<!-- 如涉及 UI 变更，请提供截图 -->

## 🔗 相关 Issue
Closes #123
```

### 审查评论模板

#### 正面反馈
```
✅ **Great Pattern!**
Line 34-42: Using `AsyncValue` from Riverpod for error handling.

This makes error states explicit and type-safe. Well done!
```

#### 问题反馈
```
🔴 **Memory Leak Risk**
Line 78: `StreamSubscription` not cancelled.

**Why:** Will cause memory leak and potential crashes.

**Suggestion:**
```dart
@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```
```

#### 讨论式评论
```
🤔 **Design Question**
Line 56: Using `GlobalKey` to access scaffold state.

Have you considered using `ScaffoldMessenger.of(context)` instead? 
It's more idiomatic and doesn't require passing keys around.

*No need to change if current approach works for you.*
```

---

## 📚 参考资料

### Flutter 性能优化
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/rendering/best-practices)
- [DevTools Performance View](https://docs.flutter.dev/development/tools/devtools/performance)

### Dart 代码风格
- [Effective Dart](https://dart.dev/effective-dart)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

### 代码审查最佳实践
- [Google's Code Review Developer Guide](https://google.github.io/eng-practices/review/)
- [Best Practices for Code Review](https://www.developer.com/design/best-practices-for-peer-code-review/)

---

## 🔄 更新记录

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-06-10 | 初始版本 | Code Review Expert |

---

**记住**: 代码审查的目的是提高代码质量和团队技能，而不是找茬。保持友善、专业和建设性！
