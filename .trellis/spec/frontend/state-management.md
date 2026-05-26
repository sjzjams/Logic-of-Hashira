# State Management

> How state is managed in **fitness_log_app** today and how to extend it.

---

## Overview

| Aspect | Current project |
|--------|-----------------|
| **Global store** | None (no Provider / Riverpod / Bloc) |
| **Tab state** | `LayoutShell` → `_currentIndex` + `IndexedStack` |
| **Screen state** | `StatefulWidget` + `setState` |
| **Data** | Hard-coded lists/maps inside widgets |
| **Persistence** | None |
| **Network** | None |

Treat this as an **UI prototype** until `models/` + `repositories/` exist.

---

## State Categories

| Category | Where | Example |
|----------|-------|---------|
| **Shell / tab** | `LayoutShell` | `_currentIndex` |
| **Ephemeral UI** | Feature `State` class | `WorkoutPlanScreen._selectedDayIndex` |
| **Form input** | `TextEditingController` | `AiCoachScreen._messageController` |
| **Mock domain** | `final` lists in State/build | `_workouts`, `_messages` |
| **Settings toggles** | `SettingsScreen` | `_gymReminders`, `_googleFitLinked` |

**URL / deep link state**: not implemented.

---

## When to Use Local `setState`

Use **local state** when:

- Only one screen (or subtree) reads/writes the value.
- UI selection: tabs, day picker, segmented Nutrition/Sleep.
- Temporary chat input and mock message append.

Keep using `setState` for these until a global solution is chosen in a dedicated task/PRD.

---

## When to Promote State (future)

Promote to **global** (Provider/Riverpod/Bloc) when:

- Same data appears on **Home + Profile + Progress** with one source of truth.
- User session (name, streak, settings) must survive tab switches **and** app restarts.
- Coach messages or workout completion sync across Plan and Profile.

Do **not** add a global package for a single-screen toggle.

Suggested layout after promotion:

```
lib/providers/   # or lib/bloc/
lib/models/
lib/repositories/
```

---

## Server State

Not applicable yet. When APIs arrive:

- Repositories return typed `Future`/`Stream` models.
- UI layer: `AsyncValue`-style loading/error or explicit `ConnectionState` in widgets.
- Do not leave raw `http` calls inside `build()`.

Mock → real migration: replace inline lists in screens with repository streams; keep widget trees stable.

---

## Parent ↔ Child Communication

| Need | Pattern in repo |
|------|-----------------|
| Child changes tab | Callback: `onNavigateToTab(int index)` on `HomeScreen` |
| Open sub-screen | `Navigator.push(context, MaterialPageRoute(...))` |
| Pass arguments | Constructor params on detail screens |

Avoid `InheritedWidget` hacks until a state package is adopted.

---

## Derived State

Compute in `build` or small getters when cheap (e.g. `isSelected = _selectedDayIndex == index`).

For heavy lists, memoize in State after `setState` triggers, or use `select` from Riverpod later.

---

## Common Mistakes

| Mistake | Why it hurts |
|---------|----------------|
| Duplicating mock user “Alex” in every screen | Drift when profile updates |
| `Future.delayed` mock AI without `mounted` check | setState after dispose |
| Storing tab index only in child | Breaks “Start → Plan tab” from Home |
| Global singleton statics for mock data | Untestable, blocks DI |

---

## Forbidden (current phase)

- Adding Provider/Riverpod **without** a task PRD and folder layout in `lib/`.
- `setState` in `StatelessWidget` (use `StatefulWidget` or lift state).
- Persisting with ad-hoc files before choosing `shared_preferences` / `hive` / etc. in PRD.

---

## 团队备注

- **现阶段一律本地 `setState`**，不要为单个页面引入 Riverpod/Bloc，除非任务 PRD 写明「引入全局状态方案」。
- Tab 切换只能改 `LayoutShell` 的 index；Home「Start」跳 Plan 用 `onNavigateToTab(3)`，不要在子页面再套一层 Tab。
- Mock 用户「Alex」、周计划列表等多处重复——接真实数据时优先抽 `models` + 单一数据源，避免各 Screen 各写一份。
- AI 教练 `Future.delayed` 模拟回复必须保留 `mounted` 判断。
