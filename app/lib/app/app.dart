import 'package:flutter/material.dart';
import 'package:homelab_panel/features/dashboard/presentation/dashboard_screen.dart';

class HomeLabPanelApp extends StatelessWidget {
  const HomeLabPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLab Panel',
      theme: ThemeData(useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}
