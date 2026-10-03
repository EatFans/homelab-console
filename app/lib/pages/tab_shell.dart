import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homelab_panel/pages/apps_page.dart';
import 'package:homelab_panel/pages/overview_page.dart';
import 'package:homelab_panel/theme/panel_theme.dart';

/// 两个一级页面共用的外壳：负责切换 Tab 和显示底部悬浮切换栏。
/// 选中的 Tab 会变化，因此这里使用 StatefulWidget。
class TabShell extends StatefulWidget {
  const TabShell({super.key});

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  // 0 = 应用，1 = 总览；setState 更新它时，Flutter 会重新执行 build。
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 某些设备启动的首帧可能暂时给出 0 尺寸，此时先不布局页面。
          if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
            return const SizedBox.shrink();
          }

          // Stack 让悬浮栏盖在页面内容上方，而不是占用独立的底栏高度。
          return Stack(
            children: [
              // IndexedStack 只显示当前 Tab，但保留其他 Tab 的组件状态。
              // 例如切到总览再回来，应用页的滚动位置不会从头开始。
              IndexedStack(
                index: _selectedTab,
                children: const [AppsPage(), OverviewPage()],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: SafeArea(
                  // 避开设备底部手势区域，并额外留出 18dp 的间距。
                  top: false,
                  minimum: const EdgeInsets.only(bottom: 18),
                  child: Center(child: _buildFloatingTabBar()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingTabBar() {
    final palette = PanelPalette.of(context);

    // ClipRRect 限制模糊范围；BackdropFilter 只模糊悬浮栏背后的内容。
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: palette.floatingBar,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            // 复用 iOS 风格的分段切换控件，值与 IndexedStack 的索引一致。
            groupValue: _selectedTab,
            backgroundColor: Colors.transparent,
            thumbColor: palette.surfaceMuted,
            padding: EdgeInsets.zero,
            onValueChanged: (value) {
              if (value != null) {
                // 通知 Flutter 重建当前组件，显示新 Tab 并更新选中样式。
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
    final palette = PanelPalette.of(context);
    final isSelected = _selectedTab == index;
    final color = isSelected ? palette.accent : palette.textMuted;

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
