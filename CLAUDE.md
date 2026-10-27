# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**TrainUp** — offline-only Flutter gym log (workout plans, set-by-set execution, history, load/body progress charts, global rest timer). No backend, no login, no network: all data lives in a local SQLite DB (Drift). Android/iOS ID `br.com.trainup.app`, Dart package `trainup`. The app was formerly called "Minha Ficha"; only the project folder and historical audit logs still carry that name.

The user writes in Portuguese (pt-BR). Reply in pt-BR; UI strings, code comments and docs are in pt-BR too.

## Environment and commands

**Windows host (current, since 2026-10-14):** no Flutter, Android SDK or Python on the host. Everything runs in Docker through `tool/docker_flutter.sh`, run from Git Bash. Docker Desktop must be running.

- The image is `ghcr.io/cirruslabs/flutter:stable` (Android SDK + Java). Flutter 3.47.6 lives in the volume `trainup-flutter-sdk`, and pub/Gradle caches in `trainup-pub-cache` / `trainup-gradle`.
- Commands:
  - `bash tool/docker_flutter.sh test --timeout 120s`
  - `bash tool/docker_flutter.sh analyze`
  - `bash tool/docker_flutter.sh build apk --debug`
  - `bash tool/docker_flutter.sh --shell 'dart format . && python3 tool/generate_privacy_html.py'`
- The working copy uses CRLF (`core.autocrlf=true`). Edit with the Edit tool, not with scripts that match `\n`.
- The release keystore and `key.properties` are not on this machine, so release builds are debug-signed.
- The Docker daemon also starts the containers of another project (`taredia-*`). Leave them alone.

The Linux notes below describe the original machine:

- Flutter SDK is **not on PATH**: `export PATH=~/development/flutter/bin:$PATH` (Flutter 3.47.6 / Dart 3.13).
- The host is Ubuntu 20.04 (glibc 2.31). The SQLite library bundled by `sqlite3` needs glibc 2.33, so **any test that opens a database fails on the host**. Run those in Docker:
  - Full suite: `tool/docker_test.sh` (same as `flutter test`, using the host SDK and pub-cache inside `ghcr.io/cirruslabs/flutter:stable`).
  - Single file or test: `tool/docker_test.sh test test/data/workout_session_repository_test.dart --plain-name "fluxo do MVP"`.
  - Pure-logic and fake-backed tests also run on the host: `flutter test test/unit/formatters_test.dart`. Those include `test/unit/*` except `timer_controller_test`, plus `test/widget/{timer_notice,workout_input_audit,publication_fixes,chart_audit}_test.dart`.
  - Use `--timeout 120s`: a hung widget test otherwise blocks for 10 minutes.
- Quality gate, which must stay clean (no `// ignore` to silence lints): `flutter pub get`, `dart format .`, `flutter analyze`, full suite in Docker.
- After changing `lib/core/database/tables.dart`: `dart run build_runner build`. The generated `app_database.g.dart` is committed.
- **Android builds**: there is no Android SDK or Java on the host. Build inside the local image `trainup-build:sdk-cache`, which already has NDK/CMake and runs as root. Always `chown` the outputs back to **uid 1001** (the user is 1001; uid 1000 does not exist). The pattern used:
  ```bash
  docker run --rm -e HOME=/tmp/audit-home -e PUB_CACHE=/home/wagner/.pub-cache \
    -v /home/wagner/.pub-cache:/home/wagner/.pub-cache -v /home/wagner/development/flutter:/home/wagner/development/flutter \
    -v "$PWD:$PWD" -w "$PWD" trainup-build:sdk-cache bash -c '
      trap "chown -R 1001:1001 build .dart_tool android ios docs /home/wagner/.pub-cache /home/wagner/development/flutter" EXIT
      git config --global --add safe.directory "*"
      /home/wagner/development/flutter/bin/flutter build appbundle --release'
  ```
  If such a container is killed, the trap does not run. Fix ownership with `docker run --rm -v "$PWD:/p" alpine chown -R 1001:1001 /p/...`. Do not touch other projects' containers.
- Release signing reads `android/key.properties` and `android/keystore/trainup-upload.jks`. Both are gitignored and must never be printed or published. Without them, release falls back to the debug key with a Gradle warning, and Play rejects that build.
- Generators (python3 + pycairo; no PIL on this host):
  - `tool/generate_icons.py`: all launcher, store and iOS icons from one geometry.
  - `tool/generate_store_assets.py`: Play feature graphic, using Roboto from the SDK via a temporary fontconfig.
  - `tool/generate_privacy_html.py`: `docs/legal/politica-de-privacidade.html` from the Dart policy text.
