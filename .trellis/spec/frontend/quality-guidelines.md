# Quality Guidelines

> Code quality standards for Flutter frontend work in this repo.

---

## Overview

Stack: **Flutter 3.41+**, **Dart 3.11+**, `flutter_lints` via `analysis_options.yaml`. No CI config in repo yet; run checks locally before merge.

---

## Required Checks

Run from project root after meaningful `lib/` changes:

```bash
flutter pub get
flutter analyze
flutter test
```

| Check | Expectation |
|-------|-------------|
| `flutter analyze` | Zero errors (warnings: fix or document in PR) |
| `flutter test` | Must pass once tests match app (see Testing below) |
| Format | `dart format lib test` on touched files |

---

## Forbidden Patterns

| Pattern | Reason |
|---------|--------|
| `print()` for debugging in committed code | Use `debugPrint` or remove |
| Ignoring analyzer with `// ignore:` without comment | Hides real issues |
| `dynamic` for domain models when types are known | Use classes in `lib/models/` |
| Secrets in repo (API keys, `.env` committed) | Use env / gitignore |
| Bypassing `HandDrawn*` + `AppColors` for one screen “quickly” | Breaks design system |
| `flutter_svg` for icons already in `LineArtIconPainter` | Duplicates art pipeline |
| Second `MaterialApp` nested in a feature | Single app root in `main.dart` |

---

## Required Patterns

| Pattern | Where |
|---------|-------|
| Colors from `AppColors` | All features |
| Shared cards/buttons from `core/widgets/` | Repeated bordered UI |
| `super.key` on widgets with keys | New/edited widgets |
| `if (!mounted) return` after `async` before `setState` | Stateful screens (e.g. coach mock reply) |
| Relative imports within `lib/` package | `package:fitness_log_app/...` or `../../core/...` consistently per file |

---

## Testing Requirements

| Level | Status | Expectation |
|-------|--------|-------------|
| **Widget** | `test/widget_test.dart` is **stale** (Counter template) | New features should add/update tests that `pumpWidget(const MyApp())` and assert visible copy (e.g. `'Good morning, Alex'`) |
| **Unit** | None | Add when extracting `models/` or parsers |
| **Golden** | None | Optional for line-art screens after stabilizing layout |

Minimum for a feature PR until suite is rebuilt:

- At least one widget test **or** manual test plan in task PRD.

---

## Code Review Checklist

- [ ] Files live under correct `features/` or `core/` per [directory-structure.md](./directory-structure.md)
- [ ] No new hard-coded brand colors outside `theme.dart`
- [ ] Navigation: tabs only in `LayoutShell`; pushes use `MaterialPageRoute`
- [ ] Controllers/timers disposed in `State.dispose`
- [ ] `flutter analyze` clean
- [ ] Mock data changes reflected in CODE_WIKI if user-facing copy/structure changes
- [ ] No scope creep (unrelated refactors)

---

## Performance

- Prefer `const` constructors for static subtrees.
- Large lists: `ListView.builder`, not unbounded children in scroll views.
- `illustrations.dart` painters: `shouldRepaint` stays `false` unless params change.
- Do not add heavy packages without PRD (this app is UI-first).

---

## Documentation

When adding a feature area or changing architecture:

- Update [docs/CODE_WIKI.md](../../../docs/CODE_WIKI.md) (navigation, modules, key classes).
- Update [README.md](../../../README.md) if run/setup changes.

---

## 团队备注

- 提交前至少跑：`flutter pub get`、`flutter analyze`、`flutter test`（`test/widget_test.dart` 已对齐当前 App）。
- 改 UI 若影响 Tab/路由/模块划分，请同步 `docs/CODE_WIKI.md`。
- 不要提交 `build/`、`.dart_tool/`；密钥勿进仓库。
- 大改 `illustrations.dart` 时注意体积与性能，`shouldRepaint` 保持为 `false` 除非参数化上色。
