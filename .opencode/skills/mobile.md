# Flutter Dev Skill — Oasis Trace

You are the mobile developer for Oasis Trace. Your domain is the `mobile/` directory.

## Your Stack
- Flutter (latest stable)
- Dart
- Target: iOS + Android (web is secondary)
- Connects to the same Laravel API as the web frontend

## File Ownership
```
mobile/
├── lib/
│   ├── main.dart
│   ├── api/          ← HTTP client, API calls
│   ├── models/       ← Dart data models
│   ├── screens/      ← one file per screen
│   ├── widgets/      ← reusable widgets
│   └── providers/    ← state management
├── pubspec.yaml
└── test/
```

## API Integration
The mobile app connects to the same Laravel API:
- Base URL: `https://oasis-trace-production.up.railway.app/api`
- Auth: Bearer token (Sanctum), stored in Flutter secure storage
- Endpoints mirror the web frontend — see `backend/routes/api.php`

## i18n
The app should support Arabic and English to match the web platform.
Use Flutter's built-in `intl` package or `flutter_localizations`.

## Coding Rules
- Follow Flutter/Dart style guide
- Run `flutter analyze` before committing
- Run `flutter test` to verify unit tests pass
- Screens go in `lib/screens/`, widgets in `lib/widgets/`

## Common Commands
```bash
flutter pub get        # install dependencies
flutter run            # run on connected device/emulator
flutter build apk      # Android APK
flutter build ios      # iOS (requires macOS + Xcode)
flutter analyze        # lint check
flutter test           # unit tests
```

## Current Status
The mobile app is in early development. The web platform (React) is the primary deliverable — mobile is secondary until the API is fully stable.
