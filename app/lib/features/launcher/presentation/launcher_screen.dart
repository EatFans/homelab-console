import 'package:flutter/material.dart';
import 'package:homelab_panel/features/launcher/presentation/feature_placeholder_screen.dart';

class LauncherScreen extends StatelessWidget {
  const LauncherScreen({super.key});

  static const _features = [
    _FeatureEntry('房间', Icons.meeting_room_rounded, Color(0xFF74C9EE)),
    _FeatureEntry('设备', Icons.devices_rounded, Color(0xFF9BA9FF)),
    _FeatureEntry('场景', Icons.auto_awesome_rounded, Color(0xFFF6C875)),
    _FeatureEntry('灯光', Icons.lightbulb_rounded, Color(0xFFFFC56D)),
    _FeatureEntry('环境', Icons.thermostat_rounded, Color(0xFF7FD9C8)),
    _FeatureEntry('窗帘', Icons.blinds_rounded, Color(0xFFBFABED)),
    _FeatureEntry('音乐', Icons.music_note_rounded, Color(0xFFFF9BB3)),
    _FeatureEntry('安防', Icons.shield_rounded, Color(0xFF8EB6F4)),
    _FeatureEntry('摄像头', Icons.videocam_rounded, Color(0xFF8CCAC3)),
    _FeatureEntry('能耗', Icons.bolt_rounded, Color(0xFFF6C875)),
    _FeatureEntry('自动化', Icons.sync_rounded, Color(0xFFA2B7F5)),
    _FeatureEntry('设置', Icons.settings_rounded, Color(0xFFADB7C8)),
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
                padding: const EdgeInsets.fromLTRB(28, 42, 28, 28),
                sliver: SliverToBoxAdapter(child: _buildHeader(context)),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(28, 0, 28, 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    '所有应用',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
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
                            accent: feature.accent,
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
    final titleStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOMELAB  /  PANEL',
          style: TextStyle(
            color: const Color(0xFF9AE4D4).withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 14),
        Text('应用中心', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '从这里进入家庭的每一项功能',
          style: TextStyle(color: Color(0xFF9BA8B7), fontSize: 15),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF202B30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF39494A)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_off_rounded, size: 18, color: Color(0xFFFFC875)),
              SizedBox(width: 9),
              Text(
                '中枢尚未接入',
                style: TextStyle(color: Color(0xFFE7DDC5), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureEntry {
  const _FeatureEntry(this.title, this.icon, this.accent);

  final String title;
  final IconData icon;
  final Color accent;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature, required this.onTap});

  final _FeatureEntry feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    feature.accent.withValues(alpha: 0.34),
                    feature.accent.withValues(alpha: 0.13),
                  ],
                ),
                border: Border.all(
                  color: feature.accent.withValues(alpha: 0.32),
                ),
              ),
              child: Icon(feature.icon, color: feature.accent, size: 39),
            ),
            const SizedBox(height: 12),
            Text(
              feature.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
