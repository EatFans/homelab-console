import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设置功能的状态与本地保存逻辑。页面只负责显示和传递用户选择。
class SettingsController extends ChangeNotifier {
  SettingsController() : _preferences = SharedPreferencesAsync();

  static const themeStorageKey = 'settings.themeMode.v1';
  final SharedPreferencesAsync _preferences;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> _saveQueue = Future<void>.value();
  bool _edited = false;
  bool _disposed = false;

  Future<void> load() async {
    try {
      final saved = await _preferences.getString(themeStorageKey);
      // 用户可能在异步读取结束前已修改设置，不用旧值覆盖新选择。
      if (_disposed || _edited) return;
      final mode = ThemeMode.values.where((value) => value.name == saved);
      if (mode.isNotEmpty) {
        _themeMode = mode.first;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('读取外观设置失败：$error');
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _edited = true;
    _themeMode = mode;
    notifyListeners();

    // 连续切换时按顺序写入，最终保存的是最后一次选择。
    _saveQueue = _saveQueue.then((_) async {
      try {
        await _preferences.setString(themeStorageKey, mode.name);
      } catch (error) {
        debugPrint('保存外观设置失败：$error');
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
