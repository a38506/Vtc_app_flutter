import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';
import '../models/address_model.dart';
import 'package:marketky/core/services/auth_service.dart';

class AddressService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// Lấy danh sách địa chỉ
  static Future<List<Address>> getAddresses() async {
    final url = Uri.parse('$baseUrl/customers/addresses');
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
        final data = jsonDecode(response.body) as List;
        return data.map((e) => Address.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Thêm địa chỉ
  static Future<bool> addAddress(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/customers/addresses');
    final token = await AuthService.getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> addAddressModel(Address address) {
    return addAddress(address.toJson());
  }

  /// Sửa địa chỉ
  static Future<bool> updateAddress(
      int addressId, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/customers/addresses/$addressId');
    final token = await AuthService.getToken();

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Xóa địa chỉ
  static Future<bool> deleteAddress(int addressId) async {
    final url = Uri.parse('$baseUrl/customers/addresses/$addressId');
    final token = await AuthService.getToken();

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  /// Đặt địa chỉ mặc định
  static Future<bool> setDefaultAddress(int addressId) async {
    final url = Uri.parse('$baseUrl/customers/addresses/$addressId');
    final token = await AuthService.getToken();

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'is_default': true}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
