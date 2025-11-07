# Contributing to simple_permission_workflow

Thank you for contributing. This document summarizes the development, testing and PR workflow.

## Prerequisites
- Flutter SDK installed and on a compatible channel with the project.
- macOS (project development environment used) when testing platform integrations.
- Basic familiarity with Dart and Flutter testing.

## Local setup
1. Clone the repository and checkout `develop` (or your working branch).
2. Get dependencies:
```bash
flutter pub get
```
3. Run the analyzer and formatter:
```bash
flutter analyze
flutter format .
```

## Running tests
- Unit tests:
```bash
flutter test
```
- Important test notes:
  - Add `TestWidgetsFlutterBinding.ensureInitialized();` at the start of test `main()` to avoid binding errors.
  - Avoid calling platform `MethodChannel` code from tests. Use the factory injection (`SimplePermissionWorkflow({...})`) to provide `FakeService` implementations that implement `SPWPermissionService`.
  - For testing exceptions on Futures, use `expect(future, throwsA(...))` or `await expectLater(future, throwsA(...))` — do not `await` before `expect`.

## Writing tests
- Unit-test any new service under `services/impl/` by injecting factories.
- Prefer deterministic fakes over mocks that hit native plugins.
- Compare `SPWResponse` properties, not instance identity, unless `==` is implemented.

## Code style
- Follow idiomatic Dart/Flutter conventions.
- Run `flutter format` on changed files.
- Keep changes small and focused.

## Commit messages & branches
- Create a feature branch from `develop`: `feature/short-description`.
- Make atomic commits with clear messages.
- Rebase from `develop` as needed to keep branch up to date.

## Pull Requests
- Open PRs against `develop`.
- Include:
  - Short description of the change.
  - Link to any relevant issues.
  - New/updated tests demonstrating the fix or feature.
- The maintainer will run CI, review code, request changes if needed, and merge when approved.

## Issues
- Open an issue with a clear title, reproduction steps and relevant logs or test cases.

## Notes
- Do not introduce tests that call real `permission_handler` MethodChannels. Use factory injection and fakes.
- If adding UI for rationale, keep it optional and testable without rendering actual dialogs (use `BuildContext` injection where appropriate).

Thank you for your contribution!

