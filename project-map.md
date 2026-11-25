# DCMS Project Map

## Current implementation (M1.1 scaffold)
- `lib/main.dart`: ProviderScope bootstrap.
- `lib/app/app.dart`: MaterialApp.router, dark theme, go_router routes.
- `lib/core/database/local_database.dart`: local SQLite schema v1 for owners, locations, chargers and charger_events.
- `lib/features/chargers/data/charger_repository.dart`: list/search/count queries.
- `lib/features/chargers/presentation/charger_list_screen.dart`: read-only charger list and search.
- `lib/features/dashboard/presentation/dashboard_screen.dart`: live local charger count and inventory navigation.
- `pubspec.yaml`: Flutter dependencies.
- `docs/setup.md`: instructions to generate Android platform scaffold locally.

## Dependency flow
UI -> Riverpod providers -> ChargerRepository -> LocalDatabase -> SQLite.
go_router controls dashboard/inventory navigation.

## Planned next changes
1. Charger registration with validated fields and stable UUID/asset_code generation.
2. Owner/location selection and charger detail.
3. QR generation and scan.
4. Photo attachments, import, backup/restore, audit.

## Limitations
No Flutter SDK build/analyze run yet. Android platform folders need generating with `flutter create --platforms=android .`.
Cloud integration disabled pending company approval. Public repo must contain only synthetic data.

## Change policy
Update this map whenever code modules, dependencies, database schema or integration contracts change.
