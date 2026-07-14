import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';

/// 快捷键录制对话框
/// 允许用户录制和设置锁定数据库的快捷键
class ShortcutRecorderDialog extends StatefulWidget {
  /// 初始快捷键设置
  final Set<LogicalKeyboardKey>? initialShortcut;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [initialShortcut] 初始快捷键设置
  const ShortcutRecorderDialog({super.key, this.initialShortcut});

  @override
  State<ShortcutRecorderDialog> createState() => _ShortcutRecorderDialogState();
}

/// 快捷键录制对话框状态类
class _ShortcutRecorderDialogState extends State<ShortcutRecorderDialog> {
  /// 当前录制的快捷键集合
  Set<LogicalKeyboardKey> _currentShortcut = {};
  
  /// 是否正在录制快捷键
  bool _isRecording = false;
  
  /// 焦点节点，用于接收键盘事件
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 初始化当前快捷键为初始设置或空集合
    _currentShortcut = widget.initialShortcut?.toSet() ?? {};
    // 设置为正在录制状态
    _isRecording = true;
    
    // 在下一帧请求焦点以便接收键盘事件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // 释放焦点节点资源
    _focusNode.dispose();
    super.dispose();
  }

  /// 处理键盘事件
  /// 
  /// [event] 键盘事件
  void _handleKeyEvent(KeyEvent event) {
    // 只处理按键按下事件
    if (event is KeyDownEvent) {
      // 忽略修饰键本身作为最终的快捷键组合
      if (event.logicalKey == LogicalKeyboardKey.control ||
          event.logicalKey == LogicalKeyboardKey.shift ||
          event.logicalKey == LogicalKeyboardKey.alt ||
          event.logicalKey == LogicalKeyboardKey.meta) {
        return;
      }

      // 如果按下了 Escape 键，取消录制并关闭对话框
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return;
      }

      // 构建当前按下的键组合
      final Set<LogicalKeyboardKey> keys = {};
      
      // 添加控制键（Ctrl）
      if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) || 
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.control)) {
        keys.add(LogicalKeyboardKey.control);
      }
      
      // 添加 Shift 键
      if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) || 
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shift)) {
        keys.add(LogicalKeyboardKey.shift);
      }
      
      // 添加 Alt 键
      if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.altLeft) || 
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.altRight) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.alt)) {
        keys.add(LogicalKeyboardKey.alt);
      }
      
      // 添加 Meta 键（Windows键或Command键）
      if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) || 
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaRight) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.meta)) {
        keys.add(LogicalKeyboardKey.meta);
      }
      
      // 添加主键（排除修饰键本身）
      if (event.logicalKey != LogicalKeyboardKey.controlLeft && 
          event.logicalKey != LogicalKeyboardKey.controlRight &&
          event.logicalKey != LogicalKeyboardKey.shiftLeft && 
          event.logicalKey != LogicalKeyboardKey.shiftRight &&
          event.logicalKey != LogicalKeyboardKey.altLeft && 
          event.logicalKey != LogicalKeyboardKey.altRight &&
          event.logicalKey != LogicalKeyboardKey.metaLeft && 
          event.logicalKey != LogicalKeyboardKey.metaRight) {
        keys.add(event.logicalKey);
      }
      
      // 更新状态：设置当前快捷键并结束录制
      setState(() {
        _currentShortcut = keys;
        _isRecording = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;
    
    // 返回焦点组件包装的对话框
    return Focus(
      focusNode: _focusNode,
      // 处理键盘事件
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      // 对话框内容
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(appLocalizations.lockDatabaseShortcut), // 对话框标题
        content: Column(
          mainAxisSize: MainAxisSize.min, // 内容最小高度
          children: [
            // 录制提示文本
            Text(
              _isRecording 
                  ? appLocalizations.shortcutRecording // 正在录制时的提示
                  : appLocalizations.pressShortcutToRecord, // 准备录制时的提示
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16), // 间距
            // 显示当前快捷键的容器
            Container(
              padding: const EdgeInsets.all(16), // 内边距
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline), // 边框
                borderRadius: BorderRadius.circular(8), // 圆角
              ),
              child: Text(
                _currentShortcut.isEmpty
                    ? appLocalizations.shortcutNotSet // 未设置快捷键时的文本
                    : _formatShortcut(_currentShortcut), // 已设置快捷键时的文本
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, // 粗体
                    ),
              ),
            ),
          ],
        ),
        // 对话框操作按钮
        actions: [
          // 取消按钮
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            child: Text(appLocalizations.cancelButton), // 取消按钮文本
          ),
          // 保存按钮
          TextButton(
            onPressed: _currentShortcut.isEmpty
                ? null // 如果未设置快捷键，按钮不可用
                : () => Navigator.of(context).pop(_currentShortcut), // 保存并返回快捷键
            child: Text(appLocalizations.saveButton), // 保存按钮文本
          ),
        ],
      ),
    );
  }

  /// 格式化快捷键显示
  /// 
  /// [shortcut] 要格式化的快捷键集合
  /// 返回格式化后的字符串
  String _formatShortcut(Set<LogicalKeyboardKey> shortcut) {
    // 获取所有键的显示标签
    final labels = shortcut.map((key) => _getKeyLabel(key)).toList();
    // 对标签进行排序
    labels.sort();
    // 用'+'连接所有标签
    return labels.join(' + ');
  }

  /// 获取键的显示标签
  /// 
  /// [key] 逻辑键盘键
  /// 返回键的显示标签
  String _getKeyLabel(LogicalKeyboardKey key) {
    // 特殊键的处理
    switch (key) {
      case LogicalKeyboardKey.control:
        return 'Ctrl'; // 控制键显示为Ctrl
      case LogicalKeyboardKey.shift:
        return 'Shift'; // Shift键显示为Shift
      case LogicalKeyboardKey.alt:
        return 'Alt'; // Alt键显示为Alt
      case LogicalKeyboardKey.meta:
        return 'Meta'; // Meta键显示为Meta
      default:
        // 对于字母键，转换为大写
        if (key.keyLabel.length == 1 && key.keyLabel.runes.every((rune) => rune >= 0x61 && rune <= 0x7A)) {
          return key.keyLabel.toUpperCase();
        }
        // 其他键直接返回标签
        return key.keyLabel;
    }
  }
}