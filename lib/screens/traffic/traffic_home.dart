import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/vehicle.dart';

class TrafficHome extends StatefulWidget {
  final int userId;
  const TrafficHome({super.key, required this.userId});

  @override
  State<TrafficHome> createState() => _TrafficHomeState();
}

class _TrafficHomeState extends State<TrafficHome> {
  List<Map<String, dynamic>> _pending = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DBHelper.instance.database;
    final res = await db.rawQuery('''
      SELECT v.*, u.name AS owner_name, u.phone AS owner_phone
      FROM vehicles v
      JOIN users u ON v.user_id = u.id
      WHERE v.status = 'pending'
    ''');
    setState(() => _pending = res);
  }

  Future<void> _decide(int vehicleId, String decision) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'vehicles',
      {'status': decision},
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المرور — طلبات التسجيل'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _pending.isEmpty
          ? const Center(child: Text('لا توجد طلبات معلقة'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pending.length,
              itemBuilder: (_, i) {
                final v = _pending[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المالك: ${v['owner_name']} — ${v['owner_phone']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('اللوحة: ${v['plate_number']}'),
                        Text(
                            'الموديل: ${v['model']} — ${v['color']} — ${v['year']}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('قبول'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () =>
                                  _decide(v['id'] as int, 'approved'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('رفض'),
                              onPressed: () =>
                                  _decide(v['id'] as int, 'rejected'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
