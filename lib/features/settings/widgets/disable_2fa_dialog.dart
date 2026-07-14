import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';

/// 禁用双因素认证对话框
/// 要求用户输入当前TOTP验证码以确认禁用2FA
class Disable2faDialog extends StatefulWidget {
  /// 数据库服务，用于验证和禁用双因素认证
  final DatabaseService databaseService;

  /// ScaffoldMessenger键，用于显示操作结果提示
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// 2FA禁用成功后的回调
  final VoidCallback on2faDisabled;

  /// 构造函数
  ///
  /// [key] 组件键
  /// [databaseService] 数据库服务（必需）
  /// [scaffoldMessengerKey] ScaffoldMessenger键（可选）
  /// [on2faDisabled] 2FA禁用成功回调（必需）
  const Disable2faDialog({
    super.key,
    required this.databaseService,
    this.scaffoldMessengerKey,
    required this.on2faDisabled,
  });

  @override
  State<Disable2faDialog> createState() => _Disable2faDialogState();
}

/// 禁用双因素认证对话框状态类
class _Disable2faDialogState extends State<Disable2faDialog> {
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

  /// 显示提示消息
  /// 优先使用scaffoldMessengerKey，否则使用当前context的ScaffoldMessenger
  void _showSnackBar(String message) {
    if (widget.scaffoldMessengerKey?.currentState != null) {
      widget.scaffoldMessengerKey!.currentState!.showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// 验证验证码并禁用双因素认证
  Future<void> _verifyAndDisable() async {
    final appLocalizations = AppLocalizations.of(context)!;
    final enteredCode = _codeController.text;

    // 检查验证码是否为空
    if (enteredCode.isEmpty) {
      setState(() {
        _errorText = '输入6位验证码';
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

      if (!isValid) {
        // 验证失败，显示错误信息
        setState(() {
          _errorText = appLocalizations.invalid2faCode;
          _isVerifying = false;
        });
        return;
      }

      // 验证通过，禁用双因素认证
      await widget.databaseService.disable2fa();

      if (!mounted) return;

      // 显示禁用成功提示
      _showSnackBar(appLocalizations.twoFactorAuthDisabled);

      // 调用禁用成功回调
      widget.on2faDisabled();

      // 关闭对话框
      Navigator.of(context).pop();
    } catch (e) {
      // 处理验证或禁用过程中的异常
      if (!mounted) return;
      setState(() {
        _errorText = '验证失败，请重试';
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
      title: Text(appLocalizations.disable2fa),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 禁用2FA的说明描述
          Text(
            appLocalizations.disable2faConfirmation,
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
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            onSubmitted: (_) => _verifyAndDisable(), // 按下回车键时触发验证
          ),
        ],
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancelButton),
        ),
        // 验证并禁用按钮
        FilledButton(
          onPressed: _isVerifying ? null : _verifyAndDisable,
          child: _isVerifying
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(appLocalizations.verifyButton),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }
}
