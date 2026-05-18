import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchCacheService {
  static const String _cacheKey = 'recent_searches';

  /// Lấy danh sách tìm kiếm gần đây
  static Future<List<Map<String, String>>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Map<String, String>.from(item)).toList();
  }

  /// Thêm một từ khóa tìm kiếm vào cache (tránh trùng lặp, giới hạn 20 mục)
  static Future<void> addSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();

    searches.removeWhere((item) => item['query'] == query);
    searches.insert(0, {'query': query});
    if (searches.length > 20) {
      searches.removeRange(20, searches.length);
    }

    await prefs.setString(_cacheKey, jsonEncode(searches));
  }

  /// Xóa một mục tìm kiếm cụ thể theo query
  static Future<void> removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();
    searches.removeWhere((item) => item['query'] == query);
    await prefs.setString(_cacheKey, jsonEncode(searches));
  }

  /// Xóa tất cả lịch sử tìm kiếm
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
