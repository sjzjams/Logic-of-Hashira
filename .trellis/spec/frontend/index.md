# Frontend Development Guidelines

> Conventions for the Flutter UI in **fitness_log_app** (`lib/`).

---

## Overview

Hand-drawn line-art fitness app: **feature-first** layout, **core** shared widgets, local **`setState`** (no global store yet). Product/design spec: `健身记录app.md`. Architecture reference: [docs/CODE_WIKI.md](../../../docs/CODE_WIKI.md).

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | `lib/` layout, features vs core, naming | **Filled** |
| [Component Guidelines](./component-guidelines.md) | Widgets, HandDrawn UI, typography | **Filled** |
| [Stateful Logic & Callbacks](./hook-guidelines.md) | Lifecycle, callbacks (Flutter; not React hooks) | **Filled** |
| [State Management](./state-management.md) | Local state today; future providers | **Filled** |
| [Quality Guidelines](./quality-guidelines.md) | analyze, test, review checklist | **Filled** |
| [Type Safety](./type-safety.md) | Dart models, maps → types migration | **Filled** |

---

## Quick Rules for AI Implementers

1. Read [directory-structure.md](./directory-structure.md) before adding files.
2. Use `AppColors` + `HandDrawnCard` / `HandDrawnButton` — see [component-guidelines.md](./component-guidelines.md).
3. Tab navigation only in `LayoutShell`; see [state-management.md](./state-management.md).
4. Run `flutter analyze` — see [quality-guidelines.md](./quality-guidelines.md).
5. Prefer typed models over `Map<String, dynamic>` — see [type-safety.md](./type-safety.md).

---

## Backend Spec

No server code in this repo yet. `.trellis/spec/backend/` remains template until an API package is added.

---

**Language**: Guideline bodies are in **English**; product copy in UI may stay English as in current screens.

---

## 团队备注

- 本目录规范已从 `docs/CODE_WIKI.md` 与现有 `lib/` 代码提炼，供 Trellis `trellis-implement` / `trellis-check` 子代理读取。
- 新任务请在 `implement.jsonl` / `check.jsonl` 中登记需要的 spec 文件路径。
- 后端暂无实现，见 [.trellis/spec/backend/](../backend/index.md) 占位说明。
- 每条 guideline 文末有中文 **团队备注**，便于日常维护；正文保持英文以利 AI 解析。
