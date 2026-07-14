import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 提供主题管理的服务。
class ThemeService with ChangeNotifier {
  /// 用于存储用户偏好的 [SharedPreferences] 实例。
  final SharedPreferences _prefs;

  /// 用于在 [SharedPreferences] 中存储主题模式的键。
  static const String _themeKey = 'theme_mode';

  /// 用于在 [SharedPreferences] 中存储字体大小缩放的键。
  static const String _fontSizeScaleKey = 'font_size_scale';

  /// 当前的主题模式。
  ThemeMode _themeMode = ThemeMode.system;

  /// 当前的字体大小缩放。
  double _fontSizeScale = 1.0;

  /// 创建一个 [ThemeService] 实例。
  ///
  /// * [_prefs]: 用于存储用户偏好的 [SharedPreferences] 实例。
  ThemeService(this._prefs) {
    _loadTheme();
    _loadFontSizeScale(); // 初始化时加载字体大小
  }

  /// 获取当前的主题模式。
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// 获取当前的字体大小缩放。
  double get fontSizeScale => _fontSizeScale;

  /// 从 [SharedPreferences] 加载主题模式。
  void _loadTheme() {
    final themeString = _prefs.getString(_themeKey);
    _themeMode = _stringToThemeMode(themeString);
    notifyListeners();
  }

  /// 从 [SharedPreferences] 加载字体大小缩放。
  void _loadFontSizeScale() {
    _fontSizeScale = _prefs.getDouble(_fontSizeScaleKey) ?? 1.0;
    notifyListeners();
  }

  /// 设置新的主题模式。
  ///
  /// * [themeMode]: 要设置的新主题模式。
  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _prefs.setString(_themeKey, _themeModeToString(themeMode));
    notifyListeners();
  }

  /// 设置新的字体大小缩放。
  ///
  /// * [scale]: 要设置的新字体大小缩放。
  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale;
    await _prefs.setDouble(_fontSizeScaleKey, scale);
    notifyListeners();
  }

  /// 将字符串转换为 [ThemeMode]。
  ThemeMode _stringToThemeMode(String? themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 将 [ThemeMode] 转换为字符串。
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}