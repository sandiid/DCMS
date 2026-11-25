import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/charger_repository.dart';

final chargerSearchProvider = StateProvider<String>((ref) => '');
final chargerListProvider = FutureProvider<List<Map<String, Object?>>>((ref) {
  final query = ref.watch(chargerSearchProvider);
  return ref.read(chargerRepositoryProvider).list(query: query);
});

class ChargerListScreen extends ConsumerWidget {
  const ChargerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chargers = ref.watch(chargerListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charger Inventory'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/chargers/new'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Charger'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) => ref.read(chargerSearchProvider.notifier).state = value,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Cari ID, merk, model, atau serial',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(child: chargers.when(
          data: (rows) => rows.isEmpty
              ? const Center(child: Text('Belum ada charger yang cocok.'))
              : ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return ListTile(
                      leading: const Icon(Icons.battery_charging_full),
                      title: Text(row['asset_code'] as String),
                      subtitle: Text('${row['brand']} · ${row['model'] ?? 'Model belum diisi'}'),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Gagal memuat: $error')),
        )),
      ]),
    );
  }
}
