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

  print("\n==============================");
  print("🔹 [LOGIN REQUEST]");
  print("➡️ URL: $url");
  print("📦 Body: ${jsonEncode({'email': email, 'password': password})}");
  print("==============================");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("\n✅ [LOGIN RESPONSE]");
    print("📄 Status Code: ${response.statusCode}");
    print("📦 Response Body: ${response.body}");
    print("==============================");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final auth = AuthResponse.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', auth.token);

      if (data['user'] != null) {
        final user = data['user'];
        // ✅ Lưu toàn bộ user để dùng ở ProfilePage
        await prefs.setString('user', jsonEncode(user));

        final customerId = int.tryParse(user['customer_id'].toString());
        if (customerId != null) await prefs.setInt('customerId', customerId);
      }

      print("✅ Token & user info saved.");
      return auth;
    }
  } on SocketException catch (e) {
    print("🚫 Không có kết nối mạng: ${e.message}");
  } on FormatException catch (e) {
    print("⚠️ Lỗi định dạng dữ liệu JSON: ${e.message}");
  } catch (e) {
    print("🔥 Lỗi không xác định: $e");
  }
  return null;
}


  /// -------------------- LƯU USER --------------------
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  /// -------------------- LẤY USER --------------------
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

    print("\n==============================");
    print("📝 [REGISTER REQUEST]");
    print("➡️ URL: $url");
    print("📦 Body: ${jsonEncode({
          'name': name,
          'email': email,
          'password': password
        })}");
    print("==============================");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      print("📄 Status: ${response.statusCode}");
      print("📦 Response: ${response.body}");

      if (response.statusCode == 201) {
        print("🎉 Đăng ký thành công!");
        return data['message'] ?? "Đăng ký thành công!";
      } else {
        return "❌ Đăng ký thất bại: ${data['message'] ?? response.statusCode}";
      }
    } catch (e) {
      print("🔥 Lỗi trong quá trình đăng ký: $e");
      return "Lỗi: $e";
    }
  }

  /// -------------------- TOKEN --------------------
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("🔑 Token hiện tại: $token");
    return token;
  }

  /// -------------------- CUSTOMER ID --------------------
  static Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('customerId');
    print("🧍 Customer ID hiện tại: $id");
    return id;
  }

  /// -------------------- LƯU CUSTOMER ID --------------------
  static Future<void> saveCustomerId(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customerId', customerId);
    print("💾 Customer ID saved: $customerId");
  }

  /// -------------------- ĐĂNG XUẤT --------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('customerId');
    await prefs.remove('user'); // 🧹 Xóa luôn dữ liệu user
    print("🚪 Đã đăng xuất và xóa token + customerId + user");
  }
}
