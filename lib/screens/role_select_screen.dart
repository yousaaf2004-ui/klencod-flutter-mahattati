import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _navigate(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      {'label': 'مستخدم', 'icon': Icons.person, 'role': 'user', 'color': Colors.blue},
      {'label': 'محطة وقود', 'icon': Icons.local_gas_station, 'role': 'station', 'color': Colors.orange},
      {'label': 'مستودع سبها', 'icon': Icons.warehouse, 'role': 'depot', 'color': Colors.green},
      {'label': 'المرور', 'icon': Icons.traffic, 'role': 'traffic', 'color': Colors.red},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_gas_station, size: 80, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                'محطتي',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر نوع الحساب',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: roles.map((r) {
                  return GestureDetector(
                    onTap: () => _navigate(context, r['role'] as String),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(r['icon'] as IconData,
                              size: 48, color: r['color'] as Color),
                          const SizedBox(height: 12),
                          Text(
                            r['label'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
