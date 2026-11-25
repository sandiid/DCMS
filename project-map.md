# DCMS Project Map

## Current implementation — M1.3 (source committed; build not yet verified)
- `lib/main.dart`: Riverpod ProviderScope bootstrap.
- `lib/app/app.dart`: dark theme and routes `/`, `/chargers`, `/chargers/new`, `/chargers/:id`, `/chargers/:id/edit`, `/scan`.
- `lib/core/database/local_database.dart`: SQLite schema v3; owners, locations, chargers, asset_counters, charger_events, charger_photos; migrations v1→v2→v3.
- `lib/features/chargers/data/charger_repository.dart`: list/search/count/create/read/update, immutable IDs, audit events.
- `lib/features/chargers/data/charger_photo_repository.dart`: app-private photo file persistence and SQLite photo metadata.
- `lib/features/chargers/presentation/charger_list_screen.dart`: inventory, search, detail links and QR scan entry.
- `lib/features/chargers/presentation/charger_create_screen.dart`: registration and edit form; existing UUID/asset_code kept unchanged.
- `lib/features/chargers/presentation/charger_detail_screen.dart`: specs, on-screen QR, camera/gallery upload and photo gallery.
- `lib/features/chargers/presentation/charger_scan_screen.dart`: camera QR scanning with offline asset UUID lookup.
- `lib/features/dashboard/presentation/dashboard_screen.dart`: local charger count and navigation.
- `docs/m1.3-test-plan.md`: test procedure, data security, photo backup gaps and QR format.

## Dependency and data flow
Flutter UI -> Riverpod providers -> ChargerRepository / ChargerPhotoRepository -> LocalDatabase -> SQLite.
ChargerPhotoRepository -> image_picker -> app documents/charger_photos -> SQLite relative path metadata.
QrImageView -> `dcms:charger:<uuid>` -> MobileScanner -> ChargerRepository.getById -> detail route.
go_router controls navigation; uuid generates stable charger/photo IDs.

## M1 remaining
Ownership/location selections, QR label export/printing, photo backup/restore, Excel import preview/dedup, operator attribution, offline security hardening, integration tests and build verification.

## Constraints and known risks
- No Flutter SDK build/analyze/device test performed by assistant; Android platform folders may need generating.
- Camera/QR plugin uses native Android capabilities; mobile_scanner 6.0.x needs compileSdk 34+.
- Single-device local SQLite; no cloud/multiuser sync.
- Private app files can be lost on uninstall or app-data clear. Backup/restore must cover BOTH SQLite and photo folder; Android OS auto backup must be explicitly reviewed/disabled for company-data use.
- Public GitHub contains only code/docs; no company/customer photos, files or credentials.
- Asset counters are only locally monotonic; future multi-device sync requires global collision strategy.

## Change policy
Update this map whenever modules, dependencies, schema, or integration contracts change.
