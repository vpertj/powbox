import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/utils/constants.dart';

import 'package:pwbox/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

/// 打开数据库屏幕
/// 允许用户选择并打开现有的密码数据库
class OpenDatabaseScreen extends StatefulWidget {
  /// 数据库文件路径（可选）
  final String? filePath;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [filePath] 数据库文件路径
  const OpenDatabaseScreen({super.key, this.filePath});

  @override
  State<OpenDatabaseScreen> createState() => _OpenDatabaseScreenState();
}

/// 打开数据库屏幕状态类
class _OpenDatabaseScreenState extends State<OpenDatabaseScreen> {
  /// 路径控制器
  final _pathController = TextEditingController();
  
  /// 密码控制器
  final _passwordController = TextEditingController();
  
  /// 密码是否可见
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // 如果提供了文件路径，设置到控制器中
    if (widget.filePath != null) {
      _pathController.text = widget.filePath!;
    } else {
      // 否则加载上次打开的数据库路径
      _loadLastOpenedDbPath();
    }
  }

  /// 加载上次打开的数据库路径
  Future<void> _loadLastOpenedDbPath() async {
    // 获取共享偏好设置实例
    final prefs = await SharedPreferences.getInstance();
    // 获取上次打开的数据库路径
    final lastDbPath = prefs.getString(dbPathKey);
    // 如果路径存在，设置到控制器中
    if (lastDbPath != null) {
      setState(() {
        _pathController.text = lastDbPath;
      });
    }
  }

  @override
  void dispose() {
    // 释放控制器资源
    _pathController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 选择数据库文件
  Future<void> _pickFile() async {
    // 获取本地化文本
    final l10n = AppLocalizations.of(context)!;
    // 打开文件选择器
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: l10n.selectDatabaseDialogTitle, // 对话框标题
      type: FileType.custom, // 自定义文件类型
      allowedExtensions: ['pdbw'], // 允许的文件扩展名
    );

    // 如果选择了文件且路径不为空，设置路径到控制器中
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pathController.text = p.dirname(result.files.single.path!);
      });
    }
  }

  /// 打开数据库
  Future<void> _openDatabase() async {
    // 获取输入的路径和密码
    final path = _pathController.text;
    final password = _passwordController.text;

    // 检查路径和密码是否为空
    if (path.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordCannotBeEmpty),
        ),
      );
      return;
    }

    try {
      // 打开数据库
      final dbService = await DatabaseService.open(path, password);

      // 保存数据库路径到共享偏好设置
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(dbPathKey, path);

      // 如果组件仍然挂载，导航到主页屏幕
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              databaseService: dbService, // 数据库服务实例
              isDarkMode: Theme.of(context).brightness == Brightness.dark, // 深色模式状态
              onLock: () {}, // 锁定回调（此处为空实现）
              is2faEnabled: dbService.is2faEnabled, // 双因素认证状态
            ),
          ),
        );
      }
    } catch (e) {
      // 处理打开数据库过程中出现的错误
      if (mounted) {
        final appLocalizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(appLocalizations.unexpectedErrorWithMessage(e.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final l10n = AppLocalizations.of(context)!;
    
    // 构建用户界面
    return Scaffold(
      appBar: AppBar(), // 应用栏
      body: Center(
        child: SizedBox(
          width: 400, // 固定宽度
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // 打开按钮
              ElevatedButton(
                onPressed: _openDatabase, // 点击时打开数据库
                child: Text(l10n.openButton), // 按钮文本
              ),
              const SizedBox(height: 16),
              // 数据库路径标签
              Text(l10n.databasePath),
              const SizedBox(height: 8),
              // 路径输入框（只读）
              TextFormField(
                controller: _pathController,
                readOnly: true, // 只读模式
                decoration: InputDecoration(
                  border: const OutlineInputBorder(), // 边框
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open), // 文件夹图标
                    onPressed: _pickFile, // 点击时选择文件
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 密码输入框
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // 根据状态隐藏或显示密码
                decoration: InputDecoration(
                  labelText: l10n.masterPasswordLabel, // 标签
                  border: const OutlineInputBorder(), // 边框
                  prefixIcon: const Icon(Icons.lock_outline), // 前置锁图标
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility // 可见图标
                          : Icons.visibility_off, // 不可见图标
                    ),
                    onPressed: () {
                      // 切换密码可见性
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}