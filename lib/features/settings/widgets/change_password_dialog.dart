import 'package:flutter/material.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/models/exceptions.dart';
import 'package:pwbox/core/services/crypto_service.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/widgets/password_strength_indicator.dart';

/// 一个用于更改主密码的对话框
/// 支持验证当前密码、设置新密码、确认新密码等功能
class ChangePasswordDialog extends StatefulWidget {
  /// 数据库路径
  final String dbPath;

  /// 数据库服务
  final DatabaseService databaseService;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [dbPath] 数据库路径
  /// [databaseService] 数据库服务
  const ChangePasswordDialog({
    super.key,
    required this.dbPath,
    required this.databaseService,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPasswordNotifier = ValueNotifier<String>('');
  final _confirmPasswordController = TextEditingController();
  bool _isChanging = false;
  String? _currentPasswordError;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      _newPasswordNotifier.value = _newPasswordController.text;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordNotifier.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    setState(() {
      _currentPasswordError = null;
      _isChanging = true;
    });

    try {
      await widget.databaseService.changePassword(currentPassword, newPassword);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.masterPasswordChangedSuccessfully),
        ),
      );
      Navigator.of(context).pop(true);
    } on InvalidPasswordException {
      if (!mounted) return;
      setState(() {
        _currentPasswordError = appLocalizations.invalidCurrentPassword;
        _isChanging = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentPasswordError = appLocalizations.failedToChangePassword(e.toString());
        _isChanging = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String labelText, {String? errorText}) {
    const borderRadius = BorderRadius.all(Radius.circular(12.0));
    return InputDecoration(
      labelText: labelText,
      errorText: errorText,
      border: const OutlineInputBorder(borderRadius: borderRadius),
      enabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.blue),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: Text(appLocalizations.changeMasterPassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: _buildInputDecoration(
                appLocalizations.currentMasterPassword,
                errorText: _currentPasswordError,
              ),
              validator: (value) =>
                  value!.isEmpty ? appLocalizations.passwordEmptyError : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: _buildInputDecoration(appLocalizations.newMasterPassword),
              validator: (value) =>
                  value!.isEmpty ? appLocalizations.passwordEmptyError : null,
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: _newPasswordNotifier,
              builder: (context, password, child) {
                return PasswordStrengthIndicator(password: password);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _buildInputDecoration(appLocalizations.confirmNewMasterPassword),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return appLocalizations.passwordsDoNotMatch;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancelButton),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _isChanging ? null : _changePassword,
          child: _isChanging
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(appLocalizations.changeButton),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }
}