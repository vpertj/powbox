import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwbox/core/utils/constants.dart';

/// 用于封装加密设置的辅助类
class _EncryptionSettings {
  final String name;
  final int iterations;
  final int memory; // in KB

  const _EncryptionSettings({
    required this.name,
    required this.iterations,
    required this.memory,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EncryptionSettings &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

// 创建数据库屏幕
class CreateDatabaseScreen extends StatefulWidget {
  // 解锁数据库后的回调函数
  final Function(DatabaseService, bool) onUnlock;

  // 构造函数
  const CreateDatabaseScreen({super.key, required this.onUnlock});

  @override
  State<CreateDatabaseScreen> createState() => _CreateDatabaseScreenState();
}

class _CreateDatabaseScreenState extends State<CreateDatabaseScreen> {
  // 密码控制器
  final _passwordController = TextEditingController();
  // 数据库名称控制器
  final _dbNameController = TextEditingController();

  // 加密设置
  late final List<_EncryptionSettings> _encryptionOptions;
  late _EncryptionSettings _selectedSettings;

  // 是否正在创建数据库
  bool _isCreating = false;
  // 密码是否可见
  bool _isPasswordVisible = false;
  // 是否显示完整表单
  bool _showFullForm = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _encryptionOptions = [
      _EncryptionSettings(
          name: l10n.fast, iterations: 1000, memory: 8192), // 8MB
      _EncryptionSettings(
          name: l10n.balanced,
          iterations: 10000,
          memory: 16384), // 16MB
      _EncryptionSettings(
          name: l10n.paranoid,
          iterations: 50000,
          memory: 32768), // 32MB
    ];
    _selectedSettings = _encryptionOptions[1]; // 默认选择 "均衡"
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _dbNameController.dispose();
    super.dispose();
  }

  // 创建数据库
  Future<void> _createDatabase() async {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.passwordEmptyError)));
      return;
    }

    final dbName = _dbNameController.text;
    final finalDbName = dbName.isEmpty ? 'pwbox' : dbName;

    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(finalDbName)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidDatabaseName)));
      }
      return;
    }

    if (finalDbName.startsWith('.')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.databaseNameCannotStartWithDot)),
        );
      }
      return;
    }

    String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l10n.selectDatabaseFolder,
    );

    if (directoryPath == null) return;

    final dbContainerPath = p.join(directoryPath, '$finalDbName.PDBW');

    setState(() => _isCreating = true);

    try {
      debugPrint('开始创建数据库...');
      await DatabaseService.createNewDatabase(
        dbContainerPath,
        password,
        _selectedSettings.iterations,
        memory: _selectedSettings.memory,
        parallelism: defaultArgon2Parallelism,
      );
      debugPrint('数据库创建完成');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(dbPathKey, dbContainerPath);
      debugPrint('数据库路径已保存');

      final dbService = await DatabaseService.open(dbContainerPath, password);
      debugPrint('数据库已打开');

      if (mounted) {
        debugPrint('界面已挂载，准备跳转');
        // Navigator.of(context).pop(); // Pop this screen
        debugPrint('已执行pop操作');
        widget.onUnlock(
          dbService,
          Theme.of(context).brightness == Brightness.dark,
        );
        debugPrint('已执行onUnlock回调');
      } else {
        debugPrint('界面未挂载，无法跳转');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = l10n.errorCreatingDatabase(e.toString());
        if (e.toString().contains('access')) {
          errorMessage =
              'Permission denied. Please choose a different location or run the application as administrator.';
        } else if (e.toString().contains('exists')) {
          errorMessage =
              'Database folder already exists. Please choose a different name.';
        } else if (e.toString().contains('path')) {
          errorMessage = 'Invalid path. Please choose a valid location.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.createDatabaseTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _isCreating
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      appLocalizations.creatingDatabaseMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                )
              : Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          appLocalizations.createDatabaseTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // 密码输入框
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: appLocalizations.masterPasswordLabel,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          onChanged: (_) {
                            setState(() {
                              // 每当密码改变时更新状态，确保按钮正确显示
                            });
                          },
                          onSubmitted: (_) {
                            if (_passwordController.text.isNotEmpty) {
                              setState(() {
                                _showFullForm = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // 完整表单
                        if (_showFullForm ||
                            _passwordController.text.isNotEmpty)
                          Column(
                            children: [
                              // 数据库名称输入框
                              TextField(
                                controller: _dbNameController,
                                decoration: InputDecoration(
                                  labelText: appLocalizations.databaseNameHint,
                                  prefixIcon: const Icon(Icons.folder_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 加密强度下拉选择
                              DropdownButtonFormField<_EncryptionSettings>(
                                value: _selectedSettings,
                                decoration: InputDecoration(
                                  labelText:
                                      appLocalizations.encryptionStrengthLabel,
                                  prefixIcon: const Icon(
                                    Icons.security_outlined,
                                  ),
                                ),
                                items: _encryptionOptions
                                    .map((settings) =>
                                        DropdownMenuItem<_EncryptionSettings>(
                                          value: settings,
                                          child: Text(settings.name),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSettings = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        // 底部按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 取消按钮
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(appLocalizations.cancelButton),
                            ),
                            const SizedBox(width: 8),
                            // 下一步按钮
                            if (!_showFullForm)
                              TextButton(
                                onPressed: _passwordController.text.isNotEmpty
                                    ? () {
                                        setState(() {
                                          _showFullForm = true;
                                        });
                                      }
                                    : null,
                                child: Text(appLocalizations.nextButton),
                              )
                            // 创建并保存按钮
                            else
                              FilledButton.icon(
                                onPressed: _createDatabase,
                                icon: const Icon(Icons.save_outlined),
                                label: Text(
                                  appLocalizations.createAndSaveButton,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}