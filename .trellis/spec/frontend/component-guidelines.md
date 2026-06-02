# Component Guidelines

> Flutter widget patterns for the hand-drawn **Fitness Record App** UI.

---

## Overview

“Components” are **StatelessWidget** / **StatefulWidget** classes plus shared widgets in `lib/core/widgets/`. Styling is **not** CSS/Tailwind: use `AppColors`, `GoogleFonts`, and `HandDrawn*` wrappers.

Design source: root `健身记录app.md` (line-art spec). Implementation reference: `lib/core/theme.dart`, `hand_drawn_*.dart`.

---

## Component Structure

### Screen widget

```dart
class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ /* sections */ ],
      ),
    );
  }
}
```

- Prefer **`const` constructors** when all fields are final and child widgets allow it.
- Use **`super.key`** (not legacy `Key? key` only) for new code.
- Extract private builders as `Widget _buildX()` only when `build` exceeds ~120 lines or logic repeats.

### Stateful screen (local UI state)

```dart
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}
```

Dispose `TextEditingController`s and cancel timers/stream subscriptions in `dispose()`.

---

## Props Conventions

| Pattern | Use |
|---------|-----|
| **Required constructor params** | Data the parent must supply (`workoutName`, `onNavigateToTab`) |
| **Optional named params** | Defaults (`initialTab = 0`) |
| **No “props bag”** | Avoid passing whole `Map` when a typed model exists (migrate to `models/` later) |

Example (detail screen):

```dart
const WorkoutDetailScreen({
  super.key,
  required this.workoutName,
  required this.workoutCategory,
});
```

---

## Shared UI (use before inventing new containers)

| Widget | File | Use for |
|--------|------|---------|
| `HandDrawnCard` | `hand_drawn_card.dart` | Bordered cards, chat bubbles, list rows |
| `HandDrawnButton` | `hand_drawn_button.dart` | Primary CTA, chips (`HandDrawnButtonStyle`) |
| `HandDrawnIllustration` | `illustrations.dart` | Hero `CustomPainter` with fixed size |
| `LineArtIconPainter` | `illustrations.dart` | Icons via `CustomPaint(painter: LineArtIconPainter(iconType: 'strength'))` |
| `PrototypePage` | `prototype_page.dart` | Prototype-style page scaffold: `AppColors.canvas` background + scrollable `Column` with shared padding |
| `PrototypeHeader` | `prototype_page.dart` | Prototype-style page title + optional kicker + optional trailing action; pass `center: true` for centered headers |
| `PrototypeIconButton` | `prototype_page.dart` | 40×40 white rounded icon button using `LineArtIconPainter`; default for header trailing actions |

### HandDrawnCard defaults

- Border: `AppColors.border`, width `1.2`, radius `24`.
- Highlight selected state: increase `borderWidth` / set `borderColor: AppColors.inkBlue` (see `WorkoutPlanScreen`).

### Typography

| Role | Font | Typical use |
|------|------|-------------|
| Titles, labels, coach tone | `GoogleFonts.pangolin` | 18–28 sp, bold |
| Body, metrics, hints | `GoogleFonts.nunito` | 11–16 sp |

Use **`AppColors.inkText`** / **`AppColors.grayText`** — not raw `Colors.black54` for primary copy.

---

## Styling Patterns

1. **Theme tokens**: `AppColors.*` from `lib/core/theme.dart`.
2. **Prefer `AppTheme.lightTheme`** in `MaterialApp` when consolidating theme (today `main.dart` duplicates part of this — new work should not add a third theme definition).
3. **Borders**: `Border.all(color: AppColors.border, width: 1.2)` for controls matching design spec.
4. **Illustrations**: add new icon types to `LineArtIconPainter` switch in `illustrations.dart`; use existing `iconType` strings from [CODE_WIKI appendix](../../../docs/CODE_WIKI.md#14-附录图标类型一览) before inventing duplicates.

---

## Composition

- **Tab body**: no `Scaffold` inside tab screens unless needed (`WorkoutPlanScreen` uses inner `Scaffold` — avoid doubling `Scaffold` with `LayoutShell` when possible).
- **Pushed screens**: use `Scaffold` + `AppBar` with `Icons.arrow_back_ios_new` leading, `Navigator.pop`.
- **SnackBar feedback**: placeholder actions (category taps, “coming soon”) — keep `GoogleFonts.pangolin` for snack text and `AppColors.inkBlue` background.

---

## Accessibility

Minimum bar for new UI:

- Tappable areas ≥ 48×48 logical pixels where possible (`GestureDetector` + padding).
- Icon-only buttons: provide `tooltip` or semantic label when adding new controls.
- Do not rely on color alone for state (pair with icon/checkmark like workout completion).

Full a11y audit not done yet; do not regress existing tap targets.

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Hard-coded `#4C36E3` in a feature | Use `AppColors.inkBlue` |
| New card with copy-paste `BoxDecoration` | Wrap with `HandDrawnCard` |
| Bitmap PNG for icons | Extend `LineArtIconPainter` |
| `Key? key` without `super.key` | Use `super.key` |
| Huge mock list inside `build()` | Top-level private `const` or move to `models/` / fixture file |

---

## Forbidden

- Material defaults that clash with line-art UI (heavy elevation, dark theme) without product approval.
- Third-party UI kits that override the hand-drawn system.
- Embedding business/API calls directly in `HandDrawnCard` or painters in `core/`.

---

## 团队备注

- **手绘风是硬约束**：圆角约 24、描边 1.2、`AppColors` 色板，标题用 Pangolin，数据/正文用 Nunito。
- 新图标优先扩展 `LineArtIconPainter` 的 `iconType`，不要引入 PNG/SVG 图标资源（除非 PRD 例外）。
- `main.dart` 里 Theme 与 `AppTheme.lightTheme` 重复——新改动应逐步统一到 `AppTheme`，避免第三套主题。
- 聊天、卡片、列表行：优先 `HandDrawnCard` / `HandDrawnButton`，保持与设计稿 `健身记录app.md` 一致。
