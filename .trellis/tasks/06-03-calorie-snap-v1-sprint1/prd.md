# Calorie Snap V1.0 - Sprint 1

## Goal

Deliver Sprint 1 of the Calorie Snap V1.0 board: typed domain models, an analytics service skeleton, and tab shell verification. This unblocks Sprint 2-5 by establishing a stable contract layer.

## What I already know

* Feature-first Flutter app, `lib/features/` + `lib/core/`, no global state package yet, mostly `setState`.
* `Coach` still uses Firebase AI / Gemini; this Sprint must not break that.
* Event names and typed parameter models already drafted in `lib/core/analytics/`.
* Board guidance: see `docs/Calorie Snap V1.0-开发排期看板.md` and `docs/Calorie Snap V1.0产品级PRD-整合版.md`.

## In-Scope (Sprint 1)

| ID | Description | Status |
| --- | --- | --- |
| DATA-01 | Define typed models for `Meal`, `Nutrition`, `DailyNutritionSummary`, `CoachSession`, `CoachMessageEvent`. | doing |
| AN-01/02 | Add a minimal `AnalyticsService` plus a barrel file. Track events go through this service. | doing |
| FE-01 | Verify Nutrition / Coach / Progress entries resolve correctly in `LayoutShell`. No functional change. | doing |

## Out of Scope (deferred to later sprints)

* Persistence layer (Isar / shared_preferences).
* Snapshot UI states, camera integration, foreground extraction.
* Switching `Coach` to mock responses.
* Dashboard UI, calendar UI, meal detail UI.
* Any change to the Firebase AI / Gemini path in `ai_coach_provider.dart`.

## Acceptance Criteria

- [x] `lib/models/` exposes typed `Meal`, `Nutrition`, `DailyNutritionSummary`, `CoachSession`, `CoachMessageEvent` matching the field catalog.
- [x] `AnalyticsService` exposes `track(...)` and is the only path used by app code; no raw `print` for analytics in committed code.
- [x] `flutter analyze` passes with zero errors.
- [x] Existing `Coach` (Firebase) flow continues to render with no regression.
- [x] `flutter test` passes.
- [x] `LayoutShell` records `coach_open{source:tab}` when the user enters the Coach tab (FE-01 verification).

## Definition of Done

- Code review checklist: feature-first files, `AppColors` only, no duplicated theme, `super.key` for new widgets, `dispose` for controllers.
- `dart format lib test` on touched files.
- `flutter analyze` clean.

## Technical Notes

* Use const constructors where feasible, no `Map<String, dynamic>` in public APIs.
* Models go in `lib/models/` per the team rule (do not import `flutter/material.dart`).
* `AnalyticsService` is intentionally a logging-only stub to avoid hard SDK coupling; future sprints can swap implementation.
