import 'dart:collection';

/// LRU-based message deduplication cache.
///
/// Uses a [LinkedHashSet] for O(1) lookup and insertion-order eviction.
/// Default capacity is 1000 message IDs.
class MessageCache {
  final int maxSize;
  final LinkedHashSet<String> _cache = LinkedHashSet<String>();

  MessageCache({this.maxSize = 1000});

  /// Returns `true` if [msgId] was already seen (duplicate).
  /// If not seen, adds it to the cache and evicts the oldest entry if full.
  bool isDuplicate(String msgId) {
    if (_cache.contains(msgId)) {
      return true;
    }

    _cache.add(msgId);

    // Evict oldest if over capacity
    while (_cache.length > maxSize) {
      _cache.remove(_cache.first);
    }

    return false;
  }

  /// Number of message IDs currently cached.
  int get length => _cache.length;

  /// Clears all cached message IDs.
  void clear() => _cache.clear();
}
