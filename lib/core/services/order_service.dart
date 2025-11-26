import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../../constants/api_constants.dart';
import 'package:marketky/core/services/auth_service.dart';

class OrderService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// Tạo đơn hàng mới
  static Future<Order> createOrder(Map<String, dynamic> body) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to create order: ${response.statusCode} ${response.body}');
    }
  }

  /// Mua ngay
  static Future<Order> createOrderBuyNow(Map<String, dynamic> body) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to create BuyNow order: ${response.statusCode} ${response.body}');
    }
  }

  /// Lấy chi tiết đơn hàng theo ID
  static Future<Order> getOrderById(int orderId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch order details: ${response.statusCode}');
    }
  }

  /// Lấy danh sách đơn hàng của khách
  static Future<List<dynamic>> getMyOrders() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  /// Lấy chi tiết đơn hàng của khách (My Orders)
  static Future<Order> getOrderDetail(int orderId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch order detail: ${response.statusCode}');
    }
  }

  /// Tính phí vận chuyển
  static Future<double> calculateShippingFee({
    required String carrierCode,
    required int toDistrictId,
    required String toWardCode,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await AuthService.getToken();
    final body = {
      "carrierCode": carrierCode,
      "to_district_id": toDistrictId,
      "to_ward_code": toWardCode,
      "items": items,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/shipping/options'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        final cheapest = data.reduce((a, b) {
          final feeA = a['fee'] ?? 0;
          final feeB = b['fee'] ?? 0;
          return feeA < feeB ? a : b;
        });
        return (cheapest['fee'] as num).toDouble();
      }
      throw Exception('No shipping fee found in response.');
    } else {
      throw Exception('Failed to calculate shipping fee');
    }
  }

  /// Áp dụng voucher
  static Future<double> applyVoucher(String voucherCode) async {
    if (voucherCode.isNotEmpty) {
      return 10.0; // Giảm giá cố định
    }
    throw Exception('Invalid voucher code');
  }
}
