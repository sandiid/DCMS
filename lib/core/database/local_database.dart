import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), 'dcms.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE owners (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            owner_type TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE locations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            location_type TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE chargers (
            id TEXT PRIMARY KEY,
            asset_code TEXT NOT NULL UNIQUE,
            owner_id TEXT,
            location_id TEXT,
            brand TEXT NOT NULL,
            model TEXT,
            serial_number TEXT,
            charger_type TEXT,
            voltage REAL,
            current REAL,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(owner_id) REFERENCES owners(id),
            FOREIGN KEY(location_id) REFERENCES locations(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE charger_events (
            id TEXT PRIMARY KEY,
            charger_id TEXT NOT NULL,
            event_type TEXT NOT NULL,
            operator_id TEXT,
            occurred_at TEXT NOT NULL,
            details TEXT,
            FOREIGN KEY(charger_id) REFERENCES chargers(id)
          )
        ''');
        await db.execute('CREATE INDEX idx_chargers_brand ON chargers(brand)');
        await db.execute('CREATE INDEX idx_chargers_serial ON chargers(serial_number)');
      },
    );
    return _database!;
  }
}
