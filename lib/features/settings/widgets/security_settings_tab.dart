import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/features/settings/widgets/change_password_dialog.dart';
import 'package:pwbox/features/settings/widgets/two_factor_auth_screen.dart';
import 'package:pwbox/features/settings/widgets/disable_2fa_dialog.dart';
import 'package:pwbox/core/utils/constants.dart';

/// 安全设置标签页
/// 包含数据库设置和安全功能设置
class SecuritySettingsTab extends StatefulWidget {
  /// 数据库路径
  final String dbPath;
  
  /// 数据库服务
  final DatabaseService databaseService;
  
  /// 锁定请求回调
  final VoidCallback onLockRequested;
  
  /// 是否启用双因素认证
  final bool is2faEnabled;
  
  /// ScaffoldMessenger键
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [dbPath] 数据库路径
  /// [databaseService] 数据库服务
  /// [onLockRequested] 锁定请求回调
  /// [is2faEnabled] 是否启用双因素认证
  /// [scaffoldMessengerKey] ScaffoldMessenger键
  const SecuritySettingsTab({
    super.key,
    required this.dbPath,
    required this.databaseService,
    required this.onLockRequested,
    required this.is2faEnabled,
    this.scaffoldMessengerKey,
  });

  @override
  State<SecuritySettingsTab> createState() => _SecuritySettingsTabState();
}

/// 安全设置标签页状态类
class _SecuritySettingsTabState extends State<SecuritySettingsTab> {
  /// 选择的自动锁定超时时间（分钟）
  int _selectedAutoLockTimeout = 0;
  
  /// 选择的回收站保留时间（天）
  int _selectedRecycleBinRetention = 0;
  
  /// 是否启用双因素认证
  late bool _is2faEnabled;

  @override
  void initState() {
    super.initState();
    // 初始化双因素认证状态
    _is2faEnabled = widget.is2faEnabled;
    // 加载其他设置
    _loadOtherSettings();
  }

  @override
  void didUpdateWidget(covariant SecuritySettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果双因素认证状态发生变化，更新状态
    if (oldWidget.is2faEnabled != widget.is2faEnabled) {
      setState(() {
        _is2faEnabled = widget.is2faEnabled;
      });
    }
  }

  /// 加载其他设置
  Future<void> _loadOtherSettings() async {
    // 获取共享偏好设置实例
    final prefs = await SharedPreferences.getInstance();
    // 更新状态
    setState(() {
      // 获取自动锁定超时时间
      _selectedAutoLockTimeout = prefs.getInt(autoLockTimeoutKey) ?? 0;
      // 获取回收站保留时间
      _selectedRecycleBinRetention = prefs.getInt(recycleBinRetentionKey) ?? 0;
    });
  }

  /// 自动锁定时间变化回调
  /// 
  /// [newValue] 新的自动锁定时间（分钟）
  Future<void> _onAutoLockChanged(int? newValue) async {
    // 如果新值为空，直接返回
    if (newValue == null) return;
    // 获取共享偏好设置实例
    final prefs = await SharedPreferences.getInstance();
    // 保存自动锁定超时时间
    await prefs.setInt(autoLockTimeoutKey, newValue);
    // 更新状态
    setState(() {
      _selectedAutoLockTimeout = newValue;
    });
  }

