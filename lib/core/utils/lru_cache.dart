import 'dart:collection';

/// 一个最近最少使用（LRU）缓存的实现。
/// 
/// LRU缓存是一种缓存淘汰策略，当缓存满时，会优先淘汰最近最少使用的条目。
/// 这种策略可以有效提高缓存命中率，适用于许多场景。
class LruCache<K, V> {
  /// 缓存的最大大小。
  final int _maxSize;

  /// 缓存本身，使用Map存储键值对以实现O(1)的查找时间复杂度。
  final _cache = <K, V>{};

  /// 用于跟踪键的使用顺序的双向链表。
  /// 链表头部表示最近使用的键，尾部表示最近最少使用的键。
  final _keys = DoubleLinkedQueue<K>();

  /// 创建一个 [LruCache] 实例。
  ///
  /// * [_maxSize]: 缓存的最大大小。当缓存条目数量超过此值时，将淘汰最近最少使用的条目。
  LruCache(this._maxSize) : assert(_maxSize > 0, '缓存大小必须大于0');

  /// 获取与指定键关联的值。
  ///
  /// * [key]: 要获取其值的键。
  ///
  /// 如果键存在，则返回关联的值，并将该键标记为最近使用；
  /// 否则返回null。
  V? get(K key) {
    if (_cache.containsKey(key)) {
      // 将访问的键移动到链表头部（标记为最近使用）
      _keys.remove(key);
      _keys.addFirst(key);
      return _cache[key];
    }
    return null;
  }

  /// 将键值对放入缓存中。
  ///
  /// * [key]: 要放入缓存的键。
  /// * [value]: 要放入缓存的值。
  ///
  /// 如果键已存在，则更新其值并将其标记为最近使用；
  /// 如果缓存已满，则淘汰最近最少使用的条目，然后添加新条目。
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // 如果键已存在，先将其从链表中移除
      _keys.remove(key);
    } else if (_cache.length >= _maxSize) {
      // 如果缓存已满，淘汰最近最少使用的条目（链表尾部）
      final lastKey = _keys.removeLast();
      _cache.remove(lastKey);
    }
    
    // 将键添加到链表头部（标记为最近使用）
    _keys.addFirst(key);
    // 在缓存中存储键值对
    _cache[key] = value;
  }

  /// 清除缓存中的所有条目。
  void clear() {
    _cache.clear();
    _keys.clear();
  }

  /// 检查缓存是否包含指定的键。
  ///
  /// * [key]: 要检查的键。
  ///
  /// 如果缓存包含该键，则返回true；否则返回false。
  bool containsKey(K key) {
    return _cache.containsKey(key);
  }
  
  /// 获取缓存中当前条目的数量。
  int get length => _cache.length;
  
  /// 检查缓存是否为空。
  bool get isEmpty => _cache.isEmpty;
  
  /// 检查缓存是否已满。
  bool get isFull => _cache.length >= _maxSize;
}