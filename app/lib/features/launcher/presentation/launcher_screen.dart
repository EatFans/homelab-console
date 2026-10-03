import 'package:flutter/material.dart';
import 'package:homelab_panel/app/theme/panel_theme.dart';
import 'package:homelab_panel/features/launcher/presentation/feature_placeholder_screen.dart';

class LauncherScreen extends StatelessWidget {
  const LauncherScreen({super.key});

  static const _features = [
    _FeatureEntry('房间', Icons.meeting_room_rounded),
    _FeatureEntry('设备', Icons.devices_rounded),
    _FeatureEntry('场景', Icons.auto_awesome_rounded),
    _FeatureEntry('灯光', Icons.lightbulb_rounded),
    _FeatureEntry('环境', Icons.thermostat_rounded),
    _FeatureEntry('窗帘', Icons.blinds_rounded),
    _FeatureEntry('音乐', Icons.music_note_rounded),
    _FeatureEntry('安防', Icons.shield_rounded),
    _FeatureEntry('摄像头', Icons.videocam_rounded),
    _FeatureEntry('能耗', Icons.bolt_rounded),
    _FeatureEntry('自动化', Icons.sync_rounded),
    _FeatureEntry('设置', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: CustomScrollView(
            key: const PageStorageKey('launcher-scroll'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
                sliver: SliverToBoxAdapter(child: _buildHeader(context)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 144),
                sliver: SliverGrid.builder(
                  itemCount: _features.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 172,
                    mainAxisExtent: 154,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final feature = _features[index];
                    return _FeatureTile(
                      feature: feature,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => FeaturePlaceholderScreen(
                            title: feature.title,
                            icon: feature.icon,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = PanelPalette.of(context);
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: palette.text,
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        Text('应用', style: titleStyle),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: palette.warningSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_off_rounded, size: 15, color: palette.warning),
              const SizedBox(width: 6),
              Text(
                '中枢未连接',
                style: TextStyle(color: palette.warning, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureEntry {
  const _FeatureEntry(this.title, this.icon);

  final String title;
  final IconData icon;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature, required this.onTap});

  final _FeatureEntry feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = PanelPalette.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: palette.surface,
                border: Border.all(color: palette.border),
                boxShadow: [
                  BoxShadow(
                    color: palette.shadow,
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(feature.icon, color: palette.accent, size: 34),
            ),
            const SizedBox(height: 12),
            Text(
              feature.title,
              style: TextStyle(
                color: palette.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
