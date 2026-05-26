# Backend Quality Guidelines

> Code quality for server-side work.

---

## Current status: not applicable

No server code to lint or test. Client quality rules: [frontend/quality-guidelines.md](../frontend/quality-guidelines.md).

---

## When you add a backend

Define in this file:

| Check | Example |
|-------|---------|
| **Lint / format** | `ruff`, `eslint`, `golangci-lint`, etc. |
| **Unit tests** | Services and domain logic |
| **Integration tests** | API contracts, DB test container |
| **CI** | Same pipeline or separate workflow from Flutter |

Minimum bar:

- All endpoints covered by contract test or integration test.
- Migrations run in CI before deploy.

---

## Client integration tests

When API exists:

- Mock `http` / use `mockito` in `repository` tests.
- Widget tests stay offline — see `test/widget_test.dart`.

---

## Forbidden

- Deploying without migration strategy.
- Sharing production DB credentials in repo.

---

## 团队备注

- Flutter 侧：`flutter analyze` + `flutter test` 已作为前端质量门槛；后端 CI 应独立配置，避免只跑客户端流水线。
