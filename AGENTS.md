# Repository Guidelines

## Project Structure & Module Organization
This repository is a Flutter app for generating NordLynx/WireGuard profiles.

- `lib/main.dart`: UI, input flow, file save/copy actions.
- `lib/src/`: core domain logic (`nordvpn_api.dart`, `wireguard_profile.dart`, `models.dart`).
- `test/`: unit tests for API client and profile generation (`*_test.dart`).
- Platform runners: `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`.
- Root config: `pubspec.yaml`, `analysis_options.yaml`, `README.md`.

Keep business logic in `lib/src/` and keep widget code in `lib/main.dart` (or future UI-focused files).

## Build, Test, and Development Commands
- `flutter pub get`: install/update dependencies.
- `flutter run`: run the app on the selected device.
- `flutter analyze`: run static analysis using `flutter_lints`.
- `flutter test`: run all tests in `test/`.
- `dart format lib test`: apply standard Dart formatting before opening a PR.
- `flutter build <target>`: create release artifacts (example: `flutter build windows`).

## Coding Style & Naming Conventions
Follow Dart + Flutter defaults and `analysis_options.yaml` (`package:flutter_lints/flutter.yaml`).

- Use 2-space indentation and keep code `dart format` clean.
- File names: `snake_case.dart`.
- Classes/enums: `PascalCase`; methods/variables: `lowerCamelCase`.
- Prefer small, focused methods in `lib/src/` for testability.
- Keep user-facing messages clear; current UI strings are primarily Japanese, so keep language usage consistent when editing nearby text.

## Testing Guidelines
Use `flutter_test` (and `http/testing` mocks where needed) for unit tests.

- Place tests under `test/` and name files `*_test.dart`.
- Name tests by behavior (example: `fetchServiceCredentials retries auth header formats`).
- Add tests for any change to parsing, API error handling, or WireGuard config generation.
- No formal coverage gate exists yet; maintain or improve coverage in touched modules.

## Commit & Pull Request Guidelines
There is currently no commit history in this repository, so use Conventional Commit style going forward.

- Commit format: `type(scope): summary` (example: `feat(api): add country filter validation`).
- Keep commits focused and atomic.
- PRs should include: change summary, test evidence (`flutter test`, `flutter analyze`), and screenshots/GIFs for UI updates.
- Link related issues and call out any API behavior assumptions or security-sensitive changes.

## Security & Configuration Tips
- Never commit NordVPN access tokens, generated `.conf` files, or other secrets.
- Treat API responses and saved profiles as sensitive data in logs and screenshots.
