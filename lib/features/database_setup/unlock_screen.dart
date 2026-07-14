import 'package:flutter/material.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/features/database_setup/two_factor_auth_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwbox/core/utils/constants.dart';

/// 解锁数据库屏幕
/// 允许用户输入主密码来解锁已存在的数据库
class UnlockScreen extends StatefulWidget {
  /// 数据库文件路径
  final String filePath;
  
  /// 解锁成功后的回调函数
  /// 
  /// [DatabaseService] 解锁后的数据库服务实例
  final Function(DatabaseService) onUnlock;
  
  /// 切换数据库的回调函数
  final VoidCallback onSwitchDatabase;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [filePath] 数据库文件路径
  /// [onUnlock] 解锁成功回调
  /// [onSwitchDatabase] 切换数据库回调
  const UnlockScreen({
    super.key,
    required this.filePath,
    required this.onUnlock,
    required this.onSwitchDatabase,
  });

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

/// 解锁数据库屏幕状态类
class _UnlockScreenState extends State<UnlockScreen> {
  /// 密码输入控制器
  final _passwordController = TextEditingController();
  
  /// 密码输入焦点节点
  final _passwordFocusNode = FocusNode();
  
  /// 是否正在加载（解锁过程中）
  bool _isLoading = false;
  
  /// 错误信息
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // 在下一帧请求密码输入框焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 使用try-catch确保不会因为焦点问题导致其他错误
      try {
        _passwordFocusNode.requestFocus();
      } catch (e) {
        // 忽略焦点请求错误，不影响主要功能
      }
    });
  }

  @override
  void dispose() {
    // 释放控制器和焦点节点资源
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// 解锁数据库
  /// 处理解锁数据库的逻辑
  Future<void> _unlockDatabase() async {
    // 检查密码是否为空
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorText = AppLocalizations.of(context)!.passwordCannotBeEmpty;
      });
      return;
    }

    // 设置加载状态并清除错误信息
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // 尝试打开数据库
      final dbService = await DatabaseService.open(widget.filePath, _passwordController.text);
      
      // 检查是否启用了双因素认证
      if (dbService.is2faEnabled) {
        // 如果启用了2FA，显示2FA验证对话框
        if (mounted) {
          final is2faValid = await showDialog<bool>(
            context: context,
            builder: (context) => TwoFactorAuthDialog(databaseService: dbService),
          );
          
          // 如果2FA验证成功
          if (is2faValid == true) {
            // 调用解锁回调
            widget.onUnlock(dbService);
          } else {
            // 如果2FA验证失败或取消，锁定数据库
            await dbService.lock();
            // 显示错误信息
            if (mounted) {
              setState(() {
                _errorText = AppLocalizations.of(context)!.twoFactorAuthRequired;
                _isLoading = false;
              });
            }
          }
        }
      } else {
        // 如果没有启用2FA，直接调用解锁回调
        widget.onUnlock(dbService);
      }
    } catch (e) {
      // 处理解锁过程中出现的错误
      if (mounted) {
        setState(() {
          _errorText = AppLocalizations.of(context)!.invalidPasswordError;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;
    
    // 构建用户界面
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 应用图标（使用内置图标替代缺失的资源文件）
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 120,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  // 屏幕标题
                  Text(appLocalizations.unlockDatabaseTitle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  // 密码输入框
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode, // 添加焦点节点
                    obscureText: true, // 隐藏密码输入
                    decoration: InputDecoration(
                      labelText: appLocalizations.masterPassword, // 标签
                      errorText: _errorText, // 错误信息
                    ),
                    onSubmitted: (_) => _unlockDatabase(), // 提交时解锁数据库
                  ),
                  const SizedBox(height: 24),
                  // 解锁按钮或加载指示器
                  _isLoading
                      ? const CircularProgressIndicator() // 加载指示器
                      : FilledButton(
                          onPressed: _unlockDatabase, // 点击时解锁数据库
                          child: Text(appLocalizations.unlockButton), // 按钮文本
                        ),
                  const SizedBox(height: 16),
                  // 切换数据库按钮
                  TextButton(
                    onPressed: () async {
                      // 显示切换数据库选项对话框
                      final selectedOption = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(appLocalizations.switchDatabaseButton),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.storage_outlined),
                                  title: Text(appLocalizations.openLocalDatabase),
                                  onTap: () => Navigator.of(context).pop('local'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.cloud_outlined),
                                  title: Text(appLocalizations.openNetworkDatabase),
                                  onTap: () => Navigator.of(context).pop('network'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(appLocalizations.cancelButton),
                              ),
                            ],
                          );
                        },
                      );

                      if (selectedOption == 'local') {
                        // 选择本地数据库
                        final directoryPath = await FilePicker.platform
                            .getDirectoryPath(
                              dialogTitle: appLocalizations.selectDatabaseFolder, // 对话框标题
                            );

                        // 如果用户取消了文件夹选择器，直接返回
                        if (directoryPath == null) return;

                        // 保存数据库路径到共享偏好设置
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(dbPathKey, directoryPath);

                        // 重新构建当前界面以使用新的数据库路径
                        setState(() {});
                      } else if (selectedOption == 'network') {
                        // 选择网络数据库（尚未实现）
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appLocalizations.networkDatabaseNotImplemented, // 未实现提示
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(appLocalizations.switchDatabaseButton), // 按钮文本
                  ),
                  const SizedBox(height: 80), // 添加更大间距将路径推到底部附近
                  // 数据库路径（底部附近居中显示）
                  Text(
                    widget.filePath,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32), // 底部间距
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}