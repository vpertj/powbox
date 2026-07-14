import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  final SecretKey _secretKey;
  final Cipher _algorithm;

  CryptoService._(this._secretKey, this._algorithm);

  static Future<CryptoService> create(String password, Uint8List salt) async {
    final algorithm = AesGcm.with256bits();

    // 使用 PBKDF2-HMAC-SHA256 进行密钥派生
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000, // 迭代次数可以根据安全需求调整
      bits: 256,
    );

    final secretKey = SecretKey(utf8.encode(password));
    final derivedKey = await pbkdf2.deriveKey(
      secretKey: secretKey,
      nonce: salt,
    );

    return CryptoService._(derivedKey, algorithm);
  }

  /// 生成一个随机的、密码学安全的盐值
  static Future<Uint8List> generateSalt() async {
    final secretKeyData = SecretKeyData.random(length: 16);
    final bytes = await secretKeyData.extractBytes();
    return Uint8List.fromList(bytes);
  }

  Future<Uint8List> encrypt(Uint8List data) async {
    final secretBox = await _algorithm.encrypt(
      data,
      secretKey: _secretKey,
    );
    // 密文、nonce和MAC组合在一起返回
    return secretBox.concatenation();
  }

  Future<String> encryptString(String data) async {
    final encryptedBytes = await encrypt(utf8.encode(data));
    return base64.encode(encryptedBytes);
  }

  Future<Uint8List> decrypt(Uint8List encryptedData) async {
    final secretBox = SecretBox.fromConcatenation(
      encryptedData,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );

    final decryptedData = await _algorithm.decrypt(
      secretBox,
      secretKey: _secretKey,
    );
    return Uint8List.fromList(decryptedData);
  }

  Future<String> decryptString(String encryptedString) async {
    final decryptedBytes = await decrypt(base64.decode(encryptedString));
    return utf8.decode(decryptedBytes);
  }

  void clearKey() {
    // _secretKey.destroy(); // .destroy() is not available on SecretKey
  }
}

// Define CipherAlgorithm enum if it's used elsewhere, otherwise remove
// For now, we assume it's not needed as we hardcode AesGcm