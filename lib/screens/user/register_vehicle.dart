import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class RegisterVehicle extends StatefulWidget {
  final int userId;
  const RegisterVehicle({super.key, required this.userId});

  @override
  State<RegisterVehicle> createState() => _RegisterVehicleState();
}

class _RegisterVehicleState extends State<RegisterVehicle> {
  final _plateCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_plateCtrl.text.isEmpty ||
        _modelCtrl.text.isEmpty ||
        _colorCtrl.text.isEmpty ||
        _yearCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }

    setState(() => _loading = true);
    final db = await DBHelper.instance.database;

    try {
      await db.insert('vehicles', {
        'user_id': widget.userId,
        'plate_number': _plateCtrl.text.trim(),
        'model': _modelCtrl.text.trim(),
        'color': _colorCtrl.text.trim(),
        'year': int.tryParse(_yearCtrl.text.trim()) ?? 2020,
        'status': 'pending',
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب التسجيل إلى المرور')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم اللوحة مسجل مسبقاً')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل المركبة')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _plateCtrl,
              decoration: const InputDecoration(
                  labelText: 'رقم اللوحة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelCtrl,
              decoration: const InputDecoration(
                  labelText: 'موديل السيارة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colorCtrl,
              decoration: const InputDecoration(
                  labelText: 'اللون', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'سنة الصنع', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('إرسال للمرور'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
