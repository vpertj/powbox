import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:pwbox/core/services/crypto_service.dart';
import 'package:pwbox/core/models/exceptions.dart' as exceptions;

/// 数据库服务
/// 处理数据库的创建、打开、加密和数据操作
class DatabaseService {
  /// Argon2盐值
  static const String _argon2SaltKey = 'argon2_salt';
  static const String _argon2IterationsKey = 'argon2_iterations';
  static const String _argon2MemoryKey = 'argon2_memory';
  static const String _argon2ParallelismKey = 'argon2_parallelism';
  static const String _argon2TypeKey = 'argon2_type';
  static const String _passwordChallengeKey = 'password_challenge';
  static const String _cipherKey = 'cipher'; // 新增：用于存储加密算法

  static const String _dbFileName = 'database.pdbw';
  static const String _attachmentsDirName = '.attachments';
  static const String _passwordChallengeValue = 'pwbox_verification_challenge';

  late CryptoService _cryptoService;
  late Database _db;
  late final String _dbContainerPath;
  bool _is2faEnabled = false;
  late final String _dbPath;
  late final String _attachmentsPath;

  DatabaseService._(this._cryptoService, this._db, this._dbContainerPath) {
    _dbPath = p.join(_dbContainerPath, _dbFileName);
    _attachmentsPath = p.join(_dbContainerPath, _attachmentsDirName);
    getConfig('2fa_secret').then((secret) {
      _is2faEnabled = secret != null;
    });
  }

  String get dbContainerPath => _dbContainerPath;
  String get attachmentsPath => _attachmentsPath;
  bool get is2faEnabled => _is2faEnabled;
  String get dbPath => _dbPath;

  void clearSensitiveData() {
    _cryptoService.clearKey();
  }

  static Future<DatabaseService> open(
    String dbContainerPath,
    String password,
  ) async {
    final dbPath = p.join(dbContainerPath, _dbFileName);
    if (!File(dbPath).existsSync()) {
      throw Exception('Database file does not exist: $dbPath');
    }

    final db = await openDatabase(dbPath);

    try {
      final configMap = <String, dynamic>{};
      final List<Map<String, Object?>> configRows = await db.query('config');
      for (final row in configRows) {
        configMap[row['key'] as String] = row['value'];
      }

      final salt = base64.decode(configMap[_argon2SaltKey] as String);

      final cryptoService = await CryptoService.create(
        password,
        salt,
      );

      final encryptedChallenge = configMap[_passwordChallengeKey] as String;
      try {
        await cryptoService.decryptString(encryptedChallenge);
      } catch (e) {
        throw exceptions.InvalidPasswordException();
      }

      final dbService = DatabaseService._(cryptoService, db, dbContainerPath);
      return dbService;
    } catch (e) {
      await db.close();
      rethrow;
    }
  }

  static Future<void> createNewDatabase(
    String dbContainerPath,
    String password,
    int iterations, {
    int memory = 16384,
    int parallelism = 3,
  }) async {
    final containerDir = Directory(dbContainerPath);
    if (!await containerDir.exists()) {
      await containerDir.create(recursive: true);
    }

    final attachmentsDir = Directory(p.join(dbContainerPath, _attachmentsDirName));
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final dbPath = p.join(dbContainerPath, _dbFileName);
    final db = await openDatabase(dbPath);

    await _createTables(db);

    final salt = await CryptoService.generateSalt();

    final cryptoService = await CryptoService.create(
      password,
      salt,
    );

    final encryptedChallenge = await cryptoService.encryptString(_passwordChallengeValue);

    await db.insert('config', {'key': _argon2SaltKey, 'value': base64.encode(salt)});
    await db.insert('config', {'key': _argon2IterationsKey, 'value': iterations.toString()});
    await db.insert('config', {'key': _argon2MemoryKey, 'value': memory.toString()});
    await db.insert('config', {'key': _argon2ParallelismKey, 'value': parallelism.toString()});
    await db.insert('config', {'key': _argon2TypeKey, 'value': '1'}); // Argon2id
    await db.insert('config', {'key': _passwordChallengeKey, 'value': encryptedChallenge});
    await db.insert('config', {'key': _cipherKey, 'value': 'aes-256-gcm'}); // 标记为 aes-256-gcm
    await db.insert('config', {'key': 'version', 'value': '2'});

    await db.close();
  }

  Future<void> lock() async {
    clearSensitiveData();
    await _db.close();
  }

