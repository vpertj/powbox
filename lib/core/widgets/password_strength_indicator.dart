import 'package:flutter/material.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';

/// 一个显示密码强度指示器的小组件。
class PasswordStrengthIndicator extends StatelessWidget {
  /// 要检查的密码。
  final String password;

  /// 创建一个 [PasswordStrengthIndicator] 实例。
  ///
  /// * [password]: 要检查的密码。
  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final strength = _calculateStrength(password);

    Color color;
    String text;

    switch (strength) {
      case _PasswordStrength.none:
        color = Colors.grey;
        text = appLocalizations.passwordStrengthNone;
        break;
      case _PasswordStrength.weak:
        color = Colors.red;
        text = appLocalizations.passwordStrengthWeak;
        break;
      case _PasswordStrength.medium:
        color = Colors.orange;
        text = appLocalizations.passwordStrengthMedium;
        break;
      case _PasswordStrength.strong:
        color = Colors.green;
        text = appLocalizations.passwordStrengthStrong;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength.index / (_PasswordStrength.values.length - 1),
          color: color,
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  /// 计算密码强度。
  _PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) {
      return _PasswordStrength.none;
    }

    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*()_+-=<>?]'));

    int charTypeCount = 0;
    if (hasLowercase) charTypeCount++;
    if (hasUppercase) charTypeCount++;
    if (hasDigits) charTypeCount++;
    if (hasSpecial) charTypeCount++;

    if (charTypeCount >= 3) score++;
    if (charTypeCount >= 4) score++;

    if (score >= 4) {
      return _PasswordStrength.strong;
    } else if (score >= 2) {
      return _PasswordStrength.medium;
    } else {
      return _PasswordStrength.weak;
    }
  }
}

/// 密码强度的枚举。
enum _PasswordStrength { none, weak, medium, strong }