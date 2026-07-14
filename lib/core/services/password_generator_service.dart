import 'dart:math';
import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';

/// 提供密码生成功能的服务。
class PasswordGeneratorService {
  /// 大写字母字符集。
  static const String _upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// 小写字母字符集。
  static const String _lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';

  /// 数字字符集。
  static const String _numericChars = '0123456789';

  /// 特殊字符字符集。
  /// 增加了更多特殊字符以提高密码强度
  static const String _specialChars = r'!@#$%^&*()_+-=<>?[]{}|;:,./~`';

  /// 生成一个随机密码。
  ///
  /// * [length]: 密码的长度。必须大于0。
  /// * [includeUpperCase]: 是否包含大写字母。
  /// * [includeLowerCase]: 是否包含小写字母。
  /// * [includeNumeric]: 是否包含数字。
  /// * [includeSpecial]: 是否包含特殊字符。
  ///
  /// 返回生成的密码。
  /// 
  /// 该方法确保生成的密码至少包含每种选定类型的字符，
  /// 以满足大多数网站的密码复杂性要求。
  static String generatePassword({
    required int length,
    required bool includeUpperCase,
    required bool includeLowerCase,
    required bool includeNumeric,
    required bool includeSpecial,
  }) {
    // 验证输入参数
    if (length <= 0) {
      throw ArgumentError.value(length, 'length', '密码长度必须大于0');
    }
    
    if (!includeUpperCase && !includeLowerCase && !includeNumeric && !includeSpecial) {
      return ''; // 如果没有选择字符类型，则返回空字符串
    }

    String chars = '';
    if (includeUpperCase) chars += _upperCaseChars;
    if (includeLowerCase) chars += _lowerCaseChars;
    if (includeNumeric) chars += _numericChars;
    if (includeSpecial) chars += _specialChars;

    final random = Random.secure();
    final List<String> passwordChars = [];

    // 确保至少包含每种选定类型的字符
    // 这样可以满足大多数网站的密码复杂性要求
    if (includeUpperCase) {
      passwordChars.add(_upperCaseChars[random.nextInt(_upperCaseChars.length)]);
    }
    if (includeLowerCase) {
      passwordChars.add(_lowerCaseChars[random.nextInt(_lowerCaseChars.length)]);
    }
    if (includeNumeric) {
      passwordChars.add(_numericChars[random.nextInt(_numericChars.length)]);
    }
    if (includeSpecial) {
      passwordChars.add(_specialChars[random.nextInt(_specialChars.length)]);
    }

    // 填充剩余的密码长度
    for (int i = passwordChars.length; i < length; i++) {
      passwordChars.add(chars[random.nextInt(chars.length)]);
    }

    // 随机打乱字符顺序以确保随机性
    passwordChars.shuffle(random);

    return passwordChars.join();
  }

  /// 根据指定的强度生成密码。
  /// 
  /// 从SharedPreferences中读取用户设置的密码强度，
  /// 并生成相应强度的密码。
  static Future<String> generatePasswordWithStrength() async {
    final prefs = await SharedPreferences.getInstance();
    final strength = prefs.getString('password_strength') ?? 'medium';

    int length = 12;
    bool includeUpperCase = true;
    bool includeLowerCase = true;
    bool includeNumeric = true;
    bool includeSpecial = false;

    switch (strength) {
      case 'weak':
        length = 8;
        includeUpperCase = false;
        includeSpecial = false;
        break;
      case 'medium':
        length = 12;
        includeSpecial = false;
        break;
      case 'strong':
        length = 16;
        includeSpecial = true;
        break;
    }

    return generatePassword(
      length: length,
      includeUpperCase: includeUpperCase,
      includeLowerCase: includeLowerCase,
      includeNumeric: includeNumeric,
      includeSpecial: includeSpecial,
    );
  }
}