import 'dart:convert';

import 'package:doofy/screens/manual_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  bool _busy = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() => _busy = true);
    await _controller.stop();

    final ingredients = await _lookup(code);

    if (!mounted) return;

    if (ingredients == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product not found or has no ingredients listed. '
            'Try scanning the label instead.',
          ),
        ),
      );
      setState(() => _busy = false);
      await _controller.start();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManualInputScreen(initialText: ingredients),
      ),
    );

    // back from the result: allow scanning again
    if (!mounted) return;
    setState(() => _busy = false);
    await _controller.start();
  }

  Future<String?> _lookup(String barcode) async {
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode.json'
        '?fields=product_name,ingredients_text',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'Doofy/1.0 (student project)'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;

      final text = (data['product']?['ingredients_text'] as String?)?.trim();
      return (text == null || text.isEmpty) ? null : text;
    } catch (e) {
      debugPrint('Barcode lookup failed: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_busy) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
