import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pwbox/core/models/entry.dart';
import 'package:pwbox/core/models/group.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwbox/core/utils/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:pwbox/core/models/attachment.dart';
import 'package:pwbox/core/models/exceptions.dart';

/// 主页视图模型
/// 管理主页界面的状态和数据
class HomeViewModel extends ChangeNotifier {
  /// 数据库服务实例
  final DatabaseService databaseService;

  /// 就绪完成器
  final Completer<void> _readyCompleter = Completer<void>();

  /// 就绪Future
  Future<void> get ready => _readyCompleter.future;

  /// 共享偏好设置实例
  late SharedPreferences _prefs;

  // 私有状态
  /// 分组列表
  List<Group> _groups = [];

  // 条目列表
  List<Entry> _entries = [];
  // 是否正在加载条目
  bool _isLoadingEntries = false;

  /// 选中的分组
  Group? _selectedGroup;

  /// 是否选择了回收站
  bool _isRecycleBinSelected = false;

  /// 搜索查询
  String _searchQuery = '';

  /// 拖拽目标分组ID（用于拖拽和放置目标高亮）
  String? _dragTargetGroupId;

  /// 悬停的条目ID（用于条目列表悬停状态）
  String? _hoveredEntryId;

  /// 选中的条目（用于条目列表选中状态）
  Entry? _selectedEntry;

  /// 正在删除动画的条目ID集合
  final Set<String> _animatingDeletedEntryIds = {};

  /// 防抖计时器
  Timer? _debounce;

  /// 回收站视图键
  Key _recycleBinViewKey = UniqueKey();

  // 公共获取器
  /// 获取分组列表
  List<Group> get groups => _groups;

  /// 获取条目列表
  List<Entry> get entries => _entries;

  /// 获取是否正在加载条目
  bool get isLoadingEntries => _isLoadingEntries;

  /// 获取选中的分组
  Group? get selectedGroup => _selectedGroup;

  /// 是否选择了回收站
  bool get isRecycleBinSelected => _isRecycleBinSelected;

  /// 获取搜索查询
  String get searchQuery => _searchQuery;

  /// 是否处于搜索活动状态
  bool get isSearchActive => _searchQuery.isNotEmpty;

  /// 获取拖拽目标分组ID
  String? get dragTargetGroupId => _dragTargetGroupId;

  /// 获取悬停的条目ID
  String? get hoveredEntryId => _hoveredEntryId;

  /// 获取选中的条目
  Entry? get selectedEntry => _selectedEntry;

  /// 获取正在删除动画的条目ID集合
  Set<String> get animatingDeletedEntryIds => _animatingDeletedEntryIds;

  /// 获取回收站视图键
  Key get recycleBinViewKey => _recycleBinViewKey;

  /// 视图模式：是否为网格视图
  bool _isGridView = false;
  bool get isGridView => _isGridView;

  /// 构造函数
  ///
  /// [databaseService] 数据库服务实例
  HomeViewModel(this.databaseService) {
    _init(); // 调用异步初始化方法
  }

  /// 初始化方法
  Future<void> _init() async {
    // 获取共享偏好设置实例
    _prefs = await SharedPreferences.getInstance();
    // 加载用户上次选择的视图模式，默认为列表视图
    _isGridView = _prefs.getBool('isGridView') ?? false;
    // 加载分组
    await _loadGroups();
    // 如果有分组，选择第一个分组
    if (_groups.isNotEmpty) {
      onGroupSelected(_groups.first);
    } else {
      notifyListeners();
    }
    // 获取回收站保留天数
    final retentionDays = _prefs.getInt(recycleBinRetentionKey) ?? 0;
    // 如果保留天数大于0，清理旧项目
    if (retentionDays > 0) {
      await databaseService.purgeOldItems(retentionDays);
    }
    // 加载条目
    await _loadEntries();
    // 完成就绪状态
    _readyCompleter.complete();
  }

  /// 切换视图模式（列表/网格）
  Future<void> toggleView() async {
    _isGridView = !_isGridView;
    await _prefs.setBool('isGridView', _isGridView);
    notifyListeners();
  }

