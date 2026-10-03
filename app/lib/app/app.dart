import 'package:flutter/material.dart';
import 'package:homelab_panel/app/presentation/panel_shell.dart';

class HomeLabPanelApp extends StatelessWidget {
  const HomeLabPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLab Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9AE4D4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0C111A),
      ),
      home: const PanelShell(),
    );
  }
}
