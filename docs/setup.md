# Development setup

1. Install Flutter SDK and Android SDK.
2. Clone `https://github.com/sandiid/DCMS.git`.
3. From the repository root run `flutter create --platforms=android .` to generate platform files (the Dart files and pubspec are already committed).
4. Run `flutter pub get`.
5. Run `flutter analyze` and `flutter run` on an Android device.

## Current limitations
- This is an initial source scaffold, not a tested Android build.
- Charger list is read-only; registration and QR functionality come next.
- SQLite schema is version 1, not yet a finalized production migration.
- No cloud upload, multi-user authentication, or real workshop data.