  /// 加载分组
  Future<void> _loadGroups() async {
    // 从数据库获取所有分组
    final groupsData = await databaseService.getAllGroups();
    _groups = groupsData.map((groupData) => Group.fromJson(groupData)).toList();
    // 通知监听器
    notifyListeners();
  }

  /// 加载条目
  Future<void> _loadEntries() async {
    if (_selectedGroup == null && _searchQuery.isEmpty) {
      _entries = [];
      _isLoadingEntries = false;
      notifyListeners();
      return;
    }

    _isLoadingEntries = true;
    notifyListeners();

    try {
      if (_searchQuery.isNotEmpty) {
        final entriesData = await databaseService.searchEntries(_searchQuery);
        _entries = entriesData.map((data) => Entry.fromJson(data)).toList();
      } else if (_selectedGroup != null) {
          final entriesData = await databaseService.getEntries(_selectedGroup!.id);
          _entries = entriesData.map((data) => Entry.fromJson(data)).toList();
        }
    } catch (e) {
      // Handle potential errors, maybe log them or set an error state
      _entries = [];
    } finally {
      _isLoadingEntries = false;
      notifyListeners();
    }
  }

  /// 分组选择回调
  ///
  /// [group] 选中的分组
  void onGroupSelected(Group? group) {
    _selectedGroup = group;
    _selectedEntry = null; // 清除选中的条目
    _isRecycleBinSelected = false;
    _searchQuery = ''; // Clear search on group selection
    _loadEntries();
  }

  /// 回收站选择回调
  void onRecycleBinSelected() {
    // 清除选中的分组
    _selectedGroup = null;
    // 设置选择了回收站
    _isRecycleBinSelected = true;
    // 清除搜索
    onSearchChanged('');
    _entries = [];
    // 通知监听器
    notifyListeners();
  }

