# Logging Guidelines

> Structured logging for server and client diagnostics.

---

## Current status: not applicable (server)

No server logs. Flutter app does not define a logging package yet.

---

## When you add a backend

Specify:

| Item | Rule |
|------|------|
| **Format** | JSON structured logs preferred |
| **Levels** | DEBUG / INFO / WARN / ERROR usage |
| **PII** | Never log passwords, tokens, full health payloads |
| **Correlation** | Request id per HTTP call |

---

## Flutter (optional future)

If adding client logging:

- Use `dart:developer` `log()` or `logger` package per PRD.
- `debugPrint` only for dev; strip verbose logs in release.
- No `print()` in committed code — see [frontend/quality-guidelines.md](../frontend/quality-guidelines.md).

---

## Forbidden

- Logging entire request bodies with health data without redaction policy.

---

## 团队备注

- 原型阶段可不引入日志库；上线前再定 Firebase Crashlytics / Sentry 等。
