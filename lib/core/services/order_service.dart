import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../../constants/api_constants.dart';
import 'package:marketky/core/services/auth_service.dart';

class OrderService {
  static const String baseUrl = ApiConstants.API_BASE;

  // Tạo đơn hàng mới
  static Future<Order> createOrder(Order order) async {
  final token = await AuthService.getToken();
  final response = await http.post(
    Uri.parse('$baseUrl/orders'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(order.toJson()),
  );

  if (response.statusCode == 201) {
    return Order.fromJson(jsonDecode(response.body));
  } else {
    // In ra thông tin lỗi chi tiết
    print('❌ Failed to create order:');
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    // Ném Exception kèm thông tin server trả về
    throw Exception(
      'Failed to create order: ${response.statusCode} ${response.body}',
    );
  }
}


  // // Lấy danh sách đơn hàng của khách hàng
  // static Future<List<Order>> getOrdersByCustomer(String customerId) async {
  //   final response = await http.get(Uri.parse('$baseUrl/customer/$customerId'));

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     return data.map((json) => Order.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to fetch orders');
  //   }
  // }

  // Lấy chi tiết đơn hàng
  static Future<Order> getOrderById(String orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/$orderId'));

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch order details');
    }
  }

// Trong order_service.dart
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

  print('📦 Request body: ${jsonEncode(body)}');

  final response = await http.post(
    Uri.parse('$baseUrl/shipping/options'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(body),
  );

  print('📬 Response (${response.statusCode}): ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is List && data.isNotEmpty) {
      // Lấy phương án rẻ nhất
      final cheapest = data.reduce((a, b) => a['fee'] < b['fee'] ? a : b);
      print('✅ Shipping fee from API: ${cheapest['fee']}');
      return (cheapest['fee'] as num).toDouble();
    }

    throw Exception('Không tìm thấy phí vận chuyển trong phản hồi.');
  } else {
    print('❌ Failed to get shipping options: ${response.body}');
    throw Exception('Failed to calculate shipping fee');
  }
}



  // Áp dụng voucher
  static Future<double> applyVoucher(String voucherCode) async {
    // TODO: Implement voucher validation and calculation
    // This is a placeholder implementation
    if (voucherCode.isNotEmpty) {
      return 10.0; // Return a fixed discount amount
    }
    throw Exception('Invalid voucher code');
  }


  static Future<List<dynamic>> getMyOrders(String token) async {
    
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch orders');
    }
  }


  static Future<Map<String, dynamic>> getOrderDetail(String orderId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my-orders/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch order detail');
    }
  }
}