  bool get isOpen => _db.isOpen;

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parentId TEXT,
        isDeleted INTEGER DEFAULT 0,
        deletedAt INTEGER,
        sortOrder INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE entries (
        id TEXT PRIMARY KEY,
        title TEXT,
        username TEXT,
        password TEXT,
        url TEXT,
        notes TEXT,
        groupId TEXT,
        isDeleted INTEGER DEFAULT 0,
        deletedAt INTEGER,
        sortOrder INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE attachments (
        id TEXT PRIMARY KEY,
        entryId TEXT,
        fileName TEXT,
        mimeType TEXT,
        data BLOB
      )
    ''');
    await db.execute('''
      CREATE TABLE config (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE VIRTUAL TABLE entry_search USING fts5(
        entryId,
        content,
        tokenize = 'unicode61 remove_diacritics 2'
      )
    ''');
  }

  Future<List<Map<String, Object?>>> getAllGroups() async {
    return await _db.query('groups', where: 'isDeleted = 0', orderBy: 'sortOrder ASC');
  }

  Future<void> updateGroup(String id, Map<String, Object?> values) async {
    await _db.update('groups', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addGroup(Map<String, Object?> group) async {
    await _db.insert('groups', group);
  }

  Future<void> deleteGroup(String id) async {
    await _db.update('groups', {'isDeleted': 1, 'deletedAt': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> hasSubgroups(String parentId) async {
    final count = await _db.rawQuery('SELECT COUNT(*) as count FROM groups WHERE parentId = ? AND isDeleted = 0', [parentId]);
    return (count.first['count'] as int) > 0;
  }

  Future<int> getEntryCount(String groupId) async {
    final count = await _db.rawQuery('SELECT COUNT(*) as count FROM entries WHERE groupId = ? AND isDeleted = 0', [groupId]);
    return count.first['count'] as int;
  }

  Future<List<Map<String, Object?>>> getEntries(String groupId) async {
    final encryptedEntries = await _db.query('entries', where: 'groupId = ? AND isDeleted = 0', whereArgs: [groupId], orderBy: 'sortOrder ASC');
    final entries = <Map<String, Object?>>[];
    for (final entryMap in encryptedEntries) {
      final mutableEntryMap = Map<String, Object?>.from(entryMap);
      final attachmentsData = await _db.query('attachments', where: 'entryId = ?', whereArgs: [mutableEntryMap['id']]);
      mutableEntryMap['attachments'] = attachmentsData;
      entries.add(await _decryptEntry(mutableEntryMap));
    }
    return entries;
  }

  Future<List<Map<String, Object?>>> searchEntries(String query) async {
    print("Searching for: $query");
    final searchResults = await _db.query('entry_search', columns: ['entryId'], where: 'content MATCH ?', whereArgs: [query]);
    print("Found ${searchResults.length} results.");
    if (searchResults.isEmpty) return [];
    final entryIds = searchResults.map((row) => row['entryId'] as String).toList();
    final placeholders = List.generate(entryIds.length, (_) => '?').join(',');
    final encryptedEntries = await _db.query('entries', where: 'id IN ($placeholders) AND isDeleted = 0', whereArgs: entryIds);
    final entries = <Map<String, Object?>>[];
    for (final entryMap in encryptedEntries) {
      final mutableEntryMap = Map<String, Object?>.from(entryMap);
      final attachmentsData = await _db.query('attachments', where: 'entryId = ?', whereArgs: [mutableEntryMap['id']]);
      mutableEntryMap['attachments'] = attachmentsData;
      entries.add(await _decryptEntry(mutableEntryMap));
    }
    return entries;
  }

  Future<Map<String, dynamic>> _decryptEntry(Map<String, Object?> encryptedEntry) async {
    final decryptedEntry = <String, dynamic>{};
    const fieldsToEncrypt = {'title', 'username', 'password', 'url', 'notes'};
    for (final entry in encryptedEntry.entries) {
      if (fieldsToEncrypt.contains(entry.key) && entry.value is String) {
        try {
          decryptedEntry[entry.key] = await _cryptoService.decryptString(entry.value as String);
        } catch (e) {
          decryptedEntry[entry.key] = entry.value;
          print('解密字段 ${entry.key} 失败: $e');
        }
      } else {
        decryptedEntry[entry.key] = entry.value;
      }
    }
    return decryptedEntry;
  }

  Future<void> addEntry(Map<String, Object?> entry) async {
    final encryptedEntry = <String, Object?>{};
    const fieldsToEncrypt = {'title', 'username', 'password', 'url', 'notes'};
    final attachments = entry['attachments'] as List? ?? [];

    for (final e in entry.entries) {
      if (fieldsToEncrypt.contains(e.key) && e.value is String) {
        encryptedEntry[e.key] = await _cryptoService.encryptString(e.value as String);
      } else if (e.key != 'attachments') { // Don't copy attachments to the entry table
        encryptedEntry[e.key] = e.value;
      }
    }

    await _db.transaction((txn) async {
      // Insert the main entry
      await txn.insert('entries', encryptedEntry);

      // Insert attachments
      for (final attachment in attachments) {
        final attachmentMap = attachment as Map<String, Object?>;
        attachmentMap['entryId'] = entry['id'];
        await txn.insert('attachments', attachmentMap);
      }

      // Update search index
      final content = (entry['title'] as String? ?? '') +
          ' ' +
          (entry['username'] as String? ?? '') +
          ' ' +
          (entry['url'] as String? ?? '') +
          ' ' +
          (entry['notes'] as String? ?? '');
      await txn.insert('entry_search', {'entryId': entry['id'], 'content': content});
    });
  }

  Future<void> updateEntry(String id, Map<String, Object?> entry) async {
    final encryptedEntry = <String, Object?>{};
    const fieldsToEncrypt = {'title', 'username', 'password', 'url', 'notes'};
    final attachments = entry['attachments'] as List? ?? [];

    for (final e in entry.entries) {
      if (fieldsToEncrypt.contains(e.key) && e.value is String) {
        encryptedEntry[e.key] = await _cryptoService.encryptString(e.value as String);
      } else if (e.key != 'attachments') { // Don't copy attachments to the entry table
        encryptedEntry[e.key] = e.value;
      }
    }

    await _db.transaction((txn) async {
      // Update the main entry
      await txn.update('entries', encryptedEntry, where: 'id = ?', whereArgs: [id]);

      // Delete old attachments
      await txn.delete('attachments', where: 'entryId = ?', whereArgs: [id]);

      // Insert new attachments
      for (final attachment in attachments) {
        final attachmentMap = attachment as Map<String, Object?>;
        attachmentMap['entryId'] = id;
        await txn.insert('attachments', attachmentMap);
      }

      // Update search index
      final content = (entry['title'] as String? ?? '') +
          ' ' +
          (entry['username'] as String? ?? '') +
          ' ' +
          (entry['url'] as String? ?? '') +
          ' ' +
          (entry['notes'] as String? ?? '');
      await txn.delete('entry_search', where: 'entryId = ?', whereArgs: [id]);
      await txn.insert('entry_search', {'entryId': id, 'content': content});
    });
  }

  Future<void> deleteEntry(String id) async {
    await _db.transaction((txn) async {
      await txn.update('entries', {'isDeleted': 1, 'deletedAt': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);
      await txn.delete('entry_search', where: 'entryId = ?', whereArgs: [id]);
    });
  }

  Future<void> moveEntry(String entryId, String newGroupId) async {
    await _db.update('entries', {'groupId': newGroupId}, where: 'id = ?', whereArgs: [entryId]);
  }

  Future<void> reorderEntries(List<String> entryIds) async {
    final batch = _db.batch();
    for (int i = 0; i < entryIds.length; i++) {
      batch.update('entries', {'sortOrder': i}, where: 'id = ?', whereArgs: [entryIds[i]]);
    }
    await batch.commit(noResult: true, continueOnError: false, exclusive: true);
  }

  Future<List<Map<String, Object?>>> getAttachmentsInfoForEntry(String entryId) async {
    return await _db.query('attachments', columns: ['id', 'fileName', 'mimeType'], where: 'entryId = ?', whereArgs: [entryId]);
  }

  Future<void> addAttachment(Map<String, Object?> attachment) async {
    await _db.insert('attachments', attachment);
  }

  Future<Uint8List?> getAttachmentData(String attachmentId) async {
    final rows = await _db.query('attachments', columns: ['data'], where: 'id = ?', whereArgs: [attachmentId]);
    if (rows.isNotEmpty) return rows.first['data'] as Uint8List?;
    return null;
  }

  Future<void> deleteAttachment(String attachmentId) async {
    await _db.delete('attachments', where: 'id = ?', whereArgs: [attachmentId]);
  }

  Future<void> setConfig(String key, String value) async {
    await _db.insert('config', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getConfig(String key) async {
    final rows = await _db.query('config', where: 'key = ?', whereArgs: [key]);
    if (rows.isNotEmpty) return rows.first['value'] as String?;
    return null;
  }

  Future<void> deleteConfig(String key) async {
    await _db.delete('config', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final bool isOldPasswordValid = await verifyPassword(oldPassword);
    if (!isOldPasswordValid) {
      throw exceptions.InvalidPasswordException();
    }

    final salt = await CryptoService.generateSalt();

    final newCryptoService = await CryptoService.create(
      newPassword,
      salt,
    );

    // 重新加密所有条目
    final entries = await _db.query('entries');
    final batch = _db.batch();
    for (final entry in entries) {
      final decryptedEntry = await _decryptEntry(entry);
      final reEncryptedEntry = <String, Object?>{};
      const fieldsToEncrypt = {'title', 'username', 'password', 'url', 'notes'};

      for (final e in decryptedEntry.entries) {
        if (fieldsToEncrypt.contains(e.key) && e.value is String) {
          reEncryptedEntry[e.key] = await newCryptoService.encryptString(e.value as String);
        } else {
          reEncryptedEntry[e.key] = e.value;
        }
      }
      batch.update('entries', reEncryptedEntry, where: 'id = ?', whereArgs: [entry['id']]);
    }
    await batch.commit(noResult: true);

    // 附件数据目前不重新加密，因为它们是BLOB，且此流程会非常耗时
    // 这是一个可以未来优化的点

    // 更新挑战值和配置
    final encryptedChallenge = await newCryptoService.encryptString(_passwordChallengeValue);
    await setConfig(_passwordChallengeKey, encryptedChallenge);
    await setConfig(_argon2SaltKey, base64.encode(salt));
    await setConfig(_cipherKey, 'aes-256-gcm'); // 确保算法已更新为 aes-256-gcm

    _cryptoService = newCryptoService;
  }

  Future<bool> verifyPassword(String password) async {
    try {
      final configMap = <String, dynamic>{};
      final List<Map<String, Object?>> configRows = await _db.query('config');
      for (final row in configRows) {
        configMap[row['key'] as String] = row['value'];
      }

      final salt = base64.decode(configMap[_argon2SaltKey] as String);

      final tempCryptoService = await CryptoService.create(
        password,
        salt,
      );

      final encryptedChallenge = configMap[_passwordChallengeKey] as String;
      await tempCryptoService.decryptString(encryptedChallenge);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, Object?>>> getDeletedItems() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    return await _db.query('entries', where: 'isDeleted = 1 AND deletedAt < ?', whereArgs: [cutoff]);
  }

  Future<List<Map<String, Object?>>> getAllDeletedItems() async {
    return await _db.query('entries', where: 'isDeleted = 1');
  }

  Future<void> restoreItem(String itemId) async {
    await _db.update('entries', {'isDeleted': 0, 'deletedAt': null}, where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> permanentlyDeleteItem(String itemId) async {
    await _db.delete('entries', where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> emptyRecycleBin() async {
    await _db.delete('entries', where: 'isDeleted = 1');
  }

  Future<void> purgeOldItems(int retentionDays) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays)).millisecondsSinceEpoch;
    await _db.delete('entries', where: 'isDeleted = 1 AND deletedAt < ?', whereArgs: [cutoff]);
  }

  static Future<String> getDbFileHash(String dbContainerPath) async {
    final dbFile = File(p.join(dbContainerPath, _dbFileName));
    if (await dbFile.exists()) {
      final fileBytes = await dbFile.readAsBytes();
      return sha256.convert(fileBytes).toString();
    }
    return '';
  }

  Future<String> performBackup() async {
    try {
      final dbContainerPath = p.dirname(_dbPath);
      final backupsDir = Directory(p.join(dbContainerPath, 'backups'));
      if (!await backupsDir.exists()) await backupsDir.create(recursive: true);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupDbFile = File(p.join(backupsDir.path, 'database.$timestamp.v2.sqlite.bak'));
      final backupAttachmentsDir = Directory(p.join(backupsDir.path, '.attachments.$timestamp.bak'));
      final dbFile = File(_dbPath);
      String dbHash = '';
      if (await dbFile.exists()) {
        final fileBytes = await dbFile.readAsBytes();
        dbHash = sha256.convert(fileBytes).toString();
        await dbFile.copy(backupDbFile.path);
      }
      final attachmentsDir = Directory(_attachmentsPath);
      if (await attachmentsDir.exists()) {
        if (!await backupAttachmentsDir.exists()) await backupAttachmentsDir.create(recursive: true);
        await for (final entity in attachmentsDir.list()) {
          if (entity is File) {
            final newPath = p.join(backupAttachmentsDir.path, p.basename(entity.path));
            await entity.copy(newPath);
          }
        }
      }
      return dbHash;
    } catch (e) {
      print('Error during backup: $e');
      rethrow;
    }
  }
}

// 扩展：用于处理数据库升级
extension DatabaseUpgrade on DatabaseService {
  static Future<void> checkAndUpgradeDatabase(Database db) async {
    int currentVersion = 1;
    try {
      final versionResult = await db.query('config', where: 'key = ?', whereArgs: ['version']);
      if (versionResult.isNotEmpty) {
        currentVersion = int.parse(versionResult.first['value'] as String);
      }
    } catch (e) {
      // 'config' table or 'version' key might not exist in very old versions
    }

    if (currentVersion < 2) {
      await _upgradeToV2(db);
    }
  }

  static Future<void> _upgradeToV2(Database db) async {
    // V2 adds a 'sortOrder' column to 'groups' and 'entries'
    await db.execute('ALTER TABLE groups ADD COLUMN sortOrder INTEGER');
    await db.execute('ALTER TABLE entries ADD COLUMN sortOrder INTEGER');
    await db.insert('config', {'key': 'version', 'value': '2'}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
