import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../chargers/data/charger_repository.dart';

final chargerCountProvider = FutureProvider<int>(
  (ref) => ref.read(chargerRepositoryProvider).count(),
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(chargerCountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('DCMS / Workshop')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total charger terdaftar'),
                  const SizedBox(height: 8),
                  count.when(
                    data: (value) => Text('$value', style: const TextStyle(fontSize: 36)),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Gagal memuat: $error'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go('/chargers'),
            icon: const Icon(Icons.battery_charging_full),
            label: const Text('Buka Charger Inventory'),
          ),
          const SizedBox(height: 12),
          const Text('Data tersimpan lokal di perangkat. Cloud belum aktif.'),
        ],
      ),
    );
  }
}
