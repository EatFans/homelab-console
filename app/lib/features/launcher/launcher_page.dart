import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:homelab_panel/app/app_feature.dart';
import 'package:homelab_panel/features/launcher/app_order_storage.dart';
import 'package:homelab_panel/features/launcher/dock_storage.dart';
import 'package:homelab_panel/theme/panel_theme.dart';

/// 类似手机桌面的应用入口：横向翻页，底部固定常用应用栏。
/// 长按可调整桌面位置、拖进常用栏，或从常用栏拖回桌面。
class LauncherPage extends StatefulWidget {
  const LauncherPage({super.key, required this.features});

  final List<AppFeature> features;

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  static const _dockSize = 5;

  final _dockStorage = DockStorage();
  final _appOrderStorage = AppOrderStorage();
  final _pageController = PageController();
  final _pageAreaKey = GlobalKey();

  // null 表示空位。初次使用预置三个入口，剩余两个位置可直接拖入。
  List<String?> _dockSlots = ['rooms', 'devices', 'scenes', null, null];
  late List<String> _appOrder;
  Future<void> _saveQueue = Future<void>.value();
  bool _layoutEdited = false;
  Timer? _pageTurnTimer;
  int? _pageTurnDirection;
  int _currentPage = 0;
  int _pageSize = 8;

  @override
  void initState() {
    super.initState();
    _appOrder = [
      for (final feature in widget.features)
        if (!_dockSlots.contains(feature.id)) feature.id,
    ];
    _loadLayout();
  }

  @override
  void dispose() {
    _cancelPageTurn();
    _pageController.dispose();
    super.dispose();
  }

  AppFeature? _featureById(String id) {
    for (final feature in widget.features) {
      if (feature.id == id) return feature;
    }
    return null;
  }

  List<AppFeature> get _pageFeatures => [
    for (final id in _appOrder)
      if (_featureById(id) case final feature?) feature,
  ];

  Future<void> _loadLayout() async {
    try {
      final savedDock = await _dockStorage.read();
      final savedOrder = await _appOrderStorage.read();
      if (!mounted || _layoutEdited) return;

      final slots = savedDock == null
          ? List<String?>.from(_dockSlots)
          : List<String?>.filled(_dockSize, null);
      if (savedDock != null) {
        final usedIds = <String>{};
        for (
          var index = 0;
          index < math.min(savedDock.length, _dockSize);
          index++
        ) {
          final id = savedDock[index];
          if (_featureById(id) != null && usedIds.add(id)) {
            slots[index] = id;
          }
        }
      }
      // 忽略已经删除或重复的入口，新加入的功能自动排在桌面末尾。
      final order = <String>[];
      for (final id in [...?savedOrder, ...widget.features.map((f) => f.id)]) {
        if (!slots.contains(id) &&
            _featureById(id) != null &&
            !order.contains(id)) {
          order.add(id);
        }
      }
      setState(() {
        _dockSlots = slots;
        _appOrder = order;
      });
      _clampCurrentPage();
    } catch (error) {
      debugPrint('读取桌面排列失败：$error');
    }
  }

