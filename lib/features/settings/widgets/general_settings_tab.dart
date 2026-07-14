import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/services/locale_service.dart';
import 'package:pwbox/core/services/theme_service.dart';
import 'package:pwbox/core/utils/constants.dart';
import 'package:pwbox/core/utils/shortcut_utils.dart';
import 'package:pwbox/core/widgets/shortcut_recorder_dialog.dart';

/// 通用设置标签页
/// 包含外观设置、快捷键设置和备份设置等功能
class GeneralSettingsTab extends StatefulWidget {
  /// ScaffoldMessenger键
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  
  /// 数据库服务
  final DatabaseService databaseService;
  
  /// 主题服务
  final ThemeService themeService;
  
  /// 区域设置服务
  final LocaleService localeService;
  
  /// 快捷键变化回调
  final VoidCallback? onShortcutChanged;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [scaffoldMessengerKey] ScaffoldMessenger键
  /// [databaseService] 数据库服务
  /// [themeService] 主题服务
  /// [localeService] 区域设置服务
  /// [onShortcutChanged] 快捷键变化回调
  const GeneralSettingsTab({
    super.key,
    required this.scaffoldMessengerKey,
    required this.databaseService,
    required this.themeService,
    required this.localeService,
    this.onShortcutChanged,
  });

  @override
  State<GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

/// 通用设置标签页状态类
class _GeneralSettingsTabState extends State<GeneralSettingsTab> {
  /// 是否启用自动备份
  bool _enableAutoBackup = false;
  
  /// 是否正在备份
  bool _isBackingUp = false;
  
  /// 上次备份时间
  DateTime? _lastBackupTime;
  
  /// 锁定快捷键
  Set<LogicalKeyboardKey>? _lockShortcut;

  @override
  void initState() {
    super.initState();
    // 加载设置
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    // 获取共享偏好设置实例
    final prefs = await SharedPreferences.getInstance();
    // 加载快捷键设置
    final shortcut = await ShortcutUtils.loadShortcut();
    // 获取上次备份时间毫秒数
    final lastBackupMillis = prefs.getInt(lastBackupTimeKey) ?? 0;

    // 如果组件仍然挂载
    if (mounted) {
      setState(() {
        // 设置是否启用自动备份
        _enableAutoBackup = prefs.getBool(enableAutoBackupKey) ?? false;
        // 如果上次备份时间毫秒数大于0，设置上次备份时间
        if (lastBackupMillis > 0) {
          _lastBackupTime = DateTime.fromMillisecondsSinceEpoch(lastBackupMillis);
        }
        // 设置锁定快捷键
        _lockShortcut = shortcut;
      });
    }
  }

