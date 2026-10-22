import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/db_helper.dart';
import 'register_screen.dart';
import '../user/user_home.dart';
import '../station/station_home.dart';
import '../depot/depot_home.dart';
import '../traffic/traffic_home.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final db = await DBHelper.instance.database;
    final res = await db.query(
      'users',
      where: 'phone = ? AND password = ? AND role = ?',
      whereArgs: [_phoneCtrl.text.trim(), _passCtrl.text.trim(), widget.role],
    );

    setState(() => _loading = false);

    if (res.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات خاطئة أو الدور غير مطابق')),
      );
      return;
    }

    final user = res.first;
    final role = user['role'] as String;

    Widget next;
    switch (role) {
      case 'user':
        next = UserHome(userId: user['id'] as int);
        break;
      case 'station':
        next = StationHome(userId: user['id'] as int);
        break;
      case 'depot':
        next = DepotHome(userId: user['id'] as int);
        break;
      case 'traffic':
        next = TrafficHome(userId: user['id'] as int);
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => next),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = {
      'user': 'مستخدم',
      'station': 'محطة وقود',
      'depot': 'مستودع سبها',
      'traffic': 'المرور',
    };

    return Scaffold(
      appBar: AppBar(title: Text('تسجيل الدخول — ${labels[widget.role]}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('دخول'),
              ),
            ),
            if (widget.role == 'user') ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('إنشاء حساب جديد'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}