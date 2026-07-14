/// 表示一个分组，用于组织密码条目。
class Group {
  /// 分组的唯一标识符。
  String id;

  /// 分组的名称。
  String name;

  /// 父分组的ID。如果为null，则表示这是一个顶级分组。
  String? parentId;

  /// 是否已删除。
  bool isDeleted;

  /// 删除时间。
  DateTime? deletedAt;

  /// 排序顺序。
  int sortOrder;

  /// 创建一个 [Group] 实例。
  ///
  /// * [id]: 分组的唯一标识符。
  /// * [name]: 分组的名称。
  /// * [parentId]: 父分组的ID，可以为null。
  /// * [isDeleted]: 是否已删除。
  /// * [deletedAt]: 删除时间。
  /// * [sortOrder]: 排序顺序。
  Group({
    required this.id,
    required this.name,
    this.parentId,
    this.isDeleted = false,
    this.deletedAt,
    this.sortOrder = 0,
  });

  /// 从JSON映射创建一个 [Group] 实例。
  ///
  /// 这是用于从数据库或网络响应中反序列化分组数据。
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String? ?? '', // 处理可能的null值
      name: json['name'] as String? ?? '未命名分组', // 处理可能的null值
      parentId: json['parentId'] as String?,
      isDeleted: json['isDeleted'] == 1,
      deletedAt: json['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deletedAt'] as int)
          : null,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// 将 [Group] 实例转换为JSON映射。
  ///
  /// 这是用于将分组数据序列化以存入数据库或通过网络发送。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
      'sortOrder': sortOrder,
    };
  }
}
