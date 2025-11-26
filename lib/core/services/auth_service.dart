import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../models/auth_response.dart';

class AuthService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// -------------------- ĐĂNG NHẬP --------------------
  static Future<AuthResponse?> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final auth = AuthResponse.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', auth.token);

        if (data['user'] != null) {
          final user = data['user'];
          await prefs.setString('user', jsonEncode(user));

          final customerId = int.tryParse(user['customer_id'].toString());
          if (customerId != null) await prefs.setInt('customerId', customerId);
        }

        return auth;
      }
    } on SocketException {
      return null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Lưu thông tin user
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  /// Lấy thông tin user
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  /// -------------------- ĐĂNG KÝ --------------------
  static Future<String?> register(
      String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return "Đăng ký thành công!";
      } else {
        return "Đăng ký thất bại";
      }
    } catch (e) {
      return "Lỗi: $e";
    }
  }

  /// -------------------- TOKEN --------------------
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  /// Lấy Customer ID
  static Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('customerId');
  }

  /// Lưu Customer ID
  static Future<void> saveCustomerId(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customerId', customerId);
  }

  /// Đăng xuất và xóa token, customerId, user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('customerId');
    await prefs.remove('user');
  }

  /// Quên mật khẩu
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse("$baseUrl/auth/forgot-password");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": true,
          "message": "Failed to send reset password email"
        };
      }
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  /// Đổi mật khẩu
  static Future<Map<String, dynamic>> resetPassword(
      String oldPassword, String newPassword) async {
    final token = await getToken();
    if (token == null) {
      return {"error": true, "message": "Bạn cần đăng nhập lại."};
    }

    final url = Uri.parse("$baseUrl/profile/me/change-password");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(
            {"currentPassword": oldPassword, "newPassword": newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "error": data["error"] ?? false,
          "message": data["message"] ?? "Đổi mật khẩu thành công."
        };
      } else {
        return {"error": true, "message": data["message"] ?? response.body};
      }
    } catch (e) {
      return {"error": true, "message": "Có lỗi xảy ra: $e"};
    }
  }
}