  /// 切换自动备份
  /// 
  /// [newValue] 新的自动备份状态
  Future<void> _toggleAutoBackup(bool newValue) async {
    // 获取共享偏好设置实例
    final prefs = await SharedPreferences.getInstance();
    // 保存自动备份设置
    await prefs.setBool(enableAutoBackupKey, newValue);
    // 如果组件仍然挂载
    if (mounted) {
      setState(() {
        _enableAutoBackup = newValue; // 设置自动备份状态
      });
    }

    // 如果启用了自动备份
    if (newValue) {
      // 如果组件仍然挂载
      if (mounted) {
        setState(() {
          _isBackingUp = true; // 设置正在备份状态
        });
      }

      try {
        // 执行备份操作
        final newHash = await widget.databaseService.performBackup();
        // 获取当前时间
        final now = DateTime.now();
        // 保存上次备份时间和哈希值
        await prefs.setInt(lastBackupTimeKey, now.millisecondsSinceEpoch);
        await prefs.setString(lastBackupHashKey, newHash);

        // 显示备份成功的提示
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.backupCreatedSuccessfully),
          ),
        );
        // 如果组件仍然挂载
        if (mounted) {
          setState(() {
            _lastBackupTime = now; // 设置上次备份时间
          });
        }
      } catch (e) {
        // 显示备份失败的提示
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.backupFailed(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error, // 错误背景色
          ),
        );
      } finally {
        // 如果组件仍然挂载
        if (mounted) {
          setState(() {
            _isBackingUp = false; // 重置正在备份状态
          });
        }
      }
    }
  }

  /// 显示快捷键录制对话框
  Future<void> _showShortcutRecorder() async {
    // 显示快捷键录制对话框
    final newShortcut = await showDialog<Set<LogicalKeyboardKey>>(
      context: context,
      builder: (context) =>
          ShortcutRecorderDialog(initialShortcut: _lockShortcut), // 传递初始快捷键
    );

    // 如果设置了新的快捷键
    if (newShortcut != null) {
      // 保存快捷键
      await ShortcutUtils.saveShortcut(newShortcut);
      // 如果组件仍然挂载
      if (mounted) {
        setState(() {
          _lockShortcut = newShortcut; // 设置锁定快捷键
        });
      }

      // 调用快捷键变化回调
      widget.onShortcutChanged?.call();

      // 显示设置已保存的提示
      widget.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)),
      );
    }
  }

  /// 清除快捷键
  Future<void> _clearShortcut() async {
    // 保存空快捷键（即清除快捷键）
    await ShortcutUtils.saveShortcut(null);
    // 如果组件仍然挂载
    if (mounted) {
      setState(() {
        _lockShortcut = null; // 清除锁定快捷键
      });
    }

    // 调用快捷键变化回调
    widget.onShortcutChanged?.call();

    // 显示设置已保存的提示
    widget.scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)),
    );
  }

  /// 格式化快捷键显示
  /// 
  /// [shortcut] 快捷键集合
  /// 返回格式化的快捷键字符串
  String _formatShortcut(Set<LogicalKeyboardKey>? shortcut) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;
    // 如果快捷键为空或空集合，返回"未设置"
    if (shortcut == null || shortcut.isEmpty) {
      return appLocalizations.shortcutNotSet;
    }

    // 获取所有键的显示标签
    final labels = shortcut.map((key) => _getKeyLabel(key, appLocalizations)).toList();
    // 对标签进行排序（修饰键优先）
    labels.sort((a, b) {
      final modifierLabels = [
        appLocalizations.shortcutCtrl,
        appLocalizations.shortcutShift,
        appLocalizations.shortcutAlt,
        appLocalizations.shortcutMeta,
      ];
      bool aIsModifierLabel = modifierLabels.contains(a);
      bool bIsModifierLabel = modifierLabels.contains(b);

      if (aIsModifierLabel && !bIsModifierLabel) return -1;
      if (!aIsModifierLabel && bIsModifierLabel) return 1;

      return a.compareTo(b);
    });
    // 用'+'连接所有标签
    return labels.join(' + ');
  }

  /// 获取键的显示标签
  /// 
  /// [key] 逻辑键盘键
  /// [appLocalizations] 本地化文本
  /// 返回键的显示标签
  String _getKeyLabel(LogicalKeyboardKey key, AppLocalizations appLocalizations) {
    // 根据键类型返回对应的标签
    switch (key) {
      case LogicalKeyboardKey.control:
      case LogicalKeyboardKey.controlLeft:
      case LogicalKeyboardKey.controlRight:
        return appLocalizations.shortcutCtrl; // Ctrl键
      case LogicalKeyboardKey.shift:
      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        return appLocalizations.shortcutShift; // Shift键
      case LogicalKeyboardKey.alt:
      case LogicalKeyboardKey.altLeft:
      case LogicalKeyboardKey.altRight:
        return appLocalizations.shortcutAlt; // Alt键
      case LogicalKeyboardKey.meta:
      case LogicalKeyboardKey.metaLeft:
      case LogicalKeyboardKey.metaRight:
        return appLocalizations.shortcutMeta; // Meta键
      default:
        // 对于字母键，转换为大写
        if (key.keyLabel.length == 1 &&
            key.keyLabel.runes.every((rune) => rune >= 0x61 && rune <= 0x7A)) {
          return key.keyLabel.toUpperCase();
        }
        // 其他键直接返回标签
        return key.keyLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    // 返回列表视图
    return ListView(
      padding: const EdgeInsets.all(16.0), // 内边距
      children: [
        // 外观设置卡片
        Card(
          margin: const EdgeInsets.only(bottom: 16.0), // 外边距
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 交叉轴起始对齐
              children: [
                // 标题：外观设置
                Text(
                  appLocalizations.appearanceSettings,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                // 主题设置
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined), // 亮度图标
                  title: Text(appLocalizations.theme), // "主题"
                  trailing: DropdownButton<ThemeMode>(
                    value: widget.themeService.themeMode, // 当前主题模式
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(appLocalizations.themeSystem), // "跟随系统"
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(appLocalizations.themeLight), // "浅色"
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(appLocalizations.themeDark), // "深色"
                      ),
                    ],
                    onChanged: (ThemeMode? newMode) {
                      // 主题模式变化回调
                      if (newMode != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.themeService.setTheme(newMode); // 设置新主题
                        });
                      }
                    },
                  ),
                ),
                // 语言设置
                ListTile(
                  leading: const Icon(Icons.language_outlined), // 语言图标
                  title: Text(appLocalizations.language), // "语言"
                  trailing: DropdownButton<String>(
                    value: widget.localeService.locale?.languageCode ?? 'zh', // 当前语言代码
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(appLocalizations.languageEnglish), // "英语"
                      ),
                      DropdownMenuItem(
                        value: 'zh',
                        child: Text(appLocalizations.languageChinese), // "中文"
                      ),
                    ],
                    onChanged: (value) {
                      // 语言变化回调
                      if (value != null) {
                        widget.localeService.setLocale(Locale(value, '')); // 设置新语言
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // 锁定数据库快捷键卡片
        Card(
          margin: const EdgeInsets.only(bottom: 16.0), // 外边距
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 交叉轴起始对齐
              children: [
                // 标题：锁定数据库快捷键
                Text(
                  appLocalizations.lockDatabaseShortcut,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                Column(
                  children: [
                    const SizedBox(height: 16.0),
                    // 快捷键显示区域
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 主轴居中对齐
                      children: [
                        // 快捷键文本
                        Text(
                          _formatShortcut(_lockShortcut), // 格式化后的快捷键
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold, // 粗体
                                fontSize: 24.0, // 字体大小
                                color: Theme.of(context).primaryColor, // 主色调
                              ),
                        ),
                        const SizedBox(width: 24.0),
                        // 编辑快捷键按钮
                        IconButton(
                          icon: const Icon(Icons.edit_outlined), // 编辑图标
                          onPressed: _showShortcutRecorder, // 显示快捷键录制对话框
                          tooltip: appLocalizations.editButton, // 工具提示："编辑"
                        ),
                        // 如果已设置快捷键，显示清除按钮
                        if (_lockShortcut != null)
                          IconButton(
                            icon: const Icon(Icons.clear_outlined), // 清除图标
                            onPressed: _clearShortcut, // 清除快捷键
                            tooltip: appLocalizations.deleteButton, // 工具提示："删除"
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // 备份设置卡片
        Card(
          margin: const EdgeInsets.only(bottom: 16.0), // 外边距
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 交叉轴起始对齐
              children: [
                // 标题和上次备份时间
                Row(
                  children: [
                    // 标题：备份设置
                    Text(
                      appLocalizations.backupSettings,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    // 上次备份时间标签
                    if (_enableAutoBackup && _lastBackupTime != null)
                      Text(
                        appLocalizations.lastBackupLabel(DateFormat.yMd(Localizations.localeOf(context).toString()).add_jm().format(_lastBackupTime!)), // "上次备份: 时间"
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green, // 绿色文本
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // 自动备份开关
                SwitchListTile(
                  secondary: const Icon(Icons.backup_outlined), // 备份图标
                  title: Text(appLocalizations.enableAutoBackup), // "启用自动备份"
                  value: _enableAutoBackup, // 开关状态
                  onChanged: _isBackingUp ? null : _toggleAutoBackup, // 根据备份状态启用或禁用
                  subtitle: _isBackingUp
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.0), // 加载指示器
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}