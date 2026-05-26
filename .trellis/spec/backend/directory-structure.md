# Backend Directory Structure

> Server-side layout for this project.

---

## Current status: not applicable

There is **no backend codebase** in Logic-of-Hashira today. Flutter app package: `fitness_log_app`, application id `com.hashira.logic.fitness_log_app`.

Do not create empty `server/` or `api/` trees unless a Trellis task PRD explicitly scopes backend work.

---

## When you add a backend

Pick **one** layout and document it here. Examples:

### Option A — Monorepo folder

```
server/                    # or api/
├── src/
│   ├── routes/
│   ├── services/
│   ├── models/
│   └── middleware/
├── tests/
└── README.md
```

### Option B — Separate repository

Keep this repo client-only; link the server repo URL in root `README.md` and task PRD.

---

## Client-side counterpart (Flutter)

API access should live under `lib/` (future):

```
lib/
├── models/
├── repositories/
└── providers/   # or bloc/
```

See [frontend/directory-structure.md](../frontend/directory-structure.md).

---

## Forbidden (placeholder phase)

- Fake `backend/` Dart files that are never called.
- Duplicating mock JSON in both `lib/` and a non-existent server.

---

## 团队备注

- 当前阶段：**禁止** 在无 PRD 的情况下新建后端目录。
- 若采用 Firebase/BaaS，可把「后端」写在 `lib/repositories/` + 安全规则文档，仍须更新本文件说明边界。
