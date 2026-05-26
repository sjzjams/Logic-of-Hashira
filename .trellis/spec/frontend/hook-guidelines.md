# Stateful Logic & Callbacks

> Flutter equivalent of “hooks”: lifecycle, callbacks, and shared logic (no React hooks in this repo).

---

## Overview

This project does **not** use React hooks. Stateful behavior is implemented with:

- `StatefulWidget` + `State<T>`
- Constructor **callbacks** for parent communication
- **`TextEditingController`** and `FocusNode` for inputs
- **`CustomPainter`** with `shouldRepaint` for static art

---

## StatefulWidget Lifecycle

| Phase | Responsibility |
|-------|----------------|
| `initState` | Copy `widget.*` to state; init lists; **do not** use `context` for inherited widgets |
| `build` | Pure layout; avoid heavy sync work |
| `dispose` | `controller.dispose()`, cancel `Timer`, close subscriptions |

Example: `NutritionSleepScreen` sets `_selectedTab = widget.initialTab` in `initState`.

---

## Callback Patterns (preferred over global bus)

```dart
// Parent supplies tab switching
HomeScreen(onNavigateToTab: (index) {
  setState(() => _currentIndex = index);
});
```

| Callback | When |
|----------|------|
| `VoidCallback onTap` | Buttons, cards (`HandDrawnCard.onTap`) |
| `void Function(int)` | Tab index from child |
| `ValueChanged<bool>` | Future settings toggles if extracted |

Name callbacks by **intent** (`onNavigateToTab`), not widget type (`onHomeTap`).

---

## Controllers & Focus

- Create `TextEditingController` in `initState`, dispose in `dispose`.
- Clear input after send: `_messageController.clear()` after append (see `AiCoachScreen`).

---

## Async After Delay

Mock AI reply pattern — **always** guard `mounted`:

```dart
Future.delayed(const Duration(seconds: 1), () {
  if (!mounted) return;
  setState(() { /* append message */ });
});
```

---

## Extracting Shared Logic

| Situation | Extract to |
|-----------|------------|
| Same UI block in 2+ screens | `core/widgets/` widget |
| Same math/formatting | `lib/core/utils/` or top-level function in feature file |
| Same state + API (future) | Riverpod provider / Bloc — not a “hook” file |

Do **not** create `use_*` Dart files mimicking React; use idiomatic Flutter.

---

## Data Fetching (future)

When network layer exists:

- Fetch in repository, expose to UI via provider/Bloc.
- Show loading/error in screen `build` — not in `CustomPainter`.

---

## Naming Conventions

| Item | Rule |
|------|------|
| State class | `_PrivateScreenState` |
| Private methods | `_buildSection()`, `_sendMessage()` |
| Callback params | `on` + Verb + Noun (`onNavigateToTab`) |

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `setState` after async without `mounted` | Guard with `if (!mounted) return` |
| Leaking `TextEditingController` | `dispose()` |
| Passing `BuildContext` into long-lived objects | Use repository/provider |
| Tab change via nested Navigator incorrectly | Use `LayoutShell` callback index 0–4 |

---

## Forbidden

- React-style hook libraries in Flutter.
- `GlobalKey` abuse to reach parent state when a callback suffices.
- Starting timers in `build()`.

---

## 团队备注

- 本文件对应 Flutter **生命周期与回调**，不是 React Hooks；勿创建 `use_xxx.dart` 命名文件。
- 父传子：用 `onNavigateToTab` 这类命名清晰的回调；避免 `GlobalKey` 取父 State。
- `TextEditingController`、定时器、`AnimationController` 必须在 `dispose` 释放。
- 异步 `setState` 前检查 `mounted`（参考 `AiCoachScreen`）。
