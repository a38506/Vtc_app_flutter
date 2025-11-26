import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketky/core/services/auth_service.dart';
import '../../constants/api_constants.dart';
import '../models/cart_model.dart';

class CartService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// Lấy giỏ hàng của người dùng
  static Future<Cart?> getCart() async {
    final url = Uri.parse('$baseUrl/cart');
    final token = await AuthService.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson({'data': data});
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  static Future<bool> addItemToCart({
    required int customerId,
    required int variantId,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/cart');
    final token = await AuthService.getToken();
    final body = {
      'customerId': customerId,
      'variantId': variantId,
      'quantity': quantity,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Cập nhật số lượng sản phẩm trong giỏ
  static Future<bool> updateItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/cart/$cartItemId');
    final token = await AuthService.getToken();

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Xóa một sản phẩm khỏi giỏ hàng
  static Future<bool> removeItemFromCart(int cartItemId) async {
    final url = Uri.parse('$baseUrl/cart/$cartItemId');
    final token = await AuthService.getToken();

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Xóa toàn bộ giỏ hàng
  static Future<bool> clearCart() async {
    final url = Uri.parse('$baseUrl/cart/clear');
    final token = await AuthService.getToken();

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
