import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// 窗口配置服务
/// 提供窗口管理功能，如调整大小、居中等
class WindowConfigService extends ChangeNotifier {
  /// 设置窗口配置
  /// 
  /// [isResizable] 窗口是否可调整大小
  /// [showMaximizeButton] 是否显示最大化按钮
  /// [newSize] 新的窗口大小
  Future<void> setWindowConfig({
    required bool isResizable,
    required bool showMaximizeButton,
    Size? newSize,
  }) async {
    // 设置窗口是否可调整大小
    await windowManager.setResizable(isResizable);
    // 如果指定了新的窗口大小，则设置
    if (newSize != null) {
      await windowManager.setSize(newSize);
    }
    // 在window_manager中，初始化后以跨平台方式显示/隐藏特定按钮的功能不可用
    // 如果这是一个硬性要求，可能需要平台特定的代码
    notifyListeners();
  }

  /// 将窗口居中显示
  void centerWindow() {
    windowManager.center();
  }
}
