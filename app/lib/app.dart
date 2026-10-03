import 'package:flutter/material.dart';
import 'package:homelab_panel/pages/apps_page.dart';
import 'package:homelab_panel/theme/panel_theme.dart';

/// App 的根组件：统一配置名称、主题和第一个页面。
/// 这里没有可变数据，所以使用 StatelessWidget。
class HomeLabPanelApp extends StatelessWidget {
  const HomeLabPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // build 返回的是组件树；MaterialApp 提供导航、主题等应用级能力。
    return MaterialApp(
      title: 'HomeLab Panel',
      debugShowCheckedModeBanner: false,
      theme: PanelTheme.light,
      darkTheme: PanelTheme.dark,
      // 根据设备系统设置，在上面的浅色和深色主题之间自动切换。
      themeMode: ThemeMode.system,
      // 目前只有应用启动器这一个主页面，底部常用栏由它自己管理。
      home: const Scaffold(body: AppsPage()),
    );
  }
}
