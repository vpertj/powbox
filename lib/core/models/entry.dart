import 'package:pwbox/core/models/attachment.dart';
import 'package:uuid/uuid.dart';

/// 表示一个密码条目，包含登录凭据和其他相关信息。
class Entry {
  /// 条目的唯一标识符。
  String id;

  /// 条目的标题。
  String title;

  /// 用户名。
  String username;

  /// 密码。
  String password;

  /// 相关的网址。
  String url;

  /// 备注信息。
  String? notes;

  /// 所属分组的ID。
  String groupId;

  /// 附件列表。
  List<Attachment> attachments;

  /// 是否已删除。
  bool isDeleted;

  /// 删除时间。
  DateTime? deletedAt;

  /// 排序顺序。
  int sortOrder;

  /// 获取分组ID的字符串形式
  String get groupIdString => groupId.toString();

  /// 创建一个 [Entry] 实例。
  Entry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    this.notes,
    required this.groupId,
    required this.attachments,
    this.isDeleted = false,
    this.deletedAt,
    this.sortOrder = 0,
  });

  /// 从JSON映射创建一个 [Entry] 实例。
  factory Entry.fromJson(Map<String, dynamic> json) {
    var attachmentsList = <Attachment>[];
    if (json['attachments'] != null) {
      attachmentsList = (json['attachments'] as List)
          .map((i) => Attachment.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return Entry(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      url: json['url'] as String? ?? '',
      notes: json['notes'] as String?,
      groupId: json['groupId'] as String? ?? '',
      attachments: attachmentsList, // 使用正确解析的附件列表
      isDeleted: json['isDeleted'] == 1,
      deletedAt: json['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deletedAt'] as int)
          : null,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// 将 [Entry] 实例转换为JSON映射。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'groupId': groupId,
      // 正确地序列化附件列表
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
      'sortOrder': sortOrder,
    };
  }
}