import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/local_database.dart';

final chargerPhotoRepositoryProvider = Provider<ChargerPhotoRepository>(
  (ref) => ChargerPhotoRepository(),
);

class ChargerPhoto {
  const ChargerPhoto({
    required this.id,
    required this.file,
    required this.createdAt,
    required this.source,
  });

  final String id;
  final File file;
  final String createdAt;
  final String source;
}

class ChargerPhotoRepository {
  Future<Directory> _root() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, 'charger_photos'));
  }

  Future<List<ChargerPhoto>> forCharger(String chargerId) async {
    final db = await LocalDatabase.instance.database;
    final rows = await db.query(
      'charger_photos',
      where: 'charger_id = ?',
      whereArgs: [chargerId],
      orderBy: 'created_at DESC',
    );
    final root = await _root();
    return [
      for (final row in rows)
        ChargerPhoto(
          id: row['id'] as String,
          file: File(p.join(root.path, row['relative_path'] as String)),
          createdAt: row['created_at'] as String,
          source: row['source'] as String,
        ),
    ];
  }

  Future<void> add({
    required String chargerId,
    required XFile selected,
    required ImageSource source,
  }) async {
    final length = await selected.length();
    if (length > 10 * 1024 * 1024) {
      throw StateError('Foto lebih dari 10 MB. Pilih foto lain.');
    }
    final ext = p.extension(selected.path).toLowerCase();
    const supported = ['.jpg', '.jpeg', '.png', '.webp', '.heic'];
    if (!supported.contains(ext)) {
      throw StateError('Format foto tidak didukung: $ext');
    }
    final id = const Uuid().v4();
    final relative = p.join(chargerId, '$id$ext');
    final destination = File(p.join((await _root()).path, relative));
    await destination.parent.create(recursive: true);
    await selected.saveTo(destination.path);

    try {
      final db = await LocalDatabase.instance.database;
      await db.transaction((txn) async {
        final exists = await txn.query(
          'chargers', columns: ['id'], where: 'id = ?', whereArgs: [chargerId], limit: 1,
        );
        if (exists.isEmpty) throw StateError('Charger tidak ditemukan');
        final now = DateTime.now().toUtc().toIso8601String();
        await txn.insert('charger_photos', {
          'id': id, 'charger_id': chargerId, 'relative_path': relative,
          'source': source.name, 'created_at': now,
        });
        await txn.insert('charger_events', {
          'id': const Uuid().v4(), 'charger_id': chargerId,
          'event_type': 'photo_added', 'occurred_at': now,
          'details': 'Photo added from ${source.name}',
        });
      });
    } catch (_) {
      if (await destination.exists()) await destination.delete();
      rethrow;
    }
  }
}
