import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homelab_panel/app/app.dart';

void main() {
  testWidgets('switches tabs and opens a feature page', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    expect(find.text('中枢未连接'), findsOneWidget);

    await tester.tap(find.text('总览'));
    await tester.pumpAndSettle();
    expect(find.text('总览页面'), findsOneWidget);

    await tester.tap(find.text('应用'));
    await tester.pumpAndSettle();
    expect(find.text('中枢未连接'), findsOneWidget);

    await tester.tap(find.text('房间'));
    await tester.pumpAndSettle();
    expect(find.text('功能页面已预留，等待家庭中枢接入。'), findsOneWidget);

    await tester.tap(find.text('返回应用'));
    await tester.pumpAndSettle();
    expect(find.text('中枢未连接'), findsOneWidget);
  });

  testWidgets('scrolls to lower app entries on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomeLabPanelApp());
    await tester.scrollUntilVisible(
      find.text('设置'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('功能页面已预留，等待家庭中枢接入。'), findsOneWidget);
  });
}
