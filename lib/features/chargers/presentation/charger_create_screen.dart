import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/charger_repository.dart';
import 'charger_detail_screen.dart';
import 'charger_list_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class ChargerCreateScreen extends ConsumerStatefulWidget {
  const ChargerCreateScreen({super.key, this.chargerId});

  final String? chargerId;

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
  bool loading = false;
  String? loadError;

  @override
  void initState() {
    super.initState();
    if (widget.chargerId != null) {
      loading = true;
      loadCharger();
    }
  }

  Future<void> loadCharger() async {
    try {
      final row = await ref.read(chargerRepositoryProvider).getById(widget.chargerId!);
      if (!mounted) return;
      if (row == null) {
        setState(() { loadError = 'Charger tidak ditemukan'; loading = false; });
        return;
      }
      brand.text = row['brand'] as String? ?? '';
      model.text = row['model'] as String? ?? '';
      serial.text = row['serial_number'] as String? ?? '';
      voltage.text = row['voltage']?.toString() ?? '';
      current.text = row['current']?.toString() ?? '';
      notes.text = row['notes'] as String? ?? '';
      setState(() {
        chargerType = row['charger_type'] as String? ?? 'unknown';
        if (!['unknown', 'transformer', 'hf'].contains(chargerType)) chargerType = 'unknown';
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() { loadError = error.toString(); loading = false; });
    }
  }

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
  Widget build(BuildContext context) {
    final editing = widget.chargerId != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Charger' : 'Tambah Charger')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(child: Text(loadError!))
              : Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (editing)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('ID aset dan QR Code tidak akan berubah.'),
                        ),
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
                        label: Text(saving ? 'Menyimpan...' : editing ? 'Simpan Perubahan' : 'Simpan Charger'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final repository = ref.read(chargerRepositoryProvider);
      final id = widget.chargerId;
      if (id == null) {
        final code = await repository.create(
          brand: brand.text.trim(), model: model.text.trim(),
          serialNumber: serial.text.trim(), chargerType: chargerType,
          voltage: parseOptional(voltage.text), current: parseOptional(current.text),
          notes: notes.text.trim(),
        );
        ref.invalidate(chargerListProvider);
        ref.invalidate(chargerCountProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Charger $code berhasil disimpan')));
        context.go('/chargers');
      } else {
        await repository.update(
          id: id, brand: brand.text.trim(), model: model.text.trim(),
          serialNumber: serial.text.trim(), chargerType: chargerType,
          voltage: parseOptional(voltage.text), current: parseOptional(current.text),
          notes: notes.text.trim(),
        );
        ref.invalidate(chargerListProvider);
        ref.invalidate(chargerDetailProvider(id));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data charger berhasil diperbarui')),
        );
        context.go('/chargers/$id');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
