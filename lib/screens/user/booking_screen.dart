import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import '../../models/station.dart';

class BookingScreen extends StatefulWidget {
  final int userId;
  final StationModel station;
  const BookingScreen({super.key, required this.userId, required this.station});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _barcode;
  int? _group;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _book();
  }

  Future<void> _book() async {
    final db = await DBHelper.instance.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // تحقق من حجز اليوم
    final existing = await db.query(
      'bookings',
      where: 'user_id = ? AND booking_date = ?',
      whereArgs: [widget.userId, today],
    );

    if (existing.isNotEmpty) {
      final b = existing.first;
      setState(() {
        _barcode = b['barcode'] as String;
        _group = b['group_number'] as int;
        _loading = false;
      });
      return;
    }

    // جلب سيارة المستخدم
    final vehicles = await db.query(
      'vehicles',
      where: 'user_id = ? AND status = ?',
      whereArgs: [widget.userId, 'approved'],
    );

    if (vehicles.isEmpty) {
      setState(() {
        _error = 'لا توجد مركبة معتمدة';
        _loading = false;
      });
      return;
    }

    // احسب المجموعة بناءً على عدد الحجوزات في هذه المحطة اليوم
    final count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM bookings WHERE station_id = ? AND booking_date = ?',
          [widget.station.id, today],
        )) ??
        0;

    final group = (count ~/ 200) + 1;
    final barcode = const Uuid().v4();

    await db.insert('bookings', {
      'user_id': widget.userId,
      'station_id': widget.station.id,
      'vehicle_id': vehicles.first['id'],
      'booking_date': today,
      'group_number': group,
      'barcode': barcode,
      'status': 'pending',
    });

    setState(() {
      _barcode = barcode;
      _group = group;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حجزك في ${widget.station.name}')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('المجموعة $_group',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _group == 1
                              ? 'وقتك: 8:00 — 10:00 صباحاً'
                              : _group == 2
                                  ? 'وقتك: 10:00 — 12:00 ظهراً'
                                  : 'وقتك: 12:00 — 14:00 بعد الظهر',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.green),
                        ),
                        const SizedBox(height: 24),
                        QrImageView(
                          data: _barcode!,
                          version: QrVersions.auto,
                          size: 220,
                        ),
                        const SizedBox(height: 12),
                        Text(_barcode!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
      ),
    );
  }
}
