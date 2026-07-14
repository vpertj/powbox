import 'package:pwbox/core/widgets/password_strength_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/password_generator_service.dart';

/// 密码生成器屏幕
/// 用于生成安全的随机密码
class PasswordGeneratorScreen extends StatefulWidget {
  /// 构造函数
  /// 
  /// [key] 组件键
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

/// 密码生成器屏幕状态类
class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  /// 密码长度
  int _length = 16;
  
  /// 是否包含大写字母
  bool _includeUpperCase = true;
  
  /// 是否包含小写字母
  bool _includeLowerCase = true;
  
  /// 是否包含数字
  bool _includeNumeric = true;
  
  /// 是否包含特殊字符
  bool _includeSpecial = true;
  
  /// 生成的密码
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    // 初始化时生成密码
    _generatePassword();
  }

  /// 生成密码
  void _generatePassword() {
    // 更新状态并生成新密码
    setState(() {
      _generatedPassword = PasswordGeneratorService.generatePassword(
        length: _length, // 密码长度
        includeUpperCase: _includeUpperCase, // 是否包含大写字母
        includeLowerCase: _includeLowerCase, // 是否包含小写字母
        includeNumeric: _includeNumeric, // 是否包含数字
        includeSpecial: _includeSpecial, // 是否包含特殊字符
      );
    });
  }

  /// 复制到剪贴板
  /// 
  /// [context] 上下文
  /// [text] 要复制的文本
  void _copyToClipboard(BuildContext context, String text) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;
    // 设置剪贴板数据
    Clipboard.setData(ClipboardData(text: text));
    // 显示密码已复制的提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appLocalizations.passwordCopied), // "密码已复制到剪贴板！"
        duration: const Duration(seconds: 1), // 显示时长1秒
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    // 返回脚手架组件
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.passwordGeneratorTitle), // 标题："密码生成器"
        centerTitle: true, // 标题居中
        automaticallyImplyLeading: false, // 不自动显示返回按钮
        actions: [
          // 关闭按钮
          IconButton(
            icon: const Icon(Icons.close), // 关闭图标
            onPressed: () => Navigator.of(context).pop(), // 关闭屏幕
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 交叉轴拉伸对齐
          children: [
            // 生成的密码卡片
            Card(
              margin: const EdgeInsets.only(bottom: 16.0), // 外边距
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 内边距
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 交叉轴拉伸对齐
                  children: [
                    // 标题：生成的密码
                    Text(
                      appLocalizations.generatedPassword,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    // 密码显示区域
                    Container(
                      padding: const EdgeInsets.all(12.0), // 内边距
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest, // 背景色
                        borderRadius: BorderRadius.circular(8.0), // 圆角
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // 水平滚动
                        child: Text(
                          _generatedPassword, // 生成的密码
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), // 样式
                          textAlign: TextAlign.center, // 文本居中
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // 密码强度指示器
                    PasswordStrengthIndicator(password: _generatedPassword),
                    const SizedBox(height: 8.0),
                    // 复制密码按钮
                    OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context, _generatedPassword), // 复制密码
                      icon: const Icon(Icons.copy), // 复制图标
                      label: Text(appLocalizations.copyPasswordButton), // 按钮文本："复制密码"
                    ),
                  ],
                ),
              ),
            ),
            // 密码选项区域
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // 内边距
                  child: ListView(
                    children: [
                      // 标题：密码选项
                      Text(
                        appLocalizations.passwordOptions,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16.0),
                      // 密码长度标签
                      Text(
                        appLocalizations.passwordLengthLabel(_length.toInt()), // "密码长度: 长度值"
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      // 密码长度滑块
                      Slider(
                        value: _length.toDouble(), // 当前长度值
                        min: 4, // 最小值
                        max: 128, // 最大值
                        divisions: 124, // 分割数
                        label: _length.toString(), // 标签
                        onChanged: (value) => setState(() => _length = value.toInt()), // 长度值变化回调
                        onChangeEnd: (value) => _generatePassword(), // 结束拖动时生成密码
                      ),
                      // 包含大写字母复选框
                      CheckboxListTile(
                        title: Text(appLocalizations.passwordGeneratorIncludeUppercase), // "包含大写字母 (A-Z)"
                        value: _includeUpperCase, // 复选框状态
                        onChanged: (value) => setState(() {
                          _includeUpperCase = value!; // 更新状态
                          _generatePassword(); // 生成新密码
                        }),
                      ),
                      // 包含小写字母复选框
                      CheckboxListTile(
                        title: Text(appLocalizations.passwordGeneratorIncludeLowercase), // "包含小写字母 (a-z)"
                        value: _includeLowerCase, // 复选框状态
                        onChanged: (value) => setState(() {
                          _includeLowerCase = value!; // 更新状态
                          _generatePassword(); // 生成新密码
                        }),
                      ),
                      // 包含数字复选框
                      CheckboxListTile(
                        title: Text(appLocalizations.passwordGeneratorIncludeNumeric), // "包含数字 (0-9)"
                        value: _includeNumeric, // 复选框状态
                        onChanged: (value) => setState(() {
                          _includeNumeric = value!; // 更新状态
                          _generatePassword(); // 生成新密码
                        }),
                      ),
                      // 包含特殊字符复选框
                      CheckboxListTile(
                        title: Text(appLocalizations.passwordGeneratorIncludeSpecial), // "包含特殊字符 (!@#...)"
                        value: _includeSpecial, // 复选框状态
                        onChanged: (value) {
                          _includeSpecial = value!; // 更新状态
                          _generatePassword(); // 生成新密码
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // 底部导航栏：重新生成和使用此密码按钮
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // 内边距
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // 主轴末端对齐
          children: [
            // 重新生成按钮
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh), // 刷新图标
              label: Text(appLocalizations.generateButton), // 按钮文本："生成"
              onPressed: _generatePassword, // 生成密码
            ),
            const SizedBox(width: 8.0),
            // 使用此密码按钮
            FilledButton.icon(
              icon: const Icon(Icons.check), // 勾选图标
              label: Text(appLocalizations.useThisPasswordButton), // 按钮文本："使用此密码"
              onPressed: () => Navigator.of(context).pop(_generatedPassword), // 返回生成的密码并关闭屏幕
            ),
          ],
        ),
      ),
    );
  }
}