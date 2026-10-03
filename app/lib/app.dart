import 'package:flutter/material.dart';
import 'package:homelab_panel/app/feature_catalog.dart';
import 'package:homelab_panel/features/launcher/launcher_page.dart';
import 'package:homelab_panel/features/settings/settings_controller.dart';
import 'package:homelab_panel/theme/panel_theme.dart';

/// App 的根组件：统一配置名称、主题和第一个页面。
/// 外观设置需要影响整个 App，因此状态由根组件持有。
class HomeLabPanelApp extends StatefulWidget {
  const HomeLabPanelApp({super.key});

  @override
  State<HomeLabPanelApp> createState() => _HomeLabPanelAppState();
}

class _HomeLabPanelAppState extends State<HomeLabPanelApp> {
  final _settings = SettingsController();

  @override
  void initState() {
    super.initState();
    _settings.load();
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => MaterialApp(
        title: 'HomeLab Panel',
        debugShowCheckedModeBanner: false,
        theme: PanelTheme.light,
        darkTheme: PanelTheme.dark,
        themeMode: _settings.themeMode,
        // 入口清单只在这里组装，LauncherPage 不依赖任何具体功能。
        home: Scaffold(
          body: LauncherPage(features: createFeatureCatalog(_settings)),
        ),
      ),
    );
  }
}
