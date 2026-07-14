/// 分组非空异常
/// 当尝试删除一个非空分组时抛出此异常
class GroupNotEmptyException implements Exception {
  /// 异常消息
  final String message;
  
  /// 构造函数
  /// [message] 异常消息，默认为'分组非空'
  GroupNotEmptyException([this.message = '分组非空']);
}

/// 分组包含子分组异常
/// 当尝试删除一个包含子分组的分组时抛出此异常
class GroupHasSubgroupsException implements Exception {
  /// 异常消息
  final String message;
  
  /// 构造函数
  /// [message] 异常消息，默认为'分组包含子分组'
  GroupHasSubgroupsException([this.message = '分组包含子分组']);
}

/// 密码无效异常
/// 当输入的密码无效时抛出此异常
class InvalidPasswordException implements Exception {
  /// 异常消息
  final String message;
  
  /// 构造函数
  /// [message] 异常消息，默认为'密码无效'
  InvalidPasswordException([this.message = '密码无效']);
}

/// 解密失败异常
/// 当解密操作失败时抛出此异常
class DecryptionFailedException implements Exception {
  /// 异常消息
  final String message;
  
  /// 构造函数
  /// [message] 异常消息，默认为'解密失败'
  DecryptionFailedException([this.message = '解密失败']);
}