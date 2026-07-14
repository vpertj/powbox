import 'package:flutter/material.dart';
import 'package:pwbox/features/database_setup/create_database_screen.dart';
import 'package:pwbox/features/database_setup/unlock_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwbox/core/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/features/home/home_screen.dart';
import 'package:pwbox/core/utils/window_manager_helper.dart';

/// 欢迎屏幕
/// 为用户提供创建新数据库或打开现有数据库的选项
class WelcomeScreen extends StatelessWidget {
  /// 构造函数
  /// 
  /// [key] 组件键
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    // 构建用户界面
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.welcomeTitle), // 应用栏标题
        automaticallyImplyLeading: false, // 不自动显示返回按钮
        centerTitle: true, // 标题居中
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 欢迎标题
              Text(
                appLocalizations.welcomeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 60),
              // 创建数据库按钮
              ElevatedButton(
                onPressed: () {
                  // 导航到创建数据库屏幕
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateDatabaseScreen(
                        onUnlock: (DatabaseService dbService, bool isDarkMode) {
                          // 调用窗口管理器来调整大小并显示主窗口
                          WindowManagerHelper.showMainWindow(() {
                            // 导航到主页屏幕
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                    databaseService: dbService,
                                    onLock: () {
                                      // 锁定数据库并返回欢迎屏幕
                                      dbService.lock();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50), // 按钮最小尺寸
                ),
                child: Text(appLocalizations.createDatabase), // 按钮文本
              ),
              const SizedBox(height: 20),
              // 打开数据库按钮（带弹出菜单）
              PopupMenuButton<String>(
                onSelected: (value) async {
                  // 根据选择的值处理不同操作
                  if (value == 'local') {
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

                    // 如果上下文仍然挂载，导航到解锁屏幕
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UnlockScreen(
                                filePath: directoryPath, // 数据库文件路径
                                onUnlock: (DatabaseService dbService) {
                                  // 导航到主页屏幕
                                  print('Unlock callback executed, context.mounted: $context.mounted');
                                  if (context.mounted) {
                                    print('Navigating to HomeScreen');
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                          databaseService: dbService,
                                          onLock: () {
                                            // 锁定数据库并返回欢迎屏幕
                                            dbService.lock();
                                            if (context.mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const WelcomeScreen(),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('Context not mounted, cannot navigate to HomeScreen');
                                  }
                                },
                                onSwitchDatabase: () {
                                  // 返回欢迎屏幕以允许用户选择不同的数据库
                                  print('Switch database callback executed, context.mounted: $context.mounted');
                                  if (context.mounted) {
                                    print('Navigating to WelcomeScreen');
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const WelcomeScreen(),
                                      ),
                                    );
                                  } else {
                                    print('Context not mounted, cannot navigate');
                                  }
                                },
                              ),
                        ),
                      );
                    }
                  } else if (value == 'network') {
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
                // 弹出菜单项
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'local',
                    child: Text(appLocalizations.openLocalDatabase), // 本地数据库选项
                  ),
                  PopupMenuItem<String>(
                    value: 'network',
                    child: Text(appLocalizations.openNetworkDatabase), // 网络数据库选项
                  ),
                ],
                // 子组件（按钮）
                child: ElevatedButton(
                  onPressed: null, // 禁用按钮，让PopupMenuButton处理点击
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50), // 按钮最小尺寸
                  ),
                  child: Text(appLocalizations.openDatabase), // 按钮文本
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}