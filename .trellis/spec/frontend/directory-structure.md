# Directory Structure

> How Flutter UI code is organized in **fitness_log_app** (`lib/`).

---

## Overview

This is a **feature-first** Flutter app with a thin entrypoint and a shared **core** layer for design tokens and hand-drawn widgets. There is no `src/` tree, no separate `data`/`domain` packages yet, and no global state package.

| Layer | Path | Responsibility |
|-------|------|----------------|
| **Entry** | `lib/main.dart` | `main()`, `MaterialApp`, top-level `ThemeData` |
| **Shell** | `lib/features/layout_shell.dart` | Bottom navigation + `IndexedStack` tab host |
| **Features** | `lib/features/<feature>/` | One screen (or small group) per fitness domain |
| **Core** | `lib/core/` | `AppColors`, reusable widgets, `CustomPainter` illustrations |

Reference: [docs/CODE_WIKI.md](../../../docs/CODE_WIKI.md).

---

## Directory Layout

```
lib/
├── main.dart
├── core/
│   ├── theme.dart                 # AppColors, AppTheme.lightTheme
│   └── widgets/
│       ├── hand_drawn_card.dart
│       ├── hand_drawn_button.dart
│       └── illustrations.dart     # CustomPainter icons & hero art (~1k lines)
└── features/
    ├── layout_shell.dart          # Tab shell (not nested in a subfolder)
    ├── home/
    │   └── home_screen.dart
    ├── progress/
    │   └── progress_screen.dart
    ├── coach/
    │   └── ai_coach_screen.dart
    ├── plan/
    │   ├── workout_plan_screen.dart
    │   └── workout_detail_screen.dart
    ├── profile/
    │   ├── profile_screen.dart
    │   └── settings_screen.dart
    ├── nutrition/
    │   └── nutrition_sleep_screen.dart
    └── future_you/
        └── future_you_screen.dart
```

**Platform & tooling** (not under `lib/`): `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`, `test/`, `docs/`.

---

## Module Organization

### When to add a new folder under `features/`

Create `lib/features/<feature_name>/` when:

- The screen is a **distinct product area** (matches PRD / design sections), or
- You have **2+ related screens** (e.g. `plan/` already has list + detail).

Keep a **single file** in the folder until a second screen or private widgets justify splitting (e.g. `plan/workout_detail_screen.dart`).

### What belongs in `core/`

| Put in `core/` | Put in `features/` |
|----------------|-------------------|
| Used by **2+ features** | Used by **one** feature only |
| Design tokens (`AppColors`) | Screen layout & copy |
| `HandDrawnCard`, `HandDrawnButton` | Feature-specific mock lists |
| Shared `CustomPainter`s (`LineArtIconPainter`) | Navigation to sub-screens |

Do **not** put feature-specific painters in `core/` unless another feature needs them.

### Planned layers (not present yet)

When adding persistence or APIs, introduce **without breaking** feature folders:

```
lib/
├── models/           # immutable data classes (Workout, UserProfile, …)
├── repositories/     # API / local DB
└── providers/        # or bloc/ — global/session state
```

Import direction: `features → core`, `features → models/repositories`; **never** `core → features`.

---

## Naming Conventions

| Kind | Rule | Example |
|------|------|---------|
| **Folders** | `snake_case`, domain noun | `future_you/`, `nutrition/` |
| **Screen files** | `<name>_screen.dart` | `home_screen.dart` |
| **Screen classes** | `PascalCase` + `Screen` | `HomeScreen`, `WorkoutDetailScreen` |
| **Shell / app** | Descriptive noun | `LayoutShell`, `MyApp` |
| **Core widgets** | `snake_case` file, `PascalCase` class | `hand_drawn_card.dart` → `HandDrawnCard` |
| **Painters** | `PascalCase` + `Painter` | `ChestPortraitPainter` |
| **Imports** | Package imports for `lib/` | `import '../../core/theme.dart';` |

Avoid `src/`, `pages/`, `components/` top-level names — this repo uses **`features/`** and **`core/widgets/`** only.

---

## Navigation Placement

| Navigation type | Where it lives |
|-----------------|----------------|
| **Bottom tabs (5)** | `LayoutShell` only |
| **Push routes** | Calling screen uses `Navigator.push` + `MaterialPageRoute` |
| **Tab switch from child** | Callback from parent, e.g. `HomeScreen(onNavigateToTab: …)` |

Do not add a separate `routes/` file until route count grows; then prefer `go_router` with names aligned to feature folders.

---

## Assets & Fonts

- **No image assets** in `pubspec.yaml` today; illustrations are **`CustomPaint`** in `illustrations.dart`.
- **Fonts**: loaded via `google_fonts` at runtime (Pangolin, Nunito). Do not add `.ttf` under `assets/fonts/` unless offline bundling is required.

---

## Examples

| Module | Why it’s a good reference |
|--------|---------------------------|
| `lib/features/layout_shell.dart` | Tab host, `IndexedStack`, shared nav icons |
| `lib/features/home/home_screen.dart` | Callback to parent tab + `Navigator.push` |
| `lib/features/plan/` | List screen + detail screen in one feature |
| `lib/core/widgets/hand_drawn_card.dart` | Shared bordered card + optional `onTap` |
| `lib/core/theme.dart` | Single source for colors (prefer over hard-coded hex in features) |

---

## Forbidden

- New screens directly under `lib/` (except `main.dart`).
- Duplicate color hex in features when `AppColors` already defines the token.
- Large feature-specific UI copied into `core/` for one-off use.
- React/web-style `src/components` paths in new code.

---

## 团队备注

- **目录以 `lib/features/` + `lib/core/` 为准**，不要按 Web 习惯建 `src/pages`。
- 新功能优先放进已有 feature 文件夹；仅当 PRD 明确是新领域时再建目录（如 `log/`、`social/`）。
- 接 API 时再建 `lib/models/`、`lib/repositories/`，导入方向：`features → core/models/repositories`，禁止反向依赖。
- 更完整的模块说明见 `docs/CODE_WIKI.md`；视觉规范见根目录 `健身记录app.md`。
