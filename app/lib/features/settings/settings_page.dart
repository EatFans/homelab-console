import 'package:flutter/material.dart';
import 'package:homelab_panel/features/settings/settings_controller.dart';
import 'package:homelab_panel/theme/panel_theme.dart';

/// 设置功能的页面。后续的中枢连接等设置，可继续放在本目录中扩展。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final palette = PanelPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('外观', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '选择平板界面的浅色或深色外观。',
                    style: TextStyle(color: palette.textMuted),
                  ),
                  const SizedBox(height: 20),
                  // controller 通知这里刷新；根组件也会同步更新整个 App 的主题。
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) => SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('跟随系统'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('浅色'),
                        ),
                        ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
                      ],
                      selected: {controller.themeMode},
                      onSelectionChanged: (selection) =>
                          controller.setThemeMode(selection.first),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
