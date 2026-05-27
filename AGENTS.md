<!-- TRELLIS:START -->
# Trellis Instructions

These instructions are for AI assistants working in this project.

This project is managed by Trellis. The working knowledge you need lives under `.trellis/`:

- `.trellis/workflow.md` — development phases, when to create tasks, skill routing
- `.trellis/spec/` — package- and layer-scoped coding guidelines (read before writing code in a given layer)
- `.trellis/workspace/` — per-developer journals and session traces
- `.trellis/tasks/` — active and archived tasks (PRDs, research, jsonl context)

## 技能目录 (Agent Skills)

本模块集成了专门针对 Dart 和 Flutter 开发优化的技能 (Skills)，旨在提升 AI 助手在特定任务中的准确性。

### Flutter UI & 架构
- **[架构最佳实践](file:///d:/Logic-of-Hashira/.agents/skills/flutter-apply-architecture-best-practices/SKILL.md)**: 推荐的 UI、Logic、Data 分层架构。
- **[布局问题修复](file:///d:/Logic-of-Hashira/.agents/skills/flutter-fix-layout-issues/SKILL.md)**: 针对 Overflow、Unbounded constraints 等布局错误的诊断与修复。
- **[响应式布局构建](file:///d:/Logic-of-Hashira/.agents/skills/flutter-build-responsive-layout/SKILL.md)**: 使用 LayoutBuilder 和 MediaQuery 构建适配多端的 UI。
- **[声明式路由配置](file:///d:/Logic-of-Hashira/.agents/skills/flutter-setup-declarative-routing/SKILL.md)**: 基于 go_router 等包的高级 URL 导航配置。
- **[国际化配置](file:///d:/Logic-of-Hashira/.agents/skills/flutter-setup-localization/SKILL.md)**: 快速初始化 flutter_localizations 与 intl。

### 自动化测试
- **[Dart 单元测试](file:///d:/Logic-of-Hashira/.agents/skills/dart-add-unit-test/SKILL.md)**: 使用 `package:test` 编写函数与类逻辑测试。
- **[Widget 测试](file:///d:/Logic-of-Hashira/.agents/skills/flutter-add-widget-test/SKILL.md)**: 使用 `WidgetTester` 验证 UI 渲染与用户交互。
- **[集成测试](file:///d:/Logic-of-Hashira/.agents/skills/flutter-add-integration-test/SKILL.md)**: 配置 Flutter Driver 进行端到端自动化测试。
- **[生成测试 Mock](file:///d:/Logic-of-Hashira/.agents/skills/dart-generate-test-mocks/SKILL.md)**: 使用 mockito 模拟外部依赖。
- **[收集覆盖率](file:///d:/Logic-of-Hashira/.agents/skills/dart-collect-coverage/SKILL.md)**: 生成并分析 LCOV 报告。

### 开发工具与效率
- **[静态代码分析](file:///d:/Logic-of-Hashira/.agents/skills/dart-run-static-analysis/SKILL.md)**: 执行 `dart analyze` 并自动修复 Lint 问题。
- **[运行时错误修复](file:///d:/Logic-of-Hashira/.agents/skills/dart-fix-runtime-errors/SKILL.md)**: 基于堆栈轨迹自动定位并修复运行时崩溃。
- **[包冲突解决](file:///d:/Logic-of-Hashira/.agents/skills/dart-resolve-package-conflicts/SKILL.md)**: 解决 pub get 时的版本依赖冲突。
- **[JSON 序列化实现](file:///d:/Logic-of-Hashira/.agents/skills/flutter-implement-json-serialization/SKILL.md)**: 手动或自动生成从 JSON 到 Model 的映射。
- **[HTTP 网络请求](file:///d:/Logic-of-Hashira/.agents/skills/flutter-use-http-package/SKILL.md)**: 基于 http 包的 REST API 调用模式。

If a Trellis command is available on your platform (e.g. `/trellis:finish-work`, `/trellis:continue`), prefer it over manual steps. Not every platform exposes every command.

If you're using Codex or another agent-capable tool, additional project-scoped helpers may live in:
- [技能定义](file:///d:/Logic-of-Hashira/.agents/skills/) — 可复用的 Trellis 技能集。
- `.codex/agents/` — 可选的自定义子代理。

## Subagents

- ALWAYS wait for every spawned subagent to reach a terminal status before yielding, acting on partial results, or spawning followups.
  - On Codex, this means calling the `wait` tool with the subagent's thread id (requires `multi_agent_v2`). Do NOT infer completion from elapsed time.
  - On Claude Code / OpenCode, this means awaiting the Task/agent tool result before continuing.
- NEVER cancel or re-spawn a subagent that hasn't finished. If a subagent appears stuck, raise the wait timeout (Codex default 30s, max 1h) before judging it broken.
- Spawn subagents automatically when:
  - Parallelizable work (e.g., install + verify, npm test + typecheck, multiple tasks from plan)
  - Long-running or blocking tasks where a worker can run independently
  - Isolation for risky changes or checks

Managed by Trellis. Edits outside this block are preserved; edits inside may be overwritten by a future `trellis update`.

<!-- TRELLIS:END -->
