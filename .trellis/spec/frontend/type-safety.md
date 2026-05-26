# Type Safety

> Dart typing conventions for **fitness_log_app**.

---

## Overview

| Aspect | This project |
|--------|----------------|
| **Language** | Dart 3.11+ (`sdk: ^3.11.5`) |
| **Null safety** | Enabled (sound null safety) |
| **Codegen** | None (no freezed/json_serializable yet) |
| **Runtime validation** | None (mock maps today) |

---

## Type Organization

| Location | Contents |
|----------|----------|
| **Today** | Inline `Map<String, dynamic>`, `Map<String, String>` in screens |
| **Target** | `lib/models/*.dart` — immutable classes with `final` fields |

Import models from features; models must not import `flutter/material.dart`.

Example target model:

```dart
class WorkoutDay {
  const WorkoutDay({
    required this.title,
    required this.subtitle,
    required this.iconType,
    required this.completed,
    required this.isWorkout,
  });

  final String title;
  final String subtitle;
  final String iconType;
  final bool completed;
  final bool isWorkout;
}
```

---

## Naming

| Kind | Convention |
|------|------------|
| Classes | `PascalCase` |
| Files | `snake_case.dart` matching main class |
| Private fields | `_camelCase` |
| Enums | `PascalCase` type, `camelCase` values |

Use existing enum example: `HandDrawnButtonStyle { primary, secondary, chip }`.

---

## Maps vs Types (transitional)

Current mock pattern (acceptable until models land):

```dart
final List<Map<String, dynamic>> _messages = [
  {'sender': 'coach', 'text': '...', 'time': '09:30 AM'},
];
```

When touching a list:

1. Prefer typed class over expanding `Map` keys.
2. Access with known keys only; avoid `msg['unknown']` without cast/guard.

---

## Validation (future)

When APIs exist:

- Parse JSON in repository layer into models; throw/return `Result` types — not in widgets.
- Consider `json_serializable` + `build_runner` after PRD approval.

Until then, no fake `dynamic` from `jsonDecode` in UI files.

---

## Common Patterns

```dart
// Required constructor params — non-nullable
const NutritionSleepScreen({super.key, this.initialTab = 0});

// Callback types — prefer typedef if repeated
final void Function(int) onNavigateToTab;

// Icon type strings — document in LineArtIconPainter switch
final String iconType; // e.g. 'strength', 'cardio'
```

Use **exhaustive `switch`** on enums; for `iconType` strings, add `case` in `LineArtIconPainter` when adding new icons.

---

## Forbidden

| Pattern | Use instead |
|---------|-------------|
| `var` for public API fields | Explicit type |
| `as` casts without null check | Parse in repository / factory |
| `// ignore: implicit_dynamic` | Fix types |
| `Map<String, dynamic>` in widget **public** API | Typed model |
| Nullable `Key? key` only (legacy) | `super.key` |

---

## Analyzer

Project uses `flutter_lints`. Do not disable rules globally; fix or narrow `analysis_options.yaml` in a dedicated chore task.

---

## 团队备注

- 新代码尽量避免 `Map<String, dynamic>` 作为业务实体；列表项（训练日、消息、动作）应逐步改为 `class`。
- `iconType` 字符串与 `LineArtIconPainter` 的 `case` 必须成对新增，避免拼写错误导致默认圆点图标。
- 与后端对接时再引入 `json_serializable` 等；此前 Mock 可用 `const` 列表 + 类型化 model 并存。
