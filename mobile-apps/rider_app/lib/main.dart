import 'package:flutter/material.dart';
import 'screens/rider_dashboard_screen.dart';

void main() {
  runApp(const RiderApp());
}

class RiderApp extends StatelessWidget {
  const RiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rider Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF39FF14),     // Neon Green
          secondary: Color(0xFFFF9F0A),   // Orange
          surface: Color(0xFF161A26),     // Slate Cards
        ),
      ),
      home: const RiderDashboardScreen(),
    );
  }
}
