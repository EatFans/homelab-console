import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:homelab_panel/pages/feature_placeholder_page.dart';
import 'package:homelab_panel/theme/panel_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 类似手机桌面的应用入口：横向翻页，底部固定常用应用栏。
/// 长按图标可拖进常用栏，也可从常用栏拖回上方的应用区域。
class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  static const _dockSize = 5;
  static const _dockStorageKey = 'launcher.dock.v1';

  // id 用来保存常用栏的位置；显示名称将来可以修改而不破坏已保存的配置。
  static const _features = [
    _FeatureEntry('rooms', '房间', Icons.meeting_room_rounded),
    _FeatureEntry('devices', '设备', Icons.devices_rounded),
    _FeatureEntry('scenes', '场景', Icons.auto_awesome_rounded),
    _FeatureEntry('lights', '灯光', Icons.lightbulb_rounded),
    _FeatureEntry('climate', '环境', Icons.thermostat_rounded),
    _FeatureEntry('curtains', '窗帘', Icons.blinds_rounded),
    _FeatureEntry('music', '音乐', Icons.music_note_rounded),
    _FeatureEntry('security', '安防', Icons.shield_rounded),
    _FeatureEntry('cameras', '摄像头', Icons.videocam_rounded),
    _FeatureEntry('energy', '能耗', Icons.bolt_rounded),
    _FeatureEntry('automation', '自动化', Icons.sync_rounded),
    _FeatureEntry('settings', '设置', Icons.settings_rounded),
  ];

  final _preferences = SharedPreferencesAsync();
  final _pageController = PageController();

  // null 表示空位。初次使用预置三个入口，剩余两个位置可直接拖入。
  List<String?> _dockSlots = ['rooms', 'devices', 'scenes', null, null];
  Future<void> _saveQueue = Future<void>.value();
  bool _dockEdited = false;
  int _currentPage = 0;
  int _pageSize = 8;

  @override
  void initState() {
    super.initState();
    _loadDock();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _FeatureEntry? _featureById(String id) {
    for (final feature in _features) {
      if (feature.id == id) return feature;
    }
    return null;
  }

  List<_FeatureEntry> get _pageFeatures => [
    for (final feature in _features)
      if (!_dockSlots.contains(feature.id)) feature,
  ];

  Future<void> _loadDock() async {
    try {
      final saved = await _preferences.getStringList(_dockStorageKey);
      if (!mounted || _dockEdited || saved == null) return;

      final slots = List<String?>.filled(_dockSize, null);
      final usedIds = <String>{};
      for (var index = 0; index < math.min(saved.length, _dockSize); index++) {
        final id = saved[index];
        if (_featureById(id) != null && usedIds.add(id)) {
          slots[index] = id;
        }
      }
      setState(() => _dockSlots = slots);
      _clampCurrentPage();
    } catch (error) {
      debugPrint('读取常用应用栏失败：$error');
    }
  }

  void _saveDock() {
    final snapshot = [for (final id in _dockSlots) id ?? ''];
    // 顺序写入，避免用户快速拖动几次后，较早的写入覆盖最新顺序。
    _saveQueue = _saveQueue.then((_) async {
      try {
        await _preferences.setStringList(_dockStorageKey, snapshot);
      } catch (error) {
        debugPrint('保存常用应用栏失败：$error');
      }
    });
  }

  void _placeInDock(String id, int targetIndex) {
    if (_featureById(id) == null) return;
    final next = List<String?>.from(_dockSlots);
    final previousIndex = next.indexOf(id);
    if (previousIndex == targetIndex) return;

    // 常用栏内部拖动时交换位置；从页面拖入时，原位置的应用回到页面。
    final displaced = next[targetIndex];
    if (previousIndex >= 0) next[previousIndex] = displaced;
    next[targetIndex] = id;

    _dockEdited = true;
    setState(() => _dockSlots = next);
    _saveDock();
    _clampCurrentPage();
  }

  void _removeFromDock(String id) {
    final index = _dockSlots.indexOf(id);
    if (index < 0) return;
    final next = List<String?>.from(_dockSlots)..[index] = null;
    _dockEdited = true;
    setState(() => _dockSlots = next);
    _saveDock();
  }

  void _clampCurrentPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final pageCount = math.max(
        1,
        (_pageFeatures.length + _pageSize - 1) ~/ _pageSize,
      );
      final lastPage = pageCount - 1;
      if (_currentPage > lastPage) _pageController.jumpToPage(lastPage);
    });
  }

  void _openFeature(_FeatureEntry feature) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            FeaturePlaceholderPage(title: feature.title, icon: feature.icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                  return const SizedBox.shrink();
                }

                final columns = constraints.maxWidth >= 680
                    ? 4
                    : constraints.maxWidth >= 340
                    ? 3
                    : 2;
                final rows = constraints.maxHeight >= 520 ? 2 : 1;
                _pageSize = columns * rows;
                final features = _pageFeatures;
                final pageCount = math.max(
                  1,
                  (features.length + _pageSize - 1) ~/ _pageSize,
                );

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                      child: _buildHeader(context),
                    ),
                    // DragTarget 覆盖整个分页区：把常用栏图标拖回这里即可移出。
                    Expanded(
                      child: DragTarget<String>(
                        onWillAcceptWithDetails: (details) =>
                            _dockSlots.contains(details.data),
                        onAcceptWithDetails: (details) =>
                            _removeFromDock(details.data),
                        builder: (context, candidates, rejected) => Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: pageCount,
                              onPageChanged: (page) =>
                                  setState(() => _currentPage = page),
                              itemBuilder: (context, page) {
                                final start = page * _pageSize;
                                final end = math.min(
                                  start + _pageSize,
                                  features.length,
                                );
                                final items = features.sublist(start, end);
                                return _buildGridPage(items, columns);
                              },
                            ),
                            if (candidates.isNotEmpty)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 12,
                                child: Center(
                                  child: Text(
                                    '松开以移出常用栏',
                                    style: TextStyle(
                                      color: PanelPalette.of(context).textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    _buildPageIndicator(pageCount),
                    const SizedBox(height: 12),
                    _buildDock(context),
                    const SizedBox(height: 18),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = PanelPalette.of(context);
    return Row(
      children: [
        Text(
          '应用',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: palette.text,
            fontWeight: FontWeight.w700,
          ),
        ),
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

  Widget _buildGridPage(List<_FeatureEntry> features, int columns) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: features.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 154,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final feature = features[index];
              return LayoutBuilder(
                builder: (context, constraints) => LongPressDraggable<String>(
                  key: ValueKey('grid-${feature.id}'),
                  data: feature.id,
                  // 默认锚点以整个网格单元计算，因此预览也要保持同样尺寸。
                  // 只预览小图标会让它在开始拖动时向左上方跳动。
                  feedback: _dragFeedback(feature, constraints.biggest),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _AppTile(feature: feature, onTap: () {}),
                  ),
                  child: _AppTile(
                    feature: feature,
                    onTap: () => _openFeature(feature),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    final palette = PanelPalette.of(context);
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var page = 0; page < pageCount; page++)
            Container(
              width: page == _currentPage ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: page == _currentPage
                    ? palette.accent
                    : palette.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDock(BuildContext context) {
    final palette = PanelPalette.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(8),
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
            child: SizedBox(
              height: 96,
              child: Row(
                children: [
                  for (var index = 0; index < _dockSize; index++)
                    Expanded(child: _buildDockSlot(index)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockSlot(int index) {
    final palette = PanelPalette.of(context);
    final id = _dockSlots[index];
    final feature = id == null ? null : _featureById(id);

    return DragTarget<String>(
      key: ValueKey('dock-slot-$index'),
      onWillAcceptWithDetails: (details) => _featureById(details.data) != null,
      onAcceptWithDetails: (details) => _placeInDock(details.data, index),
      builder: (context, candidates, rejected) {
        final highlighted = candidates.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: highlighted
                ? palette.accent.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: feature == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 29,
                      color: palette.textMuted,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '拖入',
                      style: TextStyle(color: palette.textMuted, fontSize: 12),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) => LongPressDraggable<String>(
                    key: ValueKey('dock-${feature.id}'),
                    data: feature.id,
                    feedback: _dragFeedback(
                      feature,
                      constraints.biggest,
                      compact: true,
                    ),
                    childWhenDragging: const SizedBox.expand(),
                    child: _AppTile(
                      feature: feature,
                      compact: true,
                      onTap: () => _openFeature(feature),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _dragFeedback(
    _FeatureEntry feature,
    Size sourceSize, {
    bool compact = false,
  }) => Material(
    key: ValueKey('drag-feedback-${feature.id}'),
    color: Colors.transparent,
    child: SizedBox.fromSize(
      size: sourceSize,
      child: Center(
        child: _AppIcon(feature: feature, compact: compact),
      ),
    ),
  );
}

class _FeatureEntry {
  const _FeatureEntry(this.id, this.title, this.icon);

  final String id;
  final String title;
  final IconData icon;
}

class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.feature,
    required this.onTap,
    this.compact = false,
  });

  final _FeatureEntry feature;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: _AppIcon(feature: feature, compact: compact),
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.feature, this.compact = false});

  final _FeatureEntry feature;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = PanelPalette.of(context);
    final size = compact ? 54.0 : 80.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 17 : 24),
            color: palette.surface,
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: compact ? 8 : 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            feature.icon,
            color: palette.accent,
            size: compact ? 26 : 34,
          ),
        ),
        SizedBox(height: compact ? 6 : 12),
        Text(
          feature.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.text,
            fontSize: compact ? 12 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
