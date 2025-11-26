import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketky/core/models/review_model.dart';
import 'package:marketky/core/services/auth_service.dart';
import '../../constants/api_constants.dart';

class ReviewService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// Lấy các review đã được duyệt của sản phẩm
  static Future<List<Review>> getApprovedReviews(int productId) async {
    final url = Uri.parse('$baseUrl/reviews/products/$productId/reviews');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Fetch reviews lỗi: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Review.fromJson(json)).toList();
  }

  /// Gửi review mới (yêu cầu login)
  static Future<Review> submitReview({
    required int productId,
    required int rating,
    required String title,
    required String content,
    List<String>? images,
  }) async {
    final token = await AuthService.getToken();

    final url = Uri.parse('$baseUrl/reviews/products/$productId/reviews');

    final bodyMap = {
      'rating': rating,
      'title': title,
      'content': content,
      'images': images ?? [],
    };

    final body = jsonEncode(bodyMap);

    // === LOG để debug ===
    print('--- SUBMIT REVIEW ---');
    print('URL: $url');
    print('Headers: Authorization: Bearer $token');
    print('Body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return Review.fromJson(data);
    } else {
      throw Exception('Submit review thất bại: ${response.body}');
    }
  }
}
