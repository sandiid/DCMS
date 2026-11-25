# DCMS v1.0 — Approved Design Blueprint

## Product
Android workshop application to track forklift battery chargers, inspection/testing, component shortages, transfers, and repair workflows.

## Core business rules
- Each physical charger has a permanent UUID and human-readable asset code (e.g. CHG-0001).
- Manufacturer serial number is optional and never the primary key.
- Charging test PASS means the charger charged a compatible battery normally according to the approved procedure; PASS is distinct from ready-for-use.
- Charger ownership, operational location, priority, condition, and workflow status are separate dimensions.
- Component transfers must be traceable, compatible, and authorized according to ownership and component type.
- No external cloud storage of company/customer information before authorization.

## Milestone 1 — Foundation & Charger Inventory
Flutter Android + local SQLite, one-device pilot. Supabase is a possible future backend, not connected in M1.

### In scope
Registration, unique asset IDs, owner/location records, photos, QR generation and scanning, search, Excel import preview and duplicate review, backup/restore, local operator/audit model.

### Deferred
Full charging tests, parts transfers, procurement, multi-device sync, production multi-user authentication.

## Acceptance criteria
AC-01 Unique charger registration, serial optional.
AC-02 Required-field validation and incomplete data handling.
AC-03 Permanent QR asset identifier and label export.
AC-04 Correct QR lookup and searchable asset list.
AC-05 Ownership and location management.
AC-06 Offline photo attachment and retrieval.
AC-07 Excel import preview, mapping and duplicate review.
AC-08 Persistence after restart.
AC-09 Backup and tested restore including relevant photos.
AC-10 No company data uploads; secure local handling.
AC-11 Defined roles without claiming multi-user authentication.
AC-12 Asset create/update audit events.

## Public repository guardrails
Only source code, documentation, and synthetic examples. No real workshop/customer datasets, photographs, credentials, local database or backups.
