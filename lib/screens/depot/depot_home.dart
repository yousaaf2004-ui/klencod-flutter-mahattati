import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/station.dart';

class DepotHome extends StatefulWidget {
  final int userId;
  const DepotHome({super.key, required this.userId});

  @override
  State<DepotHome> createState() => _DepotHomeState();
}

class _DepotHomeState extends State<DepotHome> {
  List<StationModel> _stations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DBHelper.instance.database;
    final res = await db.query('stations');
    setState(() => _stations = res.map(StationModel.fromMap).toList());
  }

  Future<void> _toggleStation(StationModel s, double liters) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'stations',
      {
        'is_open': s.isOpen ? 0 : 1,
        'allocated_liters': liters,
        'remaining_liters': liters,
      },
      where: 'id = ?',
      whereArgs: [s.id],
    );
    _load();
  }

  void _showDialog(StationModel s) {
    final ctrl = TextEditingController(
        text: s.allocatedLiters > 0 ? s.allocatedLiters.toString() : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.name),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'الكمية بالليتر', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleStation(s, double.tryParse(ctrl.text) ?? 0);
            },
            child: Text(s.isOpen ? 'إغلاق المحطة' : 'فتح المحطة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مستودع سبها'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stations.length,
        itemBuilder: (_, i) {
          final s = _stations[i];
          return Card(
            child: ListTile(
              leading: Icon(
                Icons.local_gas_station,
                color: s.isOpen ? Colors.green : Colors.grey,
              ),
              title: Text(s.name),
              subtitle: Text(
                  '${s.location}\nالمخصص: ${s.allocatedLiters} L — المتبقي: ${s.remainingLiters} L'),
              isThreeLine: true,
              trailing: Switch(
                value: s.isOpen,
                onChanged: (_) => _showDialog(s),
              ),
            ),
          );
        },
      ),
    );
  }
}
