import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/utils/constants.dart';
import 'package:pwbox/features/database_setup/unlock_screen.dart';
import 'package:pwbox/features/database_setup/welcome_screen.dart';
import 'package:pwbox/features/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/locale_service.dart';
import 'package:pwbox/core/services/theme_service.dart';
import 'package:pwbox/core/theme/app_theme.dart';
import 'package:pwbox/core/utils/window_manager_helper.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as p;

/// 程序入口点
void main() async {
  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 确保窗口管理器已初始化
  await windowManager.ensureInitialized();

  // 等待窗口准备好显示
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(400, 600), // 窗口大小
      center: true, // 窗口居中
      skipTaskbar: false, // 不跳过任务栏
    ),
    () async {
      // 设置认证窗口大小
      await WindowManagerHelper.setAuthWindowSize();
      // 显示窗口
      await windowManager.show();
      // 聚焦窗口
      await windowManager.focus();
    },
  );

  // 如果是Windows或Linux平台，初始化sqflite FFI
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 初始化时区数据
  tzdata.initializeTimeZones();

  // 获取共享偏好设置实例
  final prefs = await SharedPreferences.getInstance();
  // 运行主应用
  runApp(PwBoxApp(prefs: prefs));
}

/// PwBox主应用组件
class PwBoxApp extends StatefulWidget {
  // 共享偏好设置实例
  final SharedPreferences prefs;

  // 构造函数
  const PwBoxApp({super.key, required this.prefs});

  @override
  State<PwBoxApp> createState() => _PwBoxAppState();
}

/// PwBox主应用状态
class _PwBoxAppState extends State<PwBoxApp> {
  // 数据库服务实例
  DatabaseService? _databaseService;

  @override
  void initState() {
    super.initState();
  }

  /// 处理锁定数据库的函数
  Future<void> _handleLock() async {
    // 锁定数据库
    await _databaseService?.lock();
    // 显示认证窗口，并在回调中更新状态
    await WindowManagerHelper.showAuthWindow(() {
      setState(() {
        _databaseService = null;
      });
    });
  }

  /// 处理解锁数据库的函数
  Future<void> _handleUnlock(DatabaseService dbService) async {
    // 显示主窗口
    await WindowManagerHelper.showMainWindow(() {
      // 更新状态，设置数据库服务
      setState(() {
        _databaseService = dbService;
      });
    });
    // 运行自动备份检查
    _runAutoBackupCheck(dbService);
  }

  /// 运行自动备份检查的函数
  Future<void> _runAutoBackupCheck(DatabaseService dbService) async {
    // 获取共享偏好设置实例
    final prefs = await SharedPreferences.getInstance();
    // 检查是否启用了自动备份
    final isAutoBackupEnabled = prefs.getBool(enableAutoBackupKey) ?? false;

    // 如果启用了自动备份
    if (isAutoBackupEnabled) {
      // 获取上次备份时间
      final lastBackupMillis = prefs.getInt(lastBackupTimeKey) ?? 0;
      final lastBackupTime = DateTime.fromMillisecondsSinceEpoch(
        lastBackupMillis,
      );
      // 获取当前时间
      final now = DateTime.now();

      // 如果距离上次备份已超过24小时
      if (now.difference(lastBackupTime).inHours >= 24) {
        try {
          // 获取数据库容器路径
          final dbContainerPath = p.dirname(dbService.dbPath);
          // 获取上次备份的哈希值
          final lastHash = prefs.getString(lastBackupHashKey) ?? '';
          // 获取当前数据库文件的哈希值
          final currentHash = await DatabaseService.getDbFileHash(
            dbContainerPath,
          );

          // 如果当前哈希值不为空且与上次哈希值不同
          if (currentHash.isNotEmpty && currentHash != lastHash) {
            // 执行备份操作
            final newHash = await dbService.performBackup();
            // 更新备份时间
            await prefs.setInt(lastBackupTimeKey, now.millisecondsSinceEpoch);
            // 更新备份哈希值
            await prefs.setString(lastBackupHashKey, newHash);
            debugPrint("自动备份创建成功 (数据库已更改).");
          } else {
            // 更新备份时间
            await prefs.setInt(lastBackupTimeKey, now.millisecondsSinceEpoch);
            debugPrint("跳过自动备份 (数据库未更改).");
          }
        } catch (e) {
          debugPrint("自动备份失败: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用MultiProvider提供主题和区域设置服务
    return MultiProvider(
      providers: [
        // 提供主题服务
        ChangeNotifierProvider(create: (_) => ThemeService(widget.prefs)),
        // 提供区域设置服务
        ChangeNotifierProvider(create: (_) => LocaleService(widget.prefs)),
      ],
      // 使用Consumer2监听主题和区域设置服务
      child: Consumer2<ThemeService, LocaleService>(
        builder: (context, themeService, localeService, child) {
          // 返回MaterialApp组件
          return MaterialApp(
            debugShowCheckedModeBanner: false, // 隐藏调试横幅
            title: 'PwBox - 绝对安全的密码管理器', // 应用程序标题
            theme: AppTheme.lightTheme, // 浅色主题
            darkTheme: AppTheme.darkTheme, // 深色主题
            themeMode: themeService.themeMode, // 主题模式
            locale: localeService.locale, // 区域设置
            localizationsDelegates:
                AppLocalizations.localizationsDelegates, // 本地化委托
            supportedLocales: AppLocalizations.supportedLocales, // 支持的语言环境
            home: _buildHomeScreen(themeService.isDarkMode), // 主页
          );
        },
      ),
    );
  }

  /// 构建主页屏幕的函数
  Widget _buildHomeScreen(bool isDarkMode) {
    // 如果数据库服务存在
    if (_databaseService != null) {
      // 返回主页屏幕
      return HomeScreen(
        databaseService: _databaseService!,
        onLock: _handleLock, // 锁定回调
      );
    }

    // 返回FutureBuilder，根据数据库路径构建界面
    return FutureBuilder<String?>(
      future: _getDbPath(), // 获取数据库路径的异步函数
      builder: (context, snapshot) {
        // 如果连接状态为完成
        if (snapshot.connectionState == ConnectionState.done) {
          // 获取数据库路径
          final dbPath = snapshot.data;
          // 如果数据库路径存在
          if (dbPath != null) {
            // 返回解锁屏幕
            return UnlockScreen(
              filePath: dbPath, // 数据库文件路径
              onUnlock: _handleUnlock, // 解锁回调
              onSwitchDatabase: () {
                // 清除保存的数据库路径，返回欢迎屏幕以选择新数据库
                final prefs = SharedPreferences.getInstance();
                prefs.then((p) => p.remove(dbPathKey));
                setState(() {});
              }, // 切换数据库回调，清除路径并重新运行future
            );
          }
          // 返回欢迎屏幕
          return const WelcomeScreen();
        }
        // 返回加载指示器
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  /// 获取数据库路径的异步函数
  Future<String?> _getDbPath() async {
    // 从共享偏好设置中获取路径
    final path = widget.prefs.getString(dbPathKey);
    // 如果路径存在
    if (path != null) {
      // 构建数据库文件路径
      final dbFile = File(p.join(path, 'database.pdbw'));
      // 如果数据库文件存在
      if (await dbFile.exists()) {
        // 返回路径
        return path;
      }
    }
    // 返回null
    return null;
  }
}