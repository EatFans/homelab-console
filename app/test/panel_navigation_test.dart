import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homelab_panel/app/app.dart';

void main() {
  // 模拟 1200×800 的平板屏幕，检查 Tab 切换、打开功能页和返回。
  testWidgets('switches tabs and opens a feature page', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // pumpWidget 把 App 放进测试环境；pumpAndSettle 等待动画结束。
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
    // 窄屏下入口需要滚动才能看到，顺便验证底部入口仍可点击。
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