- No device or emulator is available. Widget tests are the only UI verification; say so when reporting.

## Architecture

Feature-first (`lib/features/<feature>/{data,domain,presentation}`), plus `lib/core` (database, router, theme, utils, widgets).

- **UI library is `package:material_ui/material_ui.dart`, not `package:flutter/material.dart`.** In Flutter 3.47, Material is a separate package and go_router 18 depends on it. Don't mix the two.
- **State**: Riverpod 3 without codegen.
  - Repositories are concrete classes over `AppDatabase`, exposed through `Provider`s. Reads are Drift `Stream`s, wrapped in `StreamProvider(.family)`, so writes refresh the UI automatically.
  - `main.dart` loads the profile flag, settings and timer state before `runApp` and injects them via overrides: `databaseProvider`, `onboardingStatusProvider`, `initialSettingsProvider`, `initialTimerSnapshotProvider`.
- **Navigation**: `lib/core/router/app_router.dart`.
  - `StatefulShellRoute` holds the 5 tabs. Secondary screens use the root navigator (`parentNavigatorKey: rootNavigatorKey`).
  - A redirect forces `/onboarding` until a profile exists. `/privacy` is exempt so the policy can be read before sign-up.
  - Use `Routes` for paths.
- **Plan vs. session**: plans (`workout_plans` → `workout_plan_exercises` → `workout_plan_sets`) are the plan. Starting a workout copies them into session tables (`workout_session_*`), with name/group snapshots. After that, sessions never depend on the plan, so editing or deleting plans or renaming exercises must not change history.
- **Session rules** (`workouts/data/workout_session_repository.dart`):
  - Every mutating method checks inside a transaction that the session is `running`.
  - Each set is persisted the moment it changes; there is no "save workout" step.
  - Only one running session is allowed.
- **Global rest timer** (`features/timer`):
  - `TimerSnapshot` stores status, duration, `startedAt` and `elapsedBefore`. The remaining time is always derived from the clock (`clockProvider`), which survives background and restarts.
  - One `TimerController` owns the only `Timer.periodic`, which exists only while the timer is running.
  - `TimerOverlay` sits in `MaterialApp.builder`, above the Navigator. It must always return the **same `Stack` structure**: swapping between `child` and `Stack` remounts the Navigator and loses screen state.
  - The button snaps to the nearest side. It only floats while a rest is active (running, paused or finished). It is hidden while the timer bottom sheet is open (`timerSheetOpenProvider`), while the keyboard is open, and while a screen has the timer docked (`timerDockedProvider`).
  - The running workout screen docks the same `TimerButton(docked: true)` in its bottom bar, with pause and +15s. It tracks visibility with `RouteAware` on `appRouteObserver`, which only fires for `PageRoute`s, so dialogs don't count. When the timer is idle, it is reached from the Home header (`home_timer`) or the workout dock.
  - Finishing or cancelling a workout resets the timer.
  - Sound: `AlertFeedback` plays `assets/sounds/rest_end.wav` via audioplayers (alarm usage, ducks other audio). The same file is at `android/app/src/main/res/raw/rest_end.wav` for the notification channel. Both come from `node tool/generate_rest_sound.js`. Android channel sound is immutable, so changing it means new channel ids (`_v3`…) and deleting the old ones in `RestAlarm._init`.
  - Locked screen/background: `app.dart` schedules a local notification (`RestAlarm`, flutter_local_notifications) on `onHide` and cancels it on `onShow`. In-app feedback is skipped on resume when the system alarm already fired. `RestAlarm` is a no-op outside Android/iOS, so tests need no override.
