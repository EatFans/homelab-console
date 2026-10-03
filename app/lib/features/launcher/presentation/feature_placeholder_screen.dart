import 'package:flutter/material.dart';
import 'package:homelab_panel/app/theme/panel_theme.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = PanelPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 98,
                  height: 98,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: palette.border),
                  ),
                  child: Icon(icon, color: palette.accent, size: 42),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: palette.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '功能页面已预留，等待家庭中枢接入。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textMuted, fontSize: 15),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('返回应用'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
