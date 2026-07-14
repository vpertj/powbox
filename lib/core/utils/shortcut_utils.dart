import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwbox/core/utils/constants.dart';

/// 快捷键工具类
/// 提供快捷键的序列化、反序列化和存储功能
class ShortcutUtils {
  /// 将逻辑键盘键集合转换为字符串表示
  /// 
  /// [shortcut] 要转换的逻辑键盘键集合
  /// 返回转换后的字符串，如果输入为空则返回null
  static String? shortcutToString(Set<LogicalKeyboardKey>? shortcut) {
    // 如果快捷键为空或空集合，返回null
    if (shortcut == null || shortcut.isEmpty) return null;
    
    // 将集合转换为列表
    final keys = shortcut.toList();
    // 按照修饰键优先的顺序排序（次序按 keyId）
    keys.sort((a, b) {
      final aIsModifier = _isModifierKey(a);
      final bIsModifier = _isModifierKey(b);
      if (aIsModifier && !bIsModifier) return -1;
      if (!aIsModifier && bIsModifier) return 1;
      return a.keyId.compareTo(b.keyId);
    });
    
    // 使用 keyId 持久化，避免依赖 debugName 或私有API
    return keys.map((key) => key.keyId.toString()).join('+');
  }
  
  /// 判断是否为修饰键
  /// 
  /// [key] 要判断的逻辑键盘键
  /// 返回是否为修饰键
  static bool _isModifierKey(LogicalKeyboardKey key) {
    // 判断是否为控制键、Shift键、Alt键或Meta键
    return key == LogicalKeyboardKey.control ||
           key == LogicalKeyboardKey.shift ||
           key == LogicalKeyboardKey.alt ||
           key == LogicalKeyboardKey.meta;
  }

  /// 将字符串表示转换为逻辑键盘键集合
  /// 
  /// [shortcutString] 要转换的字符串
  /// 返回转换后的逻辑键盘键集合，如果输入为空则返回null
  static Set<LogicalKeyboardKey>? stringToShortcut(String? shortcutString) {
    // 如果字符串为空或空字符串，返回null
    if (shortcutString == null || shortcutString.isEmpty) return null;
    
    // 按'+'分割字符串获取 keyId 列表
    final keyIdStrings = shortcutString.split('+');
    // 创建逻辑键盘键集合
    final keys = <LogicalKeyboardKey>{};
    
    // 反序列化为 LogicalKeyboardKey（使用 keyId 构造）
    for (final idStr in keyIdStrings) {
      final id = int.tryParse(idStr);
      if (id != null) {
        keys.add(LogicalKeyboardKey(id));
      }
    }
    
    // 如果集合为空，返回null，否则返回集合
    return keys.isEmpty ? null : keys;
  }

  /// 保存快捷键到 SharedPreferences
  /// 
  /// [shortcut] 要保存的快捷键集合
  static Future<void> saveShortcut(Set<LogicalKeyboardKey>? shortcut) async {
    // 获取 SharedPreferences 实例
    final prefs = await SharedPreferences.getInstance();
    // 将快捷键集合转换为字符串
    final shortcutString = shortcutToString(shortcut);
    // 如果字符串不为空，保存到 SharedPreferences
    if (shortcutString != null) {
      await prefs.setString(lockDatabaseShortcutKey, shortcutString);
    } else {
      // 如果字符串为空，从 SharedPreferences 中移除
      await prefs.remove(lockDatabaseShortcutKey);
    }
  }

  /// 从 SharedPreferences 加载快捷键
  /// 
  /// 返回加载的快捷键集合
  static Future<Set<LogicalKeyboardKey>?> loadShortcut() async {
    // 获取 SharedPreferences 实例
    final prefs = await SharedPreferences.getInstance();
    // 从 SharedPreferences 中获取快捷键字符串
    final shortcutString = prefs.getString(lockDatabaseShortcutKey);
    // 将字符串转换为快捷键集合
    return stringToShortcut(shortcutString);
  }
}