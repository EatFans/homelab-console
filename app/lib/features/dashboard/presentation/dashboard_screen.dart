import 'package:flutter/material.dart';
import 'package:homelab_panel/app/theme/panel_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PanelPalette.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 140),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: palette.border),
                ),
                child: Icon(
                  Icons.space_dashboard_rounded,
                  color: palette.accent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '总览页面',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '这里会展示家庭状态和常用控制。',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
