import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketky/core/services/auth_service.dart'; // 🆕 thêm dòng này
import '../../constants/api_constants.dart';
import '../models/cart_model.dart';

class CartService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// -------------------- LẤY GIỎ HÀNG --------------------
  static Future<Cart?> getCart() async {
    final url = Uri.parse('$baseUrl/cart');
    final token = await AuthService.getToken(); // 🆕 lấy token

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 🆕 thêm token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson({'data': data});
      } else {
        print('❌ Failed to fetch cart: ${response.body}');
        return null;
      }
    } catch (e) {
      print('🔥 Error fetching cart: $e');
      return null;
    }
  }

  /// -------------------- THÊM SẢN PHẨM --------------------
  static Future<bool> addItemToCart({
    required int customerId,
    required int variantId,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/cart');
    final token = await AuthService.getToken(); // 🆕
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
          'Authorization': 'Bearer $token', // 🆕
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Item added to cart successfully");
        return true;
      } else {
        print('❌ Failed to add item to cart: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🔥 Error adding item to cart: $e');
      return false;
    }
  }

  /// -------------------- CẬP NHẬT SỐ LƯỢNG --------------------
  static Future<bool> updateItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/cart/$cartItemId');
    final token = await AuthService.getToken(); // 🆕

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 🆕
        },
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        print("✅ Cart item updated successfully");
        return true;
      } else {
        print("❌ Failed to update item: ${response.body}");
        return false;
      }
    } catch (e) {
      print('🔥 Error updating item quantity: $e');
      return false;
    }
  }

  /// -------------------- XÓA SẢN PHẨM --------------------
  static Future<bool> removeItemFromCart(int cartItemId) async {
    final url = Uri.parse('$baseUrl/cart/$cartItemId');
    final token = await AuthService.getToken(); // 🆕

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // 🆕
        },
      );

      if (response.statusCode == 200) {
        print("🗑️ Item removed from cart successfully");
        return true;
      } else {
        print('❌ Failed to remove item: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🔥 Error removing item: $e');
      return false;
    }
  }

  /// -------------------- XÓA TOÀN BỘ GIỎ HÀNG --------------------
  static Future<bool> clearCart() async {
    final url = Uri.parse('$baseUrl/cart/clear');
    final token = await AuthService.getToken(); // 🆕

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // 🆕
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        print("🧹 Cart cleared successfully");
        return true;
      } else {
        print('❌ Failed to clear cart: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🔥 Error clearing cart: $e');
      return false;
    }
  }
}
