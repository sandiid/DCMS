# DCMS Android development setup

## Prerequisites
- Flutter SDK and Android SDK / Android Studio
- Dart compatible with project pubspec (Dart 3.4+, package resolution may require newer Flutter)
- Android compileSdk >= 34 for mobile_scanner 6.0.x

## First-time setup
```powershell
git clone https://github.com/sandiid/DCMS.git
cd DCMS
flutter create --platforms=android .
flutter pub get
flutter analyze
flutter run
```

If you already cloned:
```powershell
cd DCMS
git pull origin main
flutter pub get
flutter analyze
flutter run
```
Generate Android platform files only if missing. Review generated files before replacing any local customization.

## Current features
- Dashboard showing local charger count
- Charger registration and read-only inventory search
- Charger details and edit (asset UUID/asset code immutable)
- QR display and offline camera scan
- Multiple locally stored charger photos from camera/gallery

## Critical Android data privacy
Before entering real company/customer data, obtain company permission and review the generated Android manifest:
- Inside the `<application>` element of `android/app/src/main/AndroidManifest.xml`, set `android:allowBackup="false"`.
- For Android 12 and above also review data extraction rules and device-transfer settings; Android's default OS backup policies are not necessarily equivalent to app-level "local-only" intent.
- Photos live in private application documents and may be deleted on uninstall or clearing app data.
- Reliable database + photo directory backup/restore has **not yet been implemented**. Do not treat this version as safe for real records.
- Never commit real charger/customer photos, local SQLite DB or backups to this public repository.

## M1.3 test plan
See [m1.3-test-plan.md](m1.3-test-plan.md) for detailed smoke tests.

## Known limitations
Build/analyze and physical Android tests have not been performed by assistant.
The project is single-device local-first; no cloud, multi-user authentication, owner/location selector, QR label export, or reliable backup/restore yet.
