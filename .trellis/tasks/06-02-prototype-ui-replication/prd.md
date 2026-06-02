# Prototype UI Replication

## Goal

Replicate the UI of the HTML prototype in `prototype/个人健身成长记录app` across the existing Flutter screens while preserving current business logic, navigation, reusable components, and the Firebase AI Coach integration.

## What I Already Know

* Prototype pages include `index.html`, `progress.html`, `plan.html`, `profile.html`, `nutrition.html`, `sleep.html`, `coach.html`, `future.html`, `insights.html`, `workout-detail.html`, and `design-system.html`.
* Flutter screens map to existing files under `lib/features/`: home, progress, plan, profile, nutrition/sleep, coach, future_you, and workout detail.
* Existing Firebase AI logic in `lib/features/coach/` must not be modified beyond UI framing/styling.
* Existing shared widgets such as `HandDrawnCard`, `HandDrawnButton`, `MuscleMap`, and theme tokens should remain in use.
* Current source contains some mojibake UI strings from prior prototype copy; these should be restored as UI text fixes where touched.

## Requirements

* Match the prototype's page structure, spacing, card style, colors, typography, labels, and decorative effects as closely as practical in Flutter.
* Preserve existing tab navigation and push navigation behavior.
* Preserve existing state management and AI Coach provider initialization.
* Keep shared styling in `lib/core/` and avoid introducing a new UI framework or architecture.
* Prioritize core pages first: Home, Plan, Progress, Profile, Nutrition/Sleep, Coach, and Workout Detail.

## Acceptance Criteria

* [x] Core Flutter screens visually follow their corresponding prototype HTML page.
* [x] Existing navigation paths still work: bottom tabs, Home category links to Nutrition/Sleep, Plan item opens Workout Detail, Profile settings opens Settings.
* [x] `lib/features/coach/` Firebase AI provider logic remains intact.
* [x] `flutter analyze` passes or remaining issues are clearly documented if unrelated.
* [x] `flutter test` is run or a reason is documented if blocked.

## Definition of Done

* Relevant frontend specs were read before code changes.
* UI updates are scoped to visual replication.
* No unrelated architecture or business logic changes are introduced.
* Quality checks are run.

## Technical Approach

Use the prototype design system as the source of truth: page background `#f4f3f9`, ink `#201381`, brand blue `#4d3cff`, soft line `#e7e4f4`, muted text `#5d5791`, white translucent panels, and soft shadows. Centralize new visual tokens in `AppColors`, then update existing screens with local private UI builders where needed.

## Out of Scope

* New product features, persistence, global state, or backend/API changes.
* Replacing Firebase AI Coach implementation.
* Pixel-perfect browser-to-Flutter rendering for every secondary prototype page in this first pass.
* Adding new image asset pipelines unless the current CustomPainter system cannot represent a required visual.

## Technical Notes

* Specs read: `.trellis/spec/frontend/index.md`, `directory-structure.md`, `component-guidelines.md`, `state-management.md`, `quality-guidelines.md`, `type-safety.md`.
* Prototype design tokens inspected from `prototype/个人健身成长记录app/design-system.html`.
* Existing relevant files inspected: `lib/core/theme.dart`, `lib/features/layout_shell.dart`, and all core feature screens.
* Implemented first-pass prototype replication for Home, Progress, Plan, Profile, Nutrition/Sleep, Coach, and Workout Detail.
* Added `lib/core/widgets/prototype_page.dart` for repeated prototype page/header/icon-button structure shared by multiple screens.
* Verification: `flutter analyze` and `flutter test` both pass.
