# Backend Development Guidelines

> Backend conventions for **fitness_log_app** / Logic-of-Hashira.

---

## Overview

**Current status: no backend in this repository.**

The project is a **Flutter UI prototype** (`lib/` only). Workout, nutrition, coach, and profile data are **hard-coded mocks** inside widgets. There are no REST routes, no database, and no server package under this repo root.

When a backend is introduced (separate repo or `server/` / `api/` package), replace the placeholders below with real conventions and mark this index **Filled**.

Until then, AI implementers should:

- Follow [.trellis/spec/frontend/](../frontend/index.md) for all UI work.
- Put API contracts in task `prd.md` + `research/` when planning integration.
- Not invent server folders under `lib/`.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Where server code would live | **Placeholder** |
| [Database Guidelines](./database-guidelines.md) | ORM / persistence (N/A today) | **Placeholder** |
| [Error Handling](./error-handling.md) | API errors (N/A today) | **Placeholder** |
| [Logging Guidelines](./logging-guidelines.md) | Server logging (N/A today) | **Placeholder** |
| [Quality Guidelines](./quality-guidelines.md) | Server tests & review (N/A today) | **Placeholder** |

---

## Planned integration (reference)

Likely future shape (not implemented):

| Concern | Suggested direction |
|---------|-------------------|
| **API** | REST or GraphQL; versioned `/v1/` |
| **Mobile client** | `lib/repositories/` + `lib/models/` calling API |
| **Auth** | Token in secure storage; refresh flow in repository |
| **Coach** | LLM or chat service behind `POST /coach/messages` |
| **Health data** | Google Fit / Apple Health via platform plugins, sync server-side optional |

Document the chosen stack in a Trellis task PRD before filling these files.

---

## How to fill (when backend exists)

1. Document **actual** stack (FastAPI, Nest, Go, Firebase, etc.) — not generic ideals.
2. Add **code examples** from the server repo.
3. List **forbidden patterns** (secrets in git, raw SQL in handlers, etc.).
4. Cross-link [frontend state-management.md](../frontend/state-management.md) for client sync rules.

---

**Language**: Guideline bodies in **English**; 团队备注 in Chinese where present.

---

## 团队备注

- 本仓库 **仅 Flutter 客户端**，后端规范全部为占位，避免 AI 误建 `api/`、`server/` 目录。
- 接 API 时建议：**先** 在 Trellis 任务里写 `prd.md` + `research/`，**再** 批量填充 `spec/backend/` 与 `lib/repositories/`。
- 设计与产品说明见根目录 `健身记录app.md`；客户端架构见 `docs/CODE_WIKI.md`。