- **Platform I/O** (share sheet, file picker) goes through `fileSharingProvider` (`core/platform/file_sharing.dart`). Widget tests override it with a fake.
- **Plan export/import**: the JSON format is defined in `workout_plans/domain/plan_transfer.dart`, which has a `version` field. Exercises are matched by `normalizeName`. Import only adds plans and never overwrites.
- **Theme**: `core/theme/app_theme.dart`.
  - Brand colors live in `AppColors` (primary blue `#2563EB` / `#8AB4FF`; green = completed/progress; red only for errors).
  - The scheme is composed from Material 3 `fromSeed` variants, with custom cool-gray neutrals. Cards use `AppTheme.cardColor` (white in light mode, `surfaceContainerLow` in dark).
  - Shared tokens are `AppSpace`, `AppRadius` and `AppMotion` (`AppMotion.of` respects reduced motion), plus `AppButtons.destructive` and `.tabular` for numbers. Don't use loose numbers or uppercase labels.
  - Type scale: titles and numbers (`display*`, `headline*`, `titleLarge`) use Roboto Condensed Bold, bundled in `assets/fonts` under Apache 2.0, with its license registered in `main.dart`. Body text uses the system font, at weights 400 and 600.
  - Shared widgets:
    - `StatGrid` groups `StatTile`s in one panel.
    - `EmptyState` has primary and secondary actions.
    - `AsyncValueWidget`/`ErrorState` take `onRetry` and never show raw exceptions.
    - Failure snackbars go through `context.showError(action, e)`, which uses `friendlyError`.
    - Bottom actions use `ActionBar`, which stacks buttons when the width over the text scale is too small.
  - Layouts must hold at 320/360/390 pt with text scale 1.0/1.3/2.0. Use minimum heights, not fixed ones, on buttons with text. `SetRow`, the load cards and `ActionBar` switch to stacked layouts.
  - `test/unit/theme_contrast_test.dart` enforces WCAG contrast. Re-run it when changing colors.
- **Privacy policy**: the single source is `features/settings/domain/privacy_policy.dart`. Regenerate the HTML after edits; `test/unit/privacy_policy_test.dart` fails if the two diverge. The app collects no email (the column stays, written empty).

## Data rules

- `schemaVersion` is 2 (`AppDatabase.currentSchemaVersion`; v2 added `app_settings.weekly_goal`). `onUpgrade` runs explicit `_migrateStep` cases and throws on unknown versions. **Never recreate or drop tables.**
- To change the schema:
  1. Bump the version and add a step.
  2. Run `dart run build_runner build`, then `dart run drift_dev make-migrations`. This writes snapshots to `drift_schemas/` and test schemas to `test/drift/`.
  3. Extend `test/drift/app_database/migration_test.dart`. It was hand-edited, so don't let the generator template replace it.
- New column constraints go on the column (`.check(...)`), not in `customConstraints`, so they also apply to `addColumn` on migrated DBs.
- The DB file is `trainup.sqlite` in the app documents dir. `database_file.dart` renames the legacy `minha_ficha.sqlite` (and SQLite sidecar files) on first open. Never rename the file again without the same kind of migration.
- A completed set counts in volume, records, charts and "último treino" only if `repetitions > 0`. Keep that filter consistent in new queries.
- Plans and used exercises are soft-deleted (`is_active`). Exercise names are unique by `normalized_name`.
- Weights are stored in kg as doubles. Formatting (pt-BR, comma decimals) lives only in `core/utils/formatters.dart`. Use `formatRest` for rest periods; `formatDuration` drops seconds.

## Testing gotchas

- App-level widget tests:
  - Use the `settle()` helper (fixed number of pumps), not `pumpAndSettle`, because the running timer schedules frames continuously.
  - Register `tearDownWidgetsAndDatabase(tester, db)` from `test/helpers/test_database.dart`. It guarantees cleanup even when an assertion fails.
- DB work triggered by the UI runs in the fake-async zone and only progresses with `pump`. Don't poll the DB inside `tester.runAsync` while UI writes are pending: it deadlocks. Seed data with `runAsync` before pumping the app, and read results afterwards.
- `tester.pageBack()` doesn't find `material_ui` back buttons. Use `tester.tap(find.byType(BackButton))`.
- `matchesGoldenFile` writes images at logical size, and flutter_test replaces shadows with solid outlines (`debugDisableShadows`). For real-resolution captures, use `RenderRepaintBoundary.toImage(pixelRatio: …)` inside `runAsync` and load Roboto/MaterialIcons from `~/development/flutter/bin/cache/artifacts/material_fonts`.
- Screen captures:
  - `bash tool/docker_flutter.sh test test/screenshots --dart-define=CAPTURE_DIR=build/screenshots/after` renders the main screens in both themes at 360, 320×1.3 and 390×2.0. Without `CAPTURE_DIR`, the file is a no-op in the normal suite.
  - Demo data lives only in `test/helpers/demo_data.dart`.
  - The test fonts have no emoji or "→", which show as boxes. Devices fall back to system fonts.

## Docs

- `README.md`: features, colors, icon, build.
- `docs/architecture.md`: entities and flows.
- `docs/play-store/README.md`: publishing checklist, store texts, Play Console answers.
- `docs/audit-report.md` and `docs/publication-audit-report.md` are historical snapshots, not the current state.
