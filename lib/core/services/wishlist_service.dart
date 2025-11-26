import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// Lấy danh sách wishlist (có thông tin sản phẩm)
  static Future<List<WishlistItem>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse('$baseUrl/wishlist');

    try {
      final response =
          await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data as List<dynamic>;
        return list
            .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Failed to load wishlist");
      }
    } catch (e) {
      return [];
    }
  }

  /// Lấy danh sách productId trong wishlist
  static Future<List<int>> getWishlistProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse('$baseUrl/wishlist');

    try {
      final response =
          await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data as List<dynamic>;
        return list.map<int>((item) {
          final product = item["product"];
          final idStr = product["id"].toString();
          return int.tryParse(idStr) ?? 0;
        }).toList();
      } else {
        throw Exception("Failed to load wishlist IDs");
      }
    } catch (e) {
      return [];
    }
  }

  /// Thêm vào wishlist
  static Future<bool> addToWishlist(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse('$baseUrl/wishlist');

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"productId": productId}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Xoá sản phẩm khỏi wishlist
  static Future<bool> removeFromWishlist(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse('$baseUrl/wishlist/$productId');

    try {
      final response =
          await http.delete(url, headers: {"Authorization": "Bearer $token"});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