  void _saveLayout() {
    final dockSnapshot = List<String?>.from(_dockSlots);
    final orderSnapshot = List<String>.from(_appOrder);
    // 连续拖动时顺序写入，避免较早的异步写入覆盖最新排列。
    _saveQueue = _saveQueue.then((_) async {
      try {
        await _dockStorage.write(dockSnapshot);
        await _appOrderStorage.write(orderSnapshot);
      } catch (error) {
        debugPrint('保存桌面排列失败：$error');
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

    final order = List<String>.from(_appOrder);
    if (previousIndex < 0) {
      final gridIndex = order.indexOf(id);
      if (gridIndex >= 0) {
        if (displaced == null) {
          order.removeAt(gridIndex);
        } else {
          order[gridIndex] = displaced;
        }
      }
    }

    _layoutEdited = true;
    setState(() {
      _dockSlots = next;
      _appOrder = order;
    });
    _saveLayout();
    _clampCurrentPage();
  }

  void _removeFromDock(String id) {
    final index = _dockSlots.indexOf(id);
    if (index < 0) return;
    final next = List<String?>.from(_dockSlots)..[index] = null;
    // 松在图标间的空白处时，按初始入口顺序找到邻近位置。
    // 这样从常用栏移回桌面后，入口仍容易在原来的页面找到。
    final order = List<String>.from(_appOrder);
    final catalogIndex = widget.features.indexWhere(
      (feature) => feature.id == id,
    );
    final insertAt = order.indexWhere(
      (otherId) =>
          widget.features.indexWhere((feature) => feature.id == otherId) >
          catalogIndex,
    );
    order.insert(insertAt < 0 ? order.length : insertAt, id);
    _layoutEdited = true;
    setState(() {
      _dockSlots = next;
      _appOrder = order;
    });
    _saveLayout();
  }

  void _moveToGrid(String id, int targetIndex) {
    if (_featureById(id) == null) return;
    final order = List<String>.from(_appOrder)..remove(id);
    order.insert(targetIndex.clamp(0, order.length), id);
    final dock = List<String?>.from(_dockSlots);
    final dockIndex = dock.indexOf(id);
    if (dockIndex >= 0) dock[dockIndex] = null;
    if (dockIndex < 0 && listEquals(order, _appOrder)) return;

    _layoutEdited = true;
    setState(() {
      _dockSlots = dock;
      _appOrder = order;
    });
    _saveLayout();
    _clampCurrentPage();
  }

  void _cancelPageTurn() {
    _pageTurnTimer?.cancel();
    _pageTurnTimer = null;
    _pageTurnDirection = null;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final area = _pageAreaKey.currentContext?.findRenderObject();
    if (area is! RenderBox || !_pageController.hasClients) return;
    final point = area.globalToLocal(details.globalPosition);
    final pageCount = math.max(
      1,
      (_appOrder.length + _pageSize - 1) ~/ _pageSize,
    );
    final direction = point.dy >= 0 && point.dy <= area.size.height
        ? point.dx < 48
              ? -1
              : point.dx > area.size.width - 48
              ? 1
              : 0
        : 0;
    if (direction == 0 ||
        _currentPage + direction < 0 ||
        _currentPage + direction >= pageCount) {
      _cancelPageTurn();
      return;
    }
    if (_pageTurnDirection == direction) return;
    _cancelPageTurn();
    _pageTurnDirection = direction;
    // 手指在页边停留片刻才翻页，避免经过边缘时误触。
    _pageTurnTimer = Timer(const Duration(milliseconds: 550), () {
      _pageTurnTimer = null;
      _pageTurnDirection = null;
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        _currentPage + direction,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
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

  void _openFeature(AppFeature feature) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: feature.buildPage));
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
                        key: _pageAreaKey,
                        onWillAcceptWithDetails: (details) =>
                            _dockSlots.contains(details.data),
                        onAcceptWithDetails: (details) =>
                            _removeFromDock(details.data),
                        builder: (context, candidates, rejected) => Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              allowImplicitScrolling: true,
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
                                // 翻页时保留拖拽起点，否则旧页销毁会提前结束拖动。
                                return _KeepAliveGridPage(
                                  key: ValueKey('launcher-page-$page'),
                                  child: _buildGridPage(items, columns, start),
                                );
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

  Widget _buildGridPage(List<AppFeature> features, int columns, int start) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _pageSize,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 154,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final feature = index < features.length ? features[index] : null;
              return DragTarget<String>(
                key: ValueKey('grid-slot-${start + index}'),
                onWillAcceptWithDetails: (details) =>
                    _featureById(details.data) != null,
                onAcceptWithDetails: (details) =>
                    _moveToGrid(details.data, start + index),
                builder: (context, candidates, rejected) => Container(
                  decoration: BoxDecoration(
                    color: candidates.isNotEmpty
                        ? PanelPalette.of(
                            context,
                          ).accent.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: feature == null
                      ? const SizedBox.expand()
                      : LayoutBuilder(
                          builder: (context, constraints) =>
                              LongPressDraggable<String>(
                                key: ValueKey('grid-${feature.id}'),
                                data: feature.id,
                                // 预览与原网格单元同尺寸，长按时图标不会跳向左上方。
                                feedback: _dragFeedback(
                                  feature,
                                  constraints.biggest,
                                ),
                                onDragUpdate: _onDragUpdate,
                            onDragEnd: (_) => _cancelPageTurn(),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _AppTile(
                                    feature: feature,
                                    onTap: () {},
                                  ),
                                ),
                                child: _AppTile(
                                  feature: feature,
                                  onTap: () => _openFeature(feature),
                                ),
                              ),
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
                    onDragUpdate: _onDragUpdate,
                    onDragEnd: (_) => _cancelPageTurn(),
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
    AppFeature feature,
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

class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.feature,
    required this.onTap,
    this.compact = false,
  });

  final AppFeature feature;
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

/// PageView 切到下一页时仍保留旧页，让长按拖拽可以跨页继续。
class _KeepAliveGridPage extends StatefulWidget {
  const _KeepAliveGridPage({super.key, required this.child});

  final Widget child;

  @override
  State<_KeepAliveGridPage> createState() => _KeepAliveGridPageState();
}

class _KeepAliveGridPageState extends State<_KeepAliveGridPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.feature, this.compact = false});

  final AppFeature feature;
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
