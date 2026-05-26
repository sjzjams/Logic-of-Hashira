# Database Guidelines

> Persistence and data layer conventions.

---

## Current status: not applicable

No database, ORM, or migrations exist in this repository. All user-visible data is **in-memory mock** inside Flutter widgets.

---

## When you add persistence

Document here:

| Topic | What to specify |
|-------|-----------------|
| **Store** | PostgreSQL, SQLite, Firestore, Hive, etc. |
| **Migrations** | Tooling and naming (`YYYYMMDD_description`) |
| **Schema** | Table/collection naming, user_id scoping |
| **Queries** | Repository-only access; no SQL in UI |
| **Mobile offline** | Local cache vs server source of truth |

Align with [frontend/state-management.md](../frontend/state-management.md) for sync rules.

---

## Flutter local storage (client-only)

If only on-device storage is needed before a server:

- Prefer one chosen package per PRD (`shared_preferences`, `hive`, `drift`, …).
- Do not mix three stores without justification.

---

## Forbidden (placeholder phase)

- Assuming PostgreSQL or Prisma exists in this repo.
- Storing PII in plain `shared_preferences` without encryption decision in PRD.

---

## 团队备注

- 健身记录类数据（训练、睡眠、营养）上线前需定：**离线优先还是云端为准**。
- 与 Google Fit 联动属于客户端 + 可选云端；见 `SettingsScreen` Mock 开关。
