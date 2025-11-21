import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../models/search_model.dart';
import '../models/product_model.dart';

class SearchService {
  static const String baseUrl = ApiConstants.API_BASE;
  static const String _historyKey = 'search_history';

  /// -------------------- Lịch sử tìm kiếm --------------------
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    return history.reversed.toList(); // mới nhất lên đầu
  }

  static Future<void> addSearchHistory(String keyword) async {
    if (keyword.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    if (history.contains(keyword)) history.remove(keyword); // tránh trùng
    history.add(keyword);
    await prefs.setStringList(_historyKey, history);
  }

  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// -------------------- Tìm kiếm sản phẩm theo API --------------------
  static Future<List<Product>> searchProducts({
    String? search,
    int? categoryId,
    int? page = 1,
    int? limit = 20,
    String? sortBy,
    String? sortOrder,
    bool? isFeatured,
    double? priceMin,  
    double? priceMax,
  }) async {
    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (isFeatured != null) 'is_featured': isFeatured.toString(),
      if (priceMin != null) 'price_min' : priceMin.toString(),
      if (priceMax != null) 'price_max' : priceMax.toString(),
    });

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      final List data = jsonData['data'] ?? [];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Search failed: ${res.statusCode}');
    }
  }
}
