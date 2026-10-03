import 'package:flutter/material.dart';
import 'package:homelab_panel/features/placeholder/feature_placeholder_page.dart';

/// 一个桌面入口。id 是持久化标识，发布后不要随意改名，否则常用栏会丢失该入口。
class AppFeature {
  const AppFeature({
    required this.id,
    required this.title,
    required this.icon,
    this.pageBuilder,
  });

  final String id;
  final String title;
  final IconData icon;

  /// 功能自己的页面。未实现时显示统一的占位页。
  final WidgetBuilder? pageBuilder;

  Widget buildPage(BuildContext context) =>
      pageBuilder?.call(context) ??
      FeaturePlaceholderPage(title: title, icon: icon);
}
