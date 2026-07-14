import 'dart:typed_data';

/// 表示一个附件，可以附加到密码条目上。
class Attachment {
  /// 附件的唯一标识符。
  String id;

  /// 附件的文件名。
  String fileName;

  /// 附件的MIME类型，例如 'image/png' 或 'application/pdf'。
  String mimeType;

  /// 附件的二进制数据。
  Uint8List data;

  /// 创建一个 [Attachment] 实例。
  ///
  /// * [id]: 附件的唯一标识符。
  /// * [fileName]: 附件的文件名。
  /// * [mimeType]: 附件的MIME类型。
  /// * [data]: 附件的二进制数据。
  Attachment({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.data,
  });

  /// 从JSON映射创建一个 [Attachment] 实例。
  ///
  /// 这是用于从数据库或网络响应中反序列化附件数据。
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String? ?? '',
      data: json['data'] == null
          ? Uint8List(0)
          : Uint8List.fromList((json['data'] as List<dynamic>).cast<int>()),
    );
  }

  /// 将 [Attachment] 实例转换为JSON映射。
  /// 
  /// 这是用于将附件数据序列化以存入数据库或通过网络发送。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'mimeType': mimeType,
      // 将字节数据转换为整数列表以便存入数据库
      'data': data,
    };
  }
}