import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';

/// 双因素认证对话框
/// 在解锁数据库时要求用户输入TOTP/OTP验证码以完成2FA验证
class TwoFactorAuthDialog extends StatefulWidget {
  /// 数据库服务，用于验证2FA验证码
  final DatabaseService databaseService;

  /// 构造函数
  ///
  /// [key] 组件键
  /// [databaseService] 数据库服务（必需）
  const TwoFactorAuthDialog({
    super.key,
    required this.databaseService,
  });

  @override
  State<TwoFactorAuthDialog> createState() => _TwoFactorAuthDialogState();
}

/// 双因素认证对话框状态类
class _TwoFactorAuthDialogState extends State<TwoFactorAuthDialog> {
  /// 验证码输入控制器
  final _codeController = TextEditingController();

  /// 验证码输入焦点节点
  final _codeFocusNode = FocusNode();

  /// 错误信息
  String? _errorText;

  /// 是否正在验证中
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // 在下一帧请求验证码输入框焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _codeFocusNode.requestFocus();
      } catch (_) {
        // 忽略焦点请求错误，不影响主要功能
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  /// 验证2FA验证码
  /// 调用数据库服务的verify2fa方法进行验证
  Future<void> _verifyCode() async {
    final appLocalizations = AppLocalizations.of(context)!;
    final enteredCode = _codeController.text;

    // 检查验证码是否为空
    if (enteredCode.isEmpty) {
      setState(() {
        _errorText = appLocalizations.enter2faCodeHint;
      });
      return;
    }

    // 设置验证状态并清除错误信息
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      // 调用数据库服务验证2FA验证码
      final isValid = await widget.databaseService.verify2fa(enteredCode);

      if (!mounted) return;

      if (isValid) {
        // 验证成功，返回true
        Navigator.of(context).pop(true);
      } else {
        // 验证失败，显示错误信息
        setState(() {
          _errorText = appLocalizations.invalid2faCode;
          _isVerifying = false;
        });
      }
    } catch (e) {
      // 处理验证过程中的异常
      if (!mounted) return;
      setState(() {
        _errorText = appLocalizations.invalid2faCode;
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: Text(appLocalizations.enter2faCode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 验证码输入提示文本
          Text(
            appLocalizations.enter2faCodeHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // 验证码输入框
          TextField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // 仅允许输入数字
            ],
            decoration: InputDecoration(
              hintText: appLocalizations.enter6DigitCode,
              counterText: '', // 隐藏计数器
              errorText: _errorText,
            ),
            onSubmitted: (_) => _verifyCode(), // 按下回车键时触发验证
          ),
        ],
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(false),
          child: Text(appLocalizations.cancelButton),
        ),
        // 验证按钮
        FilledButton(
          onPressed: _isVerifying ? null : _verifyCode,
          child: _isVerifying
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(appLocalizations.verifyButton),
        ),
      ],
    );
  }
}
