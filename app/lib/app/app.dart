import 'package:flutter/material.dart';
import 'package:homelab_panel/app/presentation/panel_shell.dart';
import 'package:homelab_panel/app/theme/panel_theme.dart';

class HomeLabPanelApp extends StatelessWidget {
  const HomeLabPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeLab Panel',
      debugShowCheckedModeBanner: false,
      theme: PanelTheme.light,
      darkTheme: PanelTheme.dark,
      themeMode: ThemeMode.system,
      home: const PanelShell(),
    );
  }
}
