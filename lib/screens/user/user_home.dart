import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/station.dart';
import 'register_vehicle.dart';
import 'booking_screen.dart';

class UserHome extends StatefulWidget {
  final int userId;
  const UserHome({super.key, required this.userId});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  List<StationModel> _stations = [];
  bool _hasVehicle = false;
  String _vehicleStatus = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DBHelper.instance.database;

    final stations = await db.query('stations', where: 'is_open = 1');
    final vehicles = await db.query('vehicles',
        where: 'user_id = ?', whereArgs: [widget.userId]);

    setState(() {
      _stations = stations.map(StationModel.fromMap).toList();
      _hasVehicle = vehicles.isNotEmpty;
      if (vehicles.isNotEmpty) {
        _vehicleStatus = vehicles.first['status'] as String;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محطتي — المستخدم'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حالة السيارة
            if (!_hasVehicle)
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.directions_car, color: Colors.orange),
                  title: const Text('لم تسجّل مركبتك بعد'),
                  trailing: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              RegisterVehicle(userId: widget.userId)),
                    ).then((_) => _load()),
                    child: const Text('سجّل'),
                  ),
                ),
              )
            else
              Card(
                color: _vehicleStatus == 'approved'
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                child: ListTile(
                  leading: Icon(
                    Icons.directions_car,
                    color: _vehicleStatus == 'approved'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  title: Text(_vehicleStatus == 'approved'
                      ? 'المركبة معتمدة ✓'
                      : 'المركبة قيد المراجعة...'),
                ),
              ),

            const SizedBox(height: 20),
            const Text('المحطات المفتوحة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            _stations.isEmpty
                ? const Center(
                    child: Text('لا توجد محطات مفتوحة حالياً',
                        style: TextStyle(color: Colors.grey)))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _stations.length,
                      itemBuilder: (_, i) {
                        final s = _stations[i];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.local_gas_station,
                                color: Colors.green),
                            title: Text(s.name),
                            subtitle: Text(s.location),
                            trailing: ElevatedButton(
                              onPressed: _vehicleStatus == 'approved'
                                  ? () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookingScreen(
                                            userId: widget.userId,
                                            station: s,
                                          ),
                                        ),
                                      ).then((_) => _load())
                                  : null,
                              child: const Text('احجز'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
