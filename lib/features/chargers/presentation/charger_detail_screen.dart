import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/charger_repository.dart';
import '../data/charger_photo_repository.dart';
import 'charger_list_screen.dart';

final chargerDetailProvider = FutureProvider.family<Map<String, Object?>?, String>(
  (ref, id) => ref.read(chargerRepositoryProvider).getById(id),
);

final chargerPhotosProvider = FutureProvider.family<List<ChargerPhoto>, String>(
  (ref, id) => ref.read(chargerPhotoRepositoryProvider).forCharger(id),
);

class ChargerDetailScreen extends ConsumerStatefulWidget {
  const ChargerDetailScreen({super.key, required this.chargerId});

  final String chargerId;

  @override
  ConsumerState<ChargerDetailScreen> createState() => _ChargerDetailScreenState();
}

class _ChargerDetailScreenState extends ConsumerState<ChargerDetailScreen> {
  bool addingPhoto = false;

  Future<void> addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil foto dengan kamera'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    setState(() => addingPhoto = true);
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 82,
      );
      if (image == null) return;
      await ref.read(chargerPhotoRepositoryProvider).add(
            chargerId: widget.chargerId,
            selected: image,
            source: source,
          );
      ref.invalidate(chargerPhotosProvider(widget.chargerId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto disimpan di perangkat')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan foto: $error')),
      );
    } finally {
      if (mounted) setState(() => addingPhoto = false);
    }
  }

  Widget labelValue(String label, Object? value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 125, child: Text(label, style: const TextStyle(color: Colors.white70))),
            Expanded(child: Text(value?.toString().isNotEmpty == true ? value.toString() : 'Belum diisi')),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(chargerDetailProvider(widget.chargerId));
    final photos = ref.watch(chargerPhotosProvider(widget.chargerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Charger'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chargers'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Gagal memuat charger: $error')),
        data: (charger) {
          if (charger == null) return const Center(child: Text('Charger tidak ditemukan'));
          final id = charger['id'] as String;
          final code = charger['asset_code'] as String;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(code, style: Theme.of(context).textTheme.headlineMedium),
              Text('${charger['brand']} · ${charger['model'] ?? 'Model belum diisi'}'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go('/chargers/$id/edit'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Data Charger'),
              ),
              const SizedBox(height: 16),
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Identitas dan spesifikasi', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    labelValue('Asset Code', code),
                    labelValue('Serial', charger['serial_number']),
                    labelValue('Jenis', charger['charger_type']),
                    labelValue('Tegangan', charger['voltage'] == null ? null : '${charger['voltage']} V'),
                    labelValue('Arus', charger['current'] == null ? null : '${charger['current']} A'),
                    labelValue('Catatan', charger['notes']),
                    labelValue('Owner', charger['owner_id']),
                    labelValue('Lokasi', charger['location_id']),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('QR Code Aset', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Center(child: QrImageView(
                      data: 'dcms:charger:$id',
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    )),
                    const SizedBox(height: 8),
                    SelectableText(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Pindai menggunakan menu Scan DCMS', textAlign: TextAlign.center),
                  ],
                ),
              )),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: Text('Foto Charger', style: Theme.of(context).textTheme.titleLarge)),
                  OutlinedButton.icon(
                    onPressed: addingPhoto ? null : addPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(addingPhoto ? 'Menyimpan...' : 'Tambah Foto'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              photos.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Gagal memuat foto: $error'),
                data: (items) {
                  if (items.isEmpty) return const Text('Belum ada foto untuk charger ini.');
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final file = items[index].file;
                      return InkWell(
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (context) => Dialog(
                            child: InteractiveViewer(
                              child: Image.file(
                                file,
                                errorBuilder: (context, error, stack) =>
                                    const Center(child: Text('File foto tidak ditemukan')),
                              ),
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            file, fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const ColoredBox(
                                  color: Color(0xFF27374D),
                                  child: Center(child: Icon(Icons.broken_image_outlined)),
                                ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Foto disimpan privat di perangkat. Belum termasuk dalam backup/restore.'),
            ],
          );
        },
      ),
    );
  }
}
