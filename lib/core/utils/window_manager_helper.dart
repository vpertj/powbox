import 'package:window_manager/window_manager.dart';
import 'dart:ui'; // 导入 dart:ui 以使用 Size

/// 窗口管理助手，用于调整窗口大小和属性
class WindowManagerHelper {
  /// 调整窗口到主界面大小
  static Future<void> setMainWindowSize() async {
    await windowManager.setTitle('PwBox - 绝对安全的密码管理器'); // 设置窗口标题
    await windowManager.setResizable(true);
    await windowManager.setMaximizable(true);
    await windowManager.setMinimumSize(const Size(800, 600));
    await windowManager.setSize(const Size(1400, 900));
    await windowManager.center();
  }

  /// 调整窗口到认证界面大小 (欢迎/解锁)
  static Future<void> setAuthWindowSize() async {
    await windowManager.setTitle('PwBox - 绝对安全的密码管理器'); // 设置窗口标题
    await windowManager.setMinimumSize(const Size(400, 500));
    await windowManager.setSize(const Size(400, 600));
    await windowManager.center();
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
  }

  /// 调整窗口到主界面大小并执行回调
  static Future<void> showMainWindow(Function callback) async {
    // 先隐藏窗口
    await windowManager.hide();

    // 设置窗口大小和标题
    await setMainWindowSize();

    // 执行回调
    callback();

    // 立即显示窗口
    await windowManager.show();
    await windowManager.focus();

    // 确保窗口大小正确
    await Future.delayed(const Duration(milliseconds: 100));
    await setMainWindowSize();
  }

  /// 调整窗口到认证界面大小并执行回调
  static Future<void> showAuthWindow(Function callback) async {
    // 设置窗口大小和标题
    await setAuthWindowSize();

    // 执行回调以重建UI
    callback();
  }
}