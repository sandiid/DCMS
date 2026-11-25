import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/local_database.dart';

final chargerRepositoryProvider = Provider<ChargerRepository>((ref) => ChargerRepository());

class ChargerRepository {
  Future<List<Map<String, Object?>>> list({String query = ''}) async {
    final db = await LocalDatabase.instance.database;
    final term = query.trim();
    if (term.isEmpty) return db.query('chargers', orderBy: 'asset_code ASC');
    return db.query('chargers',
      where: 'asset_code LIKE ? OR brand LIKE ? OR model LIKE ? OR serial_number LIKE ?',
      whereArgs: List.filled(4, '%$term%'),
      orderBy: 'asset_code ASC');
  }

  Future<int> count() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM chargers');
    return (rows.first['total'] as int?) ?? 0;
  }

  Future<Map<String, Object?>?> getById(String id) async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query('chargers', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> update({
    required String id,
    required String brand,
    required String model,
    required String serialNumber,
    required String chargerType,
    required double? voltage,
    required double? current,
    required String notes,
  }) async {
    if (brand.trim().isEmpty) throw ArgumentError('Merk wajib diisi');
    if (voltage != null && (!voltage.isFinite || voltage <= 0)) throw ArgumentError('Tegangan tidak valid');
    if (current != null && (!current.isFinite || current <= 0)) throw ArgumentError('Arus tidak valid');
    final db = await LocalDatabase.instance.database;
    await db.transaction((txn) async {
      final previous = await txn.query('chargers', where: 'id = ?', whereArgs: [id], limit: 1);
      if (previous.isEmpty) throw StateError('Charger tidak ditemukan');
      final values = <String, Object?>{
        'brand': brand.trim(), 'model': model.trim().isEmpty ? null : model.trim(),
        'serial_number': serialNumber.trim().isEmpty ? null : serialNumber.trim(),
        'charger_type': chargerType, 'voltage': voltage, 'current': current,
        'notes': notes.trim().isEmpty ? null : notes.trim(),
      };
      final changed = values.keys.where((key) => previous.first[key] != values[key]).toList();
      if (changed.isEmpty) return;
      final now = DateTime.now().toUtc().toIso8601String();
      await txn.update('chargers', {...values, 'updated_at': now}, where: 'id = ?', whereArgs: [id]);
      await txn.insert('charger_events', {
        'id': const Uuid().v4(), 'charger_id': id, 'event_type': 'updated',
        'occurred_at': now, 'details': 'Updated fields: ${changed.join(', ')}',
      });
    });
  }

  Future<String> create({
    required String brand,
    required String model,
    required String serialNumber,
    required String chargerType,
    required double? voltage,
    required double? current,
    required String notes,
  }) async {
    if (brand.trim().isEmpty) throw ArgumentError('Merk wajib diisi');
    if (voltage != null && (!voltage.isFinite || voltage <= 0)) throw ArgumentError('Tegangan tidak valid');
    if (current != null && (!current.isFinite || current <= 0)) throw ArgumentError('Arus tidak valid');
    final db = await LocalDatabase.instance.database;
    return db.transaction((txn) async {
      // Serialized SQLite transaction prevents duplicate codes on this device.
      final result = await txn.rawQuery('SELECT COALESCE(MAX(seq), 0) AS last_seq FROM asset_counters');
      final next = ((result.first['last_seq'] as int?) ?? 0) + 1;
      await txn.insert('asset_counters', {'seq': next});
      final code = 'CHG-${next.toString().padLeft(4, '0')}';
      final id = const Uuid().v4();
      final now = DateTime.now().toUtc().toIso8601String();
      await txn.insert('chargers', {
        'id': id, 'asset_code': code, 'brand': brand.trim(),
        'model': model.isEmpty ? null : model,
        'serial_number': serialNumber.isEmpty ? null : serialNumber,
        'charger_type': chargerType, 'voltage': voltage, 'current': current,
        'notes': notes.isEmpty ? null : notes, 'created_at': now, 'updated_at': now,
      });
      await txn.insert('charger_events', {
        'id': const Uuid().v4(), 'charger_id': id,
        'event_type': 'created', 'occurred_at': now,
        'details': 'Charger registered locally; operator not authenticated',
      });
      return code;
    }, exclusive: true);
  }
}
