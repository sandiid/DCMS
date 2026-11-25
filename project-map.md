# DCMS Project Map

## Current implementation (M1.2 source, not build-verified)
- `lib/main.dart`: Riverpod ProviderScope bootstrap.
- `lib/app/app.dart`: dark theme and routes `/`, `/chargers`, `/chargers/new`.
- `lib/core/database/local_database.dart`: SQLite schema v2, foreign keys, charger/owner/location/events, asset counter and v1 migration.
- `lib/features/chargers/data/charger_repository.dart`: charger list/search/count/create, atomic ID allocation and audit creation.
- `lib/features/chargers/presentation/charger_list_screen.dart`: searchable inventory and add action.
- `lib/features/chargers/presentation/charger_create_screen.dart`: validated charger form, save and refresh.
- `lib/features/dashboard/presentation/dashboard_screen.dart`: live charger count and navigation.

## Dependencies
Flutter UI -> Riverpod providers -> ChargerRepository -> LocalDatabase -> SQLite.
go_router controls navigation; uuid generates local IDs.

## Remaining M1 scope
Ownership/location selectors, charger detail/edit, QR, photos, Excel import, backup/restore, operator attribution and tests.

## Risks and limitations
- Source commits have not passed `flutter analyze` or an Android build in this environment.
- Android platform scaffold must be generated with `flutter create --platforms=android .`.
- Single-device local-first; no cloud, no production multi-user login.
- No real customer/workshop data in this public repository.
- The asset counter is monotonic within a single SQLite database, not globally unique across independent offline devices; future sync requires a separate collision strategy.

## Change policy
Update this map whenever modules, schema, dependencies or integration contracts change.
