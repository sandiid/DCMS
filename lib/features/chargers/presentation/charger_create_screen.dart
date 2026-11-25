import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/charger_repository.dart';
import 'charger_list_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class ChargerCreateScreen extends ConsumerStatefulWidget {
  const ChargerCreateScreen({super.key});

  @override
  ConsumerState<ChargerCreateScreen> createState() => _ChargerCreateScreenState();
}

class _ChargerCreateScreenState extends ConsumerState<ChargerCreateScreen> {
  final formKey = GlobalKey<FormState>();
  final brand = TextEditingController();
  final model = TextEditingController();
  final serial = TextEditingController();
  final voltage = TextEditingController();
  final current = TextEditingController();
  final notes = TextEditingController();
  String chargerType = 'unknown';
  bool saving = false;

  @override
  void dispose() {
    for (final c in [brand, model, serial, voltage, current, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  double? parseOptional(String value) =>
      value.trim().isEmpty ? null : double.tryParse(value.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tambah Charger')),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: brand,
                decoration: const InputDecoration(labelText: 'Merk *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Merk wajib diisi' : null,
              ),
              TextFormField(controller: model, decoration: const InputDecoration(labelText: 'Model (opsional)')),
              TextFormField(controller: serial, decoration: const InputDecoration(labelText: 'Serial number (opsional)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: chargerType,
                decoration: const InputDecoration(labelText: 'Jenis charger'),
                items: const [
                  DropdownMenuItem(value: 'unknown', child: Text('Belum diketahui')),
                  DropdownMenuItem(value: 'transformer', child: Text('Transformer / konvensional')),
                  DropdownMenuItem(value: 'hf', child: Text('High Frequency (HF)')),
                ],
                onChanged: (v) => setState(() => chargerType = v ?? 'unknown'),
              ),
              TextFormField(
                controller: voltage,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Tegangan nominal (V)'),
                validator: (v) => v != null && v.trim().isNotEmpty &&
                        (parseOptional(v) == null || parseOptional(v)! <= 0)
                    ? 'Masukkan tegangan positif yang valid'
                    : null,
              ),
              TextFormField(
                controller: current,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Arus nominal (A)'),
                validator: (v) => v != null && v.trim().isNotEmpty &&
                        (parseOptional(v) == null || parseOptional(v)! <= 0)
                    ? 'Masukkan arus positif yang valid'
                    : null,
              ),
              TextFormField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: const Icon(Icons.save),
                label: Text(saving ? 'Menyimpan...' : 'Simpan Charger'),
              ),
            ],
          ),
        ),
      );

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final code = await ref.read(chargerRepositoryProvider).create(
            brand: brand.text.trim(),
            model: model.text.trim(),
            serialNumber: serial.text.trim(),
            chargerType: chargerType,
            voltage: parseOptional(voltage.text),
            current: parseOptional(current.text),
            notes: notes.text.trim(),
          );
      ref.invalidate(chargerListProvider);
      ref.invalidate(chargerCountProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Charger $code berhasil disimpan')));
      context.go('/chargers');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
