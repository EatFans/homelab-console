import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homelab_panel/features/dashboard/presentation/dashboard_screen.dart';
import 'package:homelab_panel/features/launcher/presentation/launcher_screen.dart';

class PanelShell extends StatefulWidget {
  const PanelShell({super.key});

  @override
  State<PanelShell> createState() => _PanelShellState();
}

class _PanelShellState extends State<PanelShell> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedTab,
            children: const [LauncherScreen(), DashboardScreen()],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 18),
              child: Center(child: _buildFloatingTabBar()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTabBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xE619202B),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _selectedTab,
            backgroundColor: Colors.transparent,
            thumbColor: const Color(0xFFE7F3EF),
            padding: EdgeInsets.zero,
            onValueChanged: (value) {
              if (value != null) {
                setState(() => _selectedTab = value);
              }
            },
            children: {
              0: _tabLabel(0, Icons.apps_rounded, '应用'),
              1: _tabLabel(1, Icons.space_dashboard_rounded, '总览'),
            },
          ),
        ),
      ),
    );
  }

  Widget _tabLabel(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    final color = isSelected ? const Color(0xFF11231F) : Colors.white70;

    return SizedBox(
      width: 112,
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 21, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
