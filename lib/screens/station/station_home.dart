import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import 'scan_barcode.dart';

class StationHome extends StatefulWidget {
  final int userId;
  const StationHome({super.key, required this.userId});

  @override
  State<StationHome> createState() => _StationHomeState();
}

class _StationHomeState extends State<StationHome> {
  int _group1 = 0, _group2 = 0, _group3 = 0;
  int _stationId = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DBHelper.instance.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // جلب أول محطة مرتبطة — للعرض فقط يُستخدم id=1 كمثال
    // في بيئة حقيقية يُربط المستخدم بالمحطة
    _stationId = 1;

    final g1 = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM bookings WHERE station_id=? AND booking_date=? AND group_number=1',
          [_stationId, today],
        )) ??
        0;
    final g2 = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM bookings WHERE station_id=? AND booking_date=? AND group_number=2',
          [_stationId, today],
        )) ??
        0;
    final g3 = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM bookings WHERE station_id=? AND booking_date=? AND group_number=3',
          [_stationId, today],
        )) ??
        0;

    setState(() {
      _group1 = g1;
      _group2 = g2;
      _group3 = g3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = [
      {'label': 'المجموعة 1', 'time': '8:00 — 10:00', 'count': _group1},
      {'label': 'المجموعة 2', 'time': '10:00 — 12:00', 'count': _group2},
      {'label': 'المجموعة 3', 'time': '12:00 — 14:00', 'count': _group3},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('محطة الوقود'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...groups.map((g) => Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.group, color: Colors.blue),
                    title: Text(g['label'] as String),
                    subtitle: Text(g['time'] as String),
                    trailing: Chip(
                      label: Text('${g['count']} / 200'),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('مسح باركود'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ScanBarcode(stationId: _stationId)),
                ).then((_) => _load()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
