import 'package:flutter/material.dart';
import 'package:pwbox/core/models/group.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// 一个显示回收站内容的小组件
/// 支持恢复项目、永久删除项目、清空回收站等功能
class RecycleBinView extends StatefulWidget {
  /// 数据库服务
  final DatabaseService databaseService;

  /// 恢复项目时调用的回调
  /// 
  /// [dynamic] 要恢复的项目
  final Function(dynamic) onRestore;

  /// 永久删除项目时调用的回调
  /// 
  /// [dynamic] 要永久删除的项目
  final Function(dynamic) onPermanentlyDelete;

  /// 构造函数
  /// 
  /// [key] 组件键
  /// [databaseService] 数据库服务
  /// [onRestore] 恢复项目回调
  /// [onPermanentlyDelete] 永久删除项目回调
  const RecycleBinView({
    super.key,
    required this.databaseService,
    required this.onRestore,
    required this.onPermanentlyDelete,
  });

  @override
  State<RecycleBinView> createState() => _RecycleBinViewState();
}

/// 回收站视图状态类
class _RecycleBinViewState extends State<RecycleBinView> {
  /// 已删除项目Future
  late Future<List<dynamic>> _deletedItemsFuture;

  @override
  void initState() {
    super.initState();
    // 初始化时获取已删除项目
    _deletedItemsFuture = widget.databaseService.getAllDeletedItems();
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    // 构建界面
    return Column(
      children: [
        // 顶部栏：回收站标题和清空回收站按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // 左侧：回收站标题
              Expanded(
                child: Text(
                  appLocalizations.recycleBin, // 回收站标题
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), // 标题样式
                ),
              ),
              // 右侧：清空回收站按钮
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever_outlined), // 永久删除图标
                label: Text(appLocalizations.emptyRecycleBin), // 按钮文本
                onPressed: () async {
                  // 显示确认对话框
                  final confirmed = await _showConfirmationDialog(
                    context,
                    appLocalizations.emptyRecycleBin, // 对话框标题
                    appLocalizations.emptyRecycleBinConfirmation, // 对话框内容
                  );
                  // 如果用户确认
                  if (confirmed == true) {
                    // 清空回收站
                    await widget.databaseService.emptyRecycleBin();
                    // 重新获取已删除项目
                    setState(() {
                      _deletedItemsFuture = widget.databaseService
                          .getAllDeletedItems();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        // 分割线
        const Divider(height: 1),
        // 中间：回收站内容列表
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _deletedItemsFuture, // 已删除项目Future
            builder: (context, snapshot) {
              // 如果正在加载
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // 显示加载指示器
              }
              // 如果出现错误
              if (snapshot.hasError) {
                return Center(child: Text(appLocalizations.errorLoadingData(snapshot.error.toString()))); // 显示错误信息
              }
              // 获取已删除项目列表
              final items = snapshot.data ?? [];
              // 如果列表为空
              if (items.isEmpty) {
                // 空状态提示
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_sweep_outlined, // 清扫图标
                        size: 64.0,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4), // 图标颜色
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        appLocalizations.recycleBinIsEmpty, // 空回收站提示
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6), // 文本颜色
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              // 内容列表
              return ListView.builder(
                itemCount: items.length, // 项目数量
                itemBuilder: (context, index) {
                  final item = items[index]; // 当前项目
                  return _buildItemTile(context, item); // 构建项目磁贴
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建一个项目磁贴
  /// 
  /// [context] 上下文
  /// [item] 项目
  /// 返回项目磁贴组件
  Widget _buildItemTile(BuildContext context, dynamic item) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;
    // 判断是否为分组
    final isGroup = item['parentId'] != null;

    // 返回卡片组件
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 外边距
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(isGroup ? Icons.folder_outlined : Icons.article_outlined), // 前置图标（分组或条目）
        title: Text(isGroup ? item['name'] as String : item['title'] as String), // 标题（分组名称或条目标题）
        subtitle: Text(
          appLocalizations.deletedAtLabel(DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(item['deletedAt'] as int))), // 删除时间
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.7), // 文本颜色
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 恢复按钮
            IconButton(
              icon: const Icon(Icons.restore_outlined), // 恢复图标
              tooltip: appLocalizations.restore, // 工具提示
              onPressed: () => widget.onRestore(item['id'] as String), // 恢复项目回调
            ),
            // 永久删除按钮
            IconButton(
              icon: const Icon(
                Icons.delete_forever_outlined, // 永久删除图标
                color: Colors.redAccent, // 红色
              ),
              tooltip: appLocalizations.permanentlyDelete, // 工具提示
              onPressed: () async {
                // 显示确认对话框
                final confirmed = await _showConfirmationDialog(
                  context,
                  appLocalizations.permanentlyDelete, // 对话框标题
                  appLocalizations.permanentlyDeleteConfirmation, // 对话框内容
                );
                // 如果用户确认
                if (confirmed == true) {
                  widget.onPermanentlyDelete(item['id'] as String); // 永久删除项目回调
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示一个确认对话框
  /// 
  /// [context] 上下文
  /// [title] 对话框标题
  /// [content] 对话框内容
  /// 返回用户的选择（true表示确认，false表示取消，null表示关闭对话框）
  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title), // 对话框标题
        content: Text(content), // 对话框内容
        actions: [
          // 取消按钮
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // 返回false
            child: Text(AppLocalizations.of(context)!.cancelButton), // 按钮文本
          ),
          // 确定按钮
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // 返回true
            child: Text(
              AppLocalizations.of(context)!.okButton, // 按钮文本
              style: const TextStyle(color: Colors.red), // 红色文本
            ),
          ),
        ],
      ),
    );
  }
}
