import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';

class ProductService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// Lấy danh sách sản phẩm
  static Future<List<Product>> getAllProducts() async {
    final url = Uri.parse('$baseUrl/products');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      return [];
    }
  }

  /// Lấy sản phẩm theo ID
  static Future<Product?> getProductById(int productId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Product.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
