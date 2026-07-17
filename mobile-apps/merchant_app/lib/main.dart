import 'package:flutter/material.dart';
import 'screens/merchant_dashboard_screen.dart';

void main() {
  runApp(const MerchantApp());
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merchant Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF006B76), // Deep Teal color for distinct merchant branding
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B76),
          primary: const Color(0xFF006B76),
        ),
      ),
      home: const MerchantDashboardScreen(),
    );
  }
}
