import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/charger_repository.dart';

class ChargerScanScreen extends ConsumerStatefulWidget {
  const ChargerScanScreen({super.key});

  @override
  ConsumerState<ChargerScanScreen> createState() => _ChargerScanScreenState();
}

class _ChargerScanScreenState extends ConsumerState<ChargerScanScreen> {
  bool handling = false;

  Future<void> onDetected(BarcodeCapture capture) async {
    if (handling) return;
    final values = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>();
    if (values.isEmpty) return;
    final value = values.first.trim();
    const prefix = 'dcms:charger:';
    if (!value.startsWith(prefix)) return;
    final id = value.substring(prefix.length);
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(id)) return;
    setState(() => handling = true);
    try {
      final charger = await ref.read(chargerRepositoryProvider).getById(id);
      if (!mounted) return;
      if (charger != null) {
        context.go('/chargers/$id');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR valid, tetapi charger tidak ada di database lokal')),
        );
        setState(() => handling = false);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencari charger: $error')),
      );
      setState(() => handling = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Charger'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/chargers'),
          ),
        ),
        body: Stack(
          children: [
            MobileScanner(onDetect: onDetected),
            const Positioned(
              left: 20, right: 20, bottom: 32,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Arahkan kamera ke QR Code DCMS. Data dibaca dari perangkat ini.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
