// location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketky/constants/api_constants.dart';

class Province {
  final String code;
  final String name;

  Province({required this.code, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'].toString(),
      name: json['name'],
    );
  }
}

class District {
  final String code;
  final String name;

  District({required this.code, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      code: json['code'].toString(),
      name: json['name'],
    );
  }
}

class Ward {
  final String code;
  final String name;

  Ward({required this.code, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['code'].toString(),
      name: json['name'],
    );
  }
}

class LocationService {
  final String baseUrl = '${ApiConstants.API_BASE}/locations';

  /// Lấy danh sách tất cả Tỉnh/Thành phố
  Future<List<Province>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/provinces'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Province.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      print('❌ Lỗi khi lấy provinces: $e');
      return [];
    }
  }

  /// Lấy danh sách Quận/Huyện dựa vào mã Tỉnh/Thành phố
  Future<List<District>> getDistricts(String provinceId) async {
    if (provinceId.isEmpty) return [];
    try {
      final response = await http.get(Uri.parse('$baseUrl/districts/$provinceId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => District.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      print('❌ Lỗi khi lấy districts cho province $provinceId: $e');
      return [];
    }
  }

  /// Lấy danh sách Phường/Xã dựa vào mã Quận/Huyện
  Future<List<Ward>> getWards(String districtId) async {
    if (districtId.isEmpty) return [];
    try {
      final response = await http.get(Uri.parse('$baseUrl/wards/$districtId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Ward.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wards');
      }
    } catch (e) {
      print('❌ Lỗi khi lấy wards cho district $districtId: $e');
      return [];
    }
  }
}
 