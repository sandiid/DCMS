import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_database.dart';

final chargerRepositoryProvider = Provider<ChargerRepository>(
  (ref) => ChargerRepository(),
);

class ChargerRepository {
  Future<List<Map<String, Object?>>> list({String query = ''}) async {
    final db = await LocalDatabase.instance.database;
    final term = query.trim();
    if (term.isEmpty) {
      return db.query('chargers', orderBy: 'asset_code ASC');
    }
    return db.query(
      'chargers',
      where: 'asset_code LIKE ? OR brand LIKE ? OR model LIKE ? OR serial_number LIKE ?',
      whereArgs: List.filled(4, '%$term%'),
      orderBy: 'asset_code ASC',
    );
  }

  Future<int> count() async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM chargers');
    return (rows.first['total'] as int?) ?? 0;
  }
}
