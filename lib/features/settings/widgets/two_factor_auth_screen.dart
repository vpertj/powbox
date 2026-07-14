import 'package:flutter/material.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:otp/otp.dart' as otp_lib;
import 'dart:math';
import 'package:base32/base32.dart';
import 'dart:typed_data';

/// 一个用于启用和验证两步验证的界面
/// 支持扫描二维码或手动输入密钥来设置双因素认证
class TwoFactorAuthScreen extends StatefulWidget {
  /// 数据库服务
  final DatabaseService databaseService;

  /// 初始密钥，用于验证
  final String? initialSecret;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [databaseService] 数据库服务
  /// [initialSecret] 初始密钥，用于验证
  const TwoFactorAuthScreen({
    super.key,
    required this.databaseService,
    this.initialSecret,
  });

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  late final String _secret;
  late final String _uri;
  final _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialSecret != null) {
      _secret = widget.initialSecret!;
      _uri = '';
    } else {
      _secret = base32.encode(
        Uint8List.fromList(
          List<int>.generate(20, (i) => Random.secure().nextInt(256)),
        ),
      );
      _uri = 'otpauth://totp/PwBox?secret=$_secret&issuer=PwBox';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText) {
    const borderRadius = BorderRadius.all(Radius.circular(12.0));
    return InputDecoration(
      labelText: labelText,
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
      title: Text(widget.initialSecret != null ? appLocalizations.enter2faCode : appLocalizations.enable2fa),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.initialSecret == null)
                Column(
                  children: [
                    Text(appLocalizations.scanQrCodeWithAuthenticator),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: QrImageView(
                        data: _uri,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(appLocalizations.orEnterSecretManually),
                    const SizedBox(height: 8),
                    SelectableText(_secret),
                    const SizedBox(height: 16),
                  ],
                ),
              TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                decoration: _buildInputDecoration(appLocalizations.enter2faCode),
                onSubmitted: (_) => _verifyAndSave(appLocalizations),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(appLocalizations.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => _verifyAndSave(appLocalizations),
          child: Text(widget.initialSecret != null ? appLocalizations.verifyButton : appLocalizations.verifyAndSaveButton),
        ),
      ],
    );
  }

  void _verifyAndSave(AppLocalizations appLocalizations) async {
    final enteredCode = _codeController.text;

    final now = DateTime.now().millisecondsSinceEpoch;
    final isValid = otp_lib.OTP.generateTOTPCodeString(_secret, now, algorithm: otp_lib.Algorithm.SHA1, isGoogle: true) == enteredCode ||
        otp_lib.OTP.generateTOTPCodeString(_secret, now - 30000, algorithm: otp_lib.Algorithm.SHA1, isGoogle: true) == enteredCode ||
        otp_lib.OTP.generateTOTPCodeString(_secret, now + 30000, algorithm: otp_lib.Algorithm.SHA1, isGoogle: true) == enteredCode;

    if (isValid) {
      if (widget.initialSecret == null) {
        await widget.databaseService.setConfig('2fa_secret', _secret);
      }
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appLocalizations.settingsTitle),
          content: const Text('Two-factor authentication has been enabled.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: Text(appLocalizations.okButton),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appLocalizations.errorTitle),
          content: Text(appLocalizations.invalid2faCode),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.okButton),
            ),
          ],
        ),
      );
    }
  }
}