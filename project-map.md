# DCMS Project Map

## Current state
Repository initialized with planning documents only. Flutter source has **not** yet been generated.

## Target modules
- app: router, theme, application composition
- core: database, errors, services, common widgets
- features/chargers: asset registry, QR, search, details
- features/owners: owner records
- features/locations: charger locations
- features/import: Excel mapping, preview, duplicate review
- features/backup: local export/restore
- features/audit: asset history and operator attribution

## Target dependencies
Flutter -> Riverpod / go_router -> repositories -> SQLite.
QR scanner and generator integrate with charger asset code.
Cloud integration deferred pending company permission.

## Change tracking
Update this map when modules, dependencies, database schema, or integration contracts change. Record cross-module impact before large refactors.
