# DCMS — Data Charger Management System

Local-first Flutter Android application for tracking forklift battery chargers in a workshop.

## Development status
**Milestone 1.3 source committed; build and device tests pending.** Not approved for real company data.

## Implemented source
- Dashboard and searchable charger inventory
- Register and edit charger records; permanent UUID and sequential internal asset codes
- Charger detail view and on-screen QR generated from UUID
- Offline QR scanner with local SQLite lookup
- Camera/gallery photo attachments copied into app-private documents storage
- SQLite schema v3 with photo metadata, asset identifiers and basic audit events

## Planned next
- Ownership and location selection
- Printable/shareable QR labels
- Excel import with review/deduplication
- Reliable backup/restore covering SQLite **and** photos
- Operator attribution, app hardening, tests and Android builds

## Stack
Flutter/Dart, Riverpod, go_router, SQLite, image_picker, qr_flutter and mobile_scanner. No Supabase connection is active.

## Safety for public GitHub repository
Do not commit company/customer records, workshop spreadsheets, real charger photos, credentials, local databases, or backups. Only synthetic fixtures belong here. Private Android app files may be included in system backup unless OS/manifest policies are explicitly configured; this must be addressed before any company-data pilot.

## Docs
- [Setup](docs/setup.md)
- [Approved blueprint](docs/blueprint.md)
- [M1.3 test plan](docs/m1.3-test-plan.md)
- [Project map](project-map.md)
