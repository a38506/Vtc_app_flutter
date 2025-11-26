import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';
import '../models/category_model.dart';

class CategoryService {
  static const String baseUrl = ApiConstants.API_BASE;

  /// Lấy tất cả danh mục
  /// Trả về List<Category>, nếu thất bại trả về list rỗng
  static Future<List<Category>> getAllCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/categories"));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Category.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Lấy chi tiết danh mục theo id
  /// Trả về Category nếu thành công, ngược lại trả về null
  static Future<Category?> getCategoryById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories/$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Category.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