  /// 禁用双因素认证
  Future<void> _disable2fa() async {
    // 显示禁用双因素认证对话框
    await showDialog<void>(
      context: context,
      builder: (context) => Disable2faDialog(
        databaseService: widget.databaseService, // 数据库服务
        scaffoldMessengerKey: widget.scaffoldMessengerKey, // ScaffoldMessenger键
        on2faDisabled: () {
          // 如果组件仍然挂载
          if (mounted) {
            setState(() {
              _is2faEnabled = false; // 设置双因素认证状态为禁用
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    // 返回列表视图
    return ListView(
      padding: const EdgeInsets.all(16.0), // 内边距
      children: [
        // 数据库设置卡片
        Card(
          margin: const EdgeInsets.only(bottom: 16.0), // 外边距
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 交叉轴起始对齐
              children: [
                // 标题：数据库设置
                Text(
                  appLocalizations.databaseSettings,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                // 数据库路径
                ListTile(
                  leading: const Icon(Icons.storage_outlined), // 存储图标
                  title: Text(appLocalizations.databasePath), // "数据库路径"
                  subtitle: Text(widget.dbPath), // 数据库路径
                ),
                // 更改主密码
                ListTile(
                  leading: const Icon(Icons.password_outlined), // 密码图标
                  title: Text(appLocalizations.changeMasterPassword), // "更改主密码"
                  enabled: true, // 启用状态
                  onTap: () {
                    // 点击时显示更改密码对话框
                    showDialog(
                      context: context,
                      builder: (context) => ChangePasswordDialog(
                        dbPath: widget.dbPath, // 数据库路径
                        databaseService: widget.databaseService, // 数据库服务
                      ),
                    ).then((result) {
                      // 如果密码更改成功，请求锁定数据库
                      if (result == true) {
                        widget.onLockRequested();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        // 安全功能卡片
        Card(
          margin: const EdgeInsets.only(bottom: 16.0), // 外边距
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 交叉轴起始对齐
              children: [
                // 标题：安全功能
                Text(
                  appLocalizations.securityFeatures,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                // 自动锁定数据库
                ListTile(
                  leading: const Icon(Icons.lock_clock_outlined), // 锁定时钟图标
                  title: Text(appLocalizations.autoLockDatabase), // "自动锁定数据库"
                  trailing: DropdownButton<int>(
                    value: _selectedAutoLockTimeout, // 当前选择的超时时间
                    items: [
                      DropdownMenuItem(value: 0, child: Text(appLocalizations.never)), // "从不"
                      DropdownMenuItem(value: 1, child: Text(appLocalizations.oneMinute)), // "1分钟"
                      DropdownMenuItem(value: 5, child: Text(appLocalizations.fiveMinutes)), // "5分钟"
                      DropdownMenuItem(value: 15, child: Text(appLocalizations.fifteenMinutes)), // "15分钟"
                    ],
                    onChanged: _onAutoLockChanged, // 变化回调
                  ),
                ),
                // 启用双因素认证开关
                SwitchListTile(
                  secondary: const Icon(Icons.security), // 安全图标
                  title: Text(appLocalizations.enable2fa), // "启用双因素认证"
                  value: _is2faEnabled, // 开关状态
                  onChanged: (value) {
                    // 开关状态变化回调
                    if (value) {
                      // 如果启用双因素认证，显示双因素认证屏幕
                      showDialog(
                        context: context,
                        builder: (context) => TwoFactorAuthScreen(
                          databaseService: widget.databaseService, // 数据库服务
                        ),
                      ).then((result) {
                        // 如果设置成功
                        if (result == true) {
                          setState(() {
                            _is2faEnabled = true; // 设置双因素认证状态为启用
                          });
                          widget.onLockRequested(); // 请求锁定数据库
                        }
                      });
                    } else {
                      // 如果禁用双因素认证，调用禁用方法
                      _disable2fa();
                    }
                  },
                ),
                // 回收站保留时间
                ListTile(
                  leading: const Icon(Icons.restore_from_trash_outlined), // 恢复垃圾桶图标
                  title: Text(appLocalizations.recycleBinRetention), // "回收站保留"
                  trailing: DropdownButton<int>(
                    value: _selectedRecycleBinRetention, // 当前选择的保留时间
                    items: [
                      DropdownMenuItem(value: 0, child: Text(appLocalizations.never)), // "从不"
                      DropdownMenuItem(value: 7, child: Text(appLocalizations.sevenDays)), // "7天"
                      DropdownMenuItem(value: 30, child: Text(appLocalizations.thirtyDays)), // "30天"
                      DropdownMenuItem(value: 90, child: Text(appLocalizations.ninetyDays)), // "90天"
                      DropdownMenuItem(value: 180, child: Text(appLocalizations.oneHundredEightyDays)), // "180天"
                      DropdownMenuItem(value: 365, child: Text(appLocalizations.threeHundredSixtyFiveDays)), // "365天"
                    ],
                    onChanged: _onRecycleBinRetentionChanged, // 变化回调
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 回收站保留时间变化回调
  /// 
  /// [newValue] 新的回收站保留时间（天）
  Future<void> _onRecycleBinRetentionChanged(int? newValue) async {
    // 如果新值为空，直接返回
    if (newValue == null) return;
    // 获取共享偏好设置实例
    final prefs = await SharedPreferences.getInstance();
    // 保存回收站保留时间
    await prefs.setInt(recycleBinRetentionKey, newValue);
    // 更新状态
    setState(() {
      _selectedRecycleBinRetention = newValue;
    });
  }
}
