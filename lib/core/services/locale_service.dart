import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 提供区域设置（语言）管理的服务。
class LocaleService with ChangeNotifier {
  /// 用于存储用户偏好的 [SharedPreferences] 实例。
  final SharedPreferences _prefs;

  /// 用于在 [SharedPreferences] 中存储语言代码的键。
  static const String _languageCodeKey = 'language_code';

  /// 当前的区域设置。
  Locale? _locale;

  /// 创建一个 [LocaleService] 实例。
  ///
  /// * [_prefs]: 用于存储用户偏好的 [SharedPreferences] 实例。
  LocaleService(this._prefs) {
    _loadLocale();
  }

  /// 获取当前的区域设置。
  Locale? get locale => _locale;

  /// 从 [SharedPreferences] 加载区域设置。
  void _loadLocale() {
    final langCode = _prefs.getString(_languageCodeKey);
    if (langCode != null) {
      _locale = Locale(langCode, '');
    } else {
      // 如果没有保存偏好，则默认为中文
      _locale = const Locale('zh', '');
    }
    notifyListeners();
  }

  /// 设置新的区域设置。
  ///
  /// * [newLocale]: 要设置的新区域设置。
  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    await _prefs.setString(_languageCodeKey, newLocale.languageCode);
    notifyListeners();
  }
}