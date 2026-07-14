import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:pwbox/core/utils/lru_cache.dart';

/// 提供获取网站图标的服务。
class FaviconService {
  /// 用于缓存网站图标的LRU缓存。
  static final LruCache<String, Uint8List?> _cache = LruCache(100);

  /// 缓存目录的名称。
  static const String _cacheDirName = 'favicons';

  /// 获取指定URL的网站图标。
  ///
  /// * [url]: 要获取网站图标的URL。
  ///
  /// 返回网站图标的字节数据，如果无法获取则返回null。
  Future<Uint8List?> getFavicon(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    final String host = uri.host;

    if (_cache.containsKey(host)) {
      return _cache.get(host);
    }

    final cacheFile = await _getCacheFile(host);
    if (await cacheFile.exists()) {
      final data = await cacheFile.readAsBytes();
      _cache.put(host, data);
      return data;
    }

    try {
      final faviconUrl = _buildFaviconUrl(uri);
      final response = await http.get(Uri.parse(faviconUrl));

      if (response.statusCode == 200) {
        final data = response.bodyBytes;
        _cache.put(host, data);
        await cacheFile.writeAsBytes(data);
        return data;
      }
    } catch (e) {
      debugPrint('获取 $host 的网站图标时出错：$e');
    }
    return null;
  }

  /// 构建网站图标的URL。
  String _buildFaviconUrl(Uri uri) {
    // 尝试常见的网站图标路径
    return '${uri.scheme}://${uri.host}/favicon.ico';
  }

  /// 获取缓存文件。
  Future<File> _getCacheFile(String host) async {
    final directory = await getApplicationSupportDirectory();
    final cacheDir = Directory('${directory.path}/$_cacheDirName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return File('${cacheDir.path}/$host.ico');
  }

  /// 清除网站图标缓存（在开发或缓存损坏时很有用）。
  static Future<void> clearCache() async {
    final directory = await getApplicationSupportDirectory();
    final cacheDir = Directory('${directory.path}/$_cacheDirName');
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
    _cache.clear();
  }
}