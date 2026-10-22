import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../database/db_helper.dart';

class ScanBarcode extends StatefulWidget {
  final int stationId;
  const ScanBarcode({super.key, required this.stationId});

  @override
  State<ScanBarcode> createState() => _ScanBarcodeState();
}

class _ScanBarcodeState extends State<ScanBarcode> {
  bool _processed = false;

  Future<void> _process(String barcode) async {
    if (_processed) return;
    _processed = true;

    final db = await DBHelper.instance.database;
    final res = await db.query(
      'bookings',
      where: 'barcode = ? AND station_id = ? AND status = ?',
      whereArgs: [barcode, widget.stationId, 'pending'],
    );

    if (res.isEmpty) {
      _show('باركود غير صالح أو تمت معالجته مسبقاً', false);
      return;
    }

    await db.update(
      'bookings',
      {'status': 'filled'},
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    // خصم من المتبقي
    await db.rawUpdate(
      'UPDATE stations SET remaining_liters = remaining_liters - 40 WHERE id = ?',
      [widget.stationId],
    );

    _show('تمت التعبئة ✓', true);
  }

  void _show(String msg, bool success) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? 'نجح' : 'خطأ'),
        content: Text(msg),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسح الباركود')),
      body: MobileScanner(
        onDetect: (capture) {
          final code = capture.barcodes.first.rawValue;
          if (code != null) _process(code);
        },
      ),
    );
  }
}
