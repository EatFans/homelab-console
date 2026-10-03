import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homelab_panel/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    // 每个测试都从独立的空存储开始，避免常用栏和设置互相影响。
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('swipes between app pages and opens an app', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('dock-rooms')), findsOneWidget);
    expect(find.byKey(const ValueKey('grid-lights')), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-700, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('grid-settings')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('grid-settings')));
    await tester.pumpAndSettle();
    expect(find.text('选择平板界面的浅色或深色外观。'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('grid-settings')), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(700, 0), 1200);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('grid-lights')));
    await tester.pumpAndSettle();
    expect(find.text('功能页面已预留，等待家庭中枢接入。'), findsOneWidget);
  });

  testWidgets('settings changes theme and restores it after restart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-700, 0), 1200);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('grid-settings')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      await SharedPreferencesAsync().getString('settings.themeMode.v1'),
      'dark',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('long press adds and removes a dock app and saves it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();

    await _longPressDrag(
      tester,
      find.byKey(const ValueKey('grid-lights')),
      find.byKey(const ValueKey('dock-slot-3')),
    );
    expect(find.byKey(const ValueKey('dock-lights')), findsOneWidget);
    expect(find.byKey(const ValueKey('grid-lights')), findsNothing);

    final saved = await SharedPreferencesAsync().getStringList(
      'launcher.dock.v1',
    );
    expect(saved, ['rooms', 'devices', 'scenes', 'lights', '']);

    // 重新创建 App，确认常用栏从本地存储恢复。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('dock-lights')), findsOneWidget);

    await _longPressDrag(
      tester,
      find.byKey(const ValueKey('dock-lights')),
      find.byType(PageView),
    );
    expect(find.byKey(const ValueKey('dock-lights')), findsNothing);
    expect(find.byKey(const ValueKey('grid-lights')), findsOneWidget);
  });

  testWidgets('reorders desktop apps and restores their positions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    await _longPressDrag(
      tester,
      find.byKey(const ValueKey('grid-lights')),
      find.byKey(const ValueKey('grid-slot-2')),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey('grid-lights'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const ValueKey('grid-curtains'))).dx,
      ),
    );
    final saved = await SharedPreferencesAsync().getStringList(
      'launcher.appOrder.v1',
    );
    expect(saved?.take(4).toList(), ['climate', 'curtains', 'lights', 'music']);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.byKey(const ValueKey('grid-lights'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const ValueKey('grid-curtains'))).dx,
      ),
    );
  });

  testWidgets('dragging to the page edge moves an app to another page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    final source = find.byKey(const ValueKey('grid-lights'));
    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 700));
    final page = tester.getRect(find.byType(PageView));
    await gesture.moveTo(Offset(page.right - 16, page.center.dy));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('grid-settings')), findsOneWidget);

    await gesture.moveTo(
      tester.getCenter(find.byKey(const ValueKey('grid-slot-8'))),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('grid-lights')), findsOneWidget);
    // 插入第 9 格后，原来第 9 格的设置会顺移到上一页末尾。
    expect(find.byKey(const ValueKey('grid-settings')), findsNothing);
    expect(
      (await SharedPreferencesAsync().getStringList(
        'launcher.appOrder.v1',
      ))?.last,
      'lights',
    );
  });

  testWidgets('can reach later apps on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('grid-settings')), findsOneWidget);
  });
}

Future<void> _longPressDrag(
  WidgetTester tester,
  Finder source,
  Finder target,
) async {
  final id = tester.widget<LongPressDraggable<String>>(source).data;
  final gesture = await tester.startGesture(tester.getCenter(source));
  await tester.pump(const Duration(milliseconds: 700));
  final feedback = find.byKey(ValueKey('drag-feedback-$id'));
  expect(feedback, findsOneWidget);
  // 拖动开始时，预览仍应覆盖原单元，不能突然偏向左上方。
  expect(
    (tester.getCenter(feedback) - tester.getCenter(source)).distance,
    lessThan(1),
  );
  await gesture.moveTo(tester.getCenter(target));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.up();
  await tester.pumpAndSettle();
}