  /// 搜索变化回调
  ///
  /// [query] 搜索查询
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      _loadEntries();
    });
  }

  /// 添加分组
  /// 
  /// [name] 分组名称
  /// [parentId] 父分组ID
  Future<void> addGroup(String name, String? parentId) async {
    // 创建新分组
    final newGroup = Group(
      id: const Uuid().v4(), // 生成唯一ID
      name: name, // 分组名称
      parentId: parentId, // 父分组ID
    );
    // 添加分组到数据库
    await databaseService.addGroup(newGroup.toJson());
    // 重新加载分组
    await _loadGroups();
  }

  /// 重命名分组
  /// 
  /// [group] 分组
  /// [newName] 新名称
  Future<void> renameGroup(Group group, String newName) async {
    // 设置新名称
    group.name = newName;
    // 更新分组
    await databaseService.updateGroup(group.id, group.toJson());
    // 重新加载分组
    await _loadGroups();
  }

  /// 删除分组
  ///
  /// [group] 分组
  Future<void> deleteGroup(Group group) async {
    // 获取分组中的条目数量
    final entryCount = await databaseService.getEntryCount(group.id);
    // 如果条目数量大于0，抛出异常
    if (entryCount > 0) {
      throw GroupNotEmptyException('分组包含条目。');
    }
    // 检查是否有子分组
    final hasSubgroups = await databaseService.hasSubgroups(
      group.id,
    );
    // 如果有子分组，抛出异常
    if (hasSubgroups) {
      throw GroupHasSubgroupsException('分组包含子分组。');
    }

    // 从数据库删除分组
    await databaseService.deleteGroup(group.id);
    // 重新加载分组
    await _loadGroups();
    // 如果删除的是当前选中的分组，清除选中状态
    if (_selectedGroup?.id == group.id) {
      onGroupSelected(null);
    }
  }

  /// 添加条目
  ///
  /// [entry] 要添加的条目
  Future<void> addEntry(Entry entry) async {
    // 将条目数据添加到数据库
    await databaseService.addEntry(entry.toJson());
    // 重新加载条目以确保UI与数据库同步
    await _loadEntries();
  }

  /// 更新条目
  ///
  /// [entry] 要更新的条目
  Future<void> updateEntry(Entry entry) async {
    // 更新数据库中的条目数据
    await databaseService.updateEntry(entry.id, entry.toJson());
    // 重新加载条目以确保UI与数据库同步
    await _loadEntries();
  }

  /// 删除条目
  ///
  /// [entry] 条目
  Future<void> deleteEntry(Entry entry) async {
    // 将条目ID添加到正在删除动画的集合中
    _animatingDeletedEntryIds.add(entry.id);
    notifyListeners();

    // 延迟300毫秒以显示删除动画
    await Future.delayed(const Duration(milliseconds: 300));
    // 从数据库删除条目
    await databaseService.deleteEntry(entry.id);
    // 重新加载条目
    await _loadEntries();
    // 从正在删除动画的集合中移除条目ID
    _animatingDeletedEntryIds.remove(entry.id);
    notifyListeners();
  }

  /// 移动条目
  ///
  /// [entry] 条目
  /// [newGroup] 新分组
  Future<void> moveEntry(Entry entry, Group newGroup) async {
    // 移动条目到新分组
    await databaseService.moveEntry(entry.id, newGroup.id);
    // 重新加载条目
    _loadEntries();
  }

  /// 添加附件
  /// 
  /// [entryId] 条目ID
  /// [attachment] 附件
  Future<void> addAttachment(String entryId, Attachment attachment) async {
    // 添加附件到数据库
    final attachmentMap = attachment.toJson();
    attachmentMap['entryId'] = entryId;
    await databaseService.addAttachment(attachmentMap);
    // 重新加载条目
    _loadEntries();
  }

  /// 删除附件
  ///
  /// [attachmentId] 附件ID
  Future<void> deleteAttachment(String attachmentId) async {
    // 从数据库删除附件
    await databaseService.deleteAttachment(attachmentId);
    // 重新加载条目
    _loadEntries();
  }

  /// 恢复回收站项目
  ///
  /// [item] 项目
  Future<void> restoreRecycleBinItem(dynamic item) async {
    // 恢复项目
    await databaseService.restoreItem(item as String);
    // 重新加载分组
    await _loadGroups();
    // 生成新的回收站视图键以强制重建
    _recycleBinViewKey = UniqueKey();
    // 通知监听器
    notifyListeners();
  }

  /// 永久删除回收站项目
  ///
  /// [item] 项目
  Future<void> permanentlyDeleteRecycleBinItem(dynamic item) async {
    // 永久删除项目
    await databaseService.permanentlyDeleteItem(item as String);
    // 生成新的回收站视图键以强制重建
    _recycleBinViewKey = UniqueKey();
    // 通知监听器
    notifyListeners();
  }

  /// 设置拖拽目标分组
  ///
  /// [groupId] 分组ID
  void setDragTargetGroup(String? groupId) {
    // 设置拖拽目标分组ID
    _dragTargetGroupId = groupId;
    // 通知监听器
    notifyListeners();
  }

  /// 设置悬停的条目
  ///
  /// [entryId] 条目ID
  void setHoveredEntry(String? entryId) {
    // 设置悬停的条目ID
    _hoveredEntryId = entryId;
    // 通知监听器
    notifyListeners();
  }

  /// 设置选中的条目
  ///
  /// [entry] 选中的条目
  void selectEntry(Entry? entry) {
    _selectedEntry = entry;
    notifyListeners();
  }

  /// 重新排序条目
  ///
  /// [draggedEntry] 被拖拽的条目
  /// [targetEntry] 目标条目
  Future<void> reorderEntry(Entry draggedEntry, Entry targetEntry) async {
    final oldIndex = _entries.indexWhere((e) => e.id == draggedEntry.id);
    final newIndex = _entries.indexWhere((e) => e.id == targetEntry.id);

    if (oldIndex != -1 && newIndex != -1) {
      // 在本地列表中重新排序
      final entry = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, entry);
      notifyListeners(); // 立即更新UI以提供即时反馈

      // 更新数据库中的排序
      final entryIds = _entries.map((e) => e.id).toList();
      try {
        await databaseService.reorderEntries(entryIds);
      } catch (e) {
        // 如果数据库更新失败，恢复UI上的顺序
        final originalOrderEntry = _entries.removeAt(newIndex);
        _entries.insert(oldIndex, originalOrderEntry);
        notifyListeners();
        // 可以选择性地向用户显示错误消息
      }
    }
  }
}
