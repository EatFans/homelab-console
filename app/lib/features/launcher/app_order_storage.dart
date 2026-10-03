import 'package:shared_preferences/shared_preferences.dart';

/// 保存桌面图标顺序。这里仅处理本地存取，位置调整由 LauncherPage 决定。
class AppOrderStorage {
  AppOrderStorage() : _preferences = SharedPreferencesAsync();

  static const storageKey = 'launcher.appOrder.v1';
  final SharedPreferencesAsync _preferences;

  Future<List<String>?> read() => _preferences.getStringList(storageKey);

  Future<void> write(List<String> ids) =>
      _preferences.setStringList(storageKey, ids);
}
