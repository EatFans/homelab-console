import 'package:shared_preferences/shared_preferences.dart';

/// 只负责在本机读取和保存常用栏；拖拽规则仍由 LauncherPage 管理。
class DockStorage {
  DockStorage() : _preferences = SharedPreferencesAsync();

  static const storageKey = 'launcher.dock.v1';
  final SharedPreferencesAsync _preferences;

  Future<List<String>?> read() => _preferences.getStringList(storageKey);

  Future<void> write(List<String?> slots) => _preferences.setStringList(
    storageKey,
    [for (final id in slots) id ?? ''],
  );
}
