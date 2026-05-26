# Error Handling

> How errors are caught, logged, and returned.

---

## Current status: not applicable

No HTTP API or server processes. Flutter UI uses `SnackBar` for placeholder feedback only.

---

## When you add an API

Document:

| Layer | Convention |
|-------|------------|
| **HTTP** | Stable status codes; JSON error body `{ "code", "message", "details?" }` |
| **Server** | Central exception handler; no stack traces to clients in production |
| **Flutter** | Map errors in `repository` → UI shows user-safe message |
| **Retry** | Idempotent GET retry; POST with care |

Example client pattern (future):

```dart
// repository — not in widgets
try {
  return await _client.fetchPlan();
} on ApiException catch (e) {
  throw UserFacingException(e.message);
}
```

---

## UI today

- Placeholder: `ScaffoldMessenger.showSnackBar` (e.g. category not implemented).
- Do not add fake `try/catch` around mock lists.

---

## Forbidden

- Swallowing errors with empty `catch (_) {}`.
- Showing raw exception strings to users in production builds.

---

## 团队备注

- 接 API 后：网络错误、401、业务错误要区分文案（中文/英文与产品统一）。
- AI 教练接口需单独定义超时与降级（本地提示 vs 重试）。
