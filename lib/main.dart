import 'package:flutter/material.dart';
import 'screens/role_select_screen.dart';

void main() {
  runApp(const MahattatiApp());
}

class MahattatiApp extends StatelessWidget {
  const MahattatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محطتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const RoleSelectScreen(),
    );
  }
}