import 'package:flutter/material.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/services/locale_service.dart';
import 'package:pwbox/core/services/theme_service.dart';
import 'package:pwbox/features/settings/widgets/about_settings_tab.dart';
import 'package:pwbox/features/settings/widgets/general_settings_tab.dart';
import 'package:pwbox/features/settings/widgets/security_settings_tab.dart';

/// 设置屏幕
/// 包含通用设置、安全设置和关于设置三个标签页
class SettingsScreen extends StatefulWidget {
  /// 数据库路径
  final String dbPath;

  /// 数据库服务
  final DatabaseService databaseService;

  /// 主题服务
  final ThemeService themeService;

  /// 区域设置服务
  final LocaleService localeService;

  /// 锁定请求回调
  final VoidCallback onLockRequested;

  /// 快捷键变化回调
  final VoidCallback? onShortcutChanged;

  /// 是否启用双因素认证
  final bool is2faEnabled;

  /// 构造函数
  ///
  /// [key] 组件键
  /// [dbPath] 数据库路径
  /// [databaseService] 数据库服务
  /// [themeService] 主题服务
  /// [localeService] 区域设置服务
  /// [onLockRequested] 锁定请求回调
  /// [onShortcutChanged] 快捷键变化回调
  /// [is2faEnabled] 是否启用双因素认证
  const SettingsScreen({
    super.key,
    required this.dbPath,
    required this.databaseService,
    required this.themeService,
    required this.localeService,
    required this.onLockRequested,
    this.onShortcutChanged,
    required this.is2faEnabled,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// 设置屏幕状态类
class _SettingsScreenState extends State<SettingsScreen> {
  /// ScaffoldMessenger键
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    final List<Widget> pages = [
      // 通用设置标签页
      GeneralSettingsTab(
        scaffoldMessengerKey: _scaffoldMessengerKey, // ScaffoldMessenger键
        databaseService: widget.databaseService, // 数据库服务
        themeService: widget.themeService, // 主题服务
        localeService: widget.localeService, // 区域设置服务
        onShortcutChanged: widget.onShortcutChanged, // 快捷键变化回调
      ),
      // 安全设置标签页
      SecuritySettingsTab(
        dbPath: widget.dbPath, // 数据库路径
        databaseService: widget.databaseService, // 数据库服务
        onLockRequested: widget.onLockRequested, // 锁定请求回调
        is2faEnabled: widget.is2faEnabled, // 是否启用双因素认证
        scaffoldMessengerKey: _scaffoldMessengerKey, // ScaffoldMessenger键
      ),
      // 关于设置标签页
      const AboutSettingsTab(),
    ];

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48.0,
          title: Text(appLocalizations.settingsTitle), // 标题
          automaticallyImplyLeading: false, // 对话框中不显示返回按钮
          actions: [
            // 关闭按钮
            IconButton(
              icon: const Icon(Icons.close_outlined), // 关闭图标
              tooltip: appLocalizations.closeButton, // 工具提示
              onPressed: () => Navigator.of(context).pop(), // 关闭设置界面
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(appLocalizations.generalSettingsTab),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.security_outlined),
                  selectedIcon: const Icon(Icons.security),
                  label: Text(appLocalizations.securitySettingsTab),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.info_outline),
                  selectedIcon: const Icon(Icons.info),
                  label: Text(appLocalizations.aboutSettingsTab),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}