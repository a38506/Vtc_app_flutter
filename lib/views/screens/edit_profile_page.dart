import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:marketky/constants/app_color.dart';
import '../../core/services/auth_service.dart';
import '../../constants/api_constants.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;
  const EditProfilePage({Key? key, this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _avatarFile;
  bool _loading = false;

  static const String baseUrl = ApiConstants.API_BASE;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.user?['phone'] ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) setState(() => _avatarFile = File(pickedFile.path));
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      String? avatarPath = widget.user?['avartar'];
      if (_avatarFile != null) {
        final uploadRequest = http.MultipartRequest(
            'POST', Uri.parse('$baseUrl/profile/me/upload-avatar'));
        uploadRequest.files.add(
            await http.MultipartFile.fromPath('avatar', _avatarFile!.path));
        final uploadResponse = await uploadRequest.send();
        if (uploadResponse.statusCode == 200) {
          final respStr = await uploadResponse.stream.bytesToString();
          final data = json.decode(respStr);
          avatarPath = data['avatar'];
        }
      }

      final token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'avatar': avatarPath,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công')),
        );
        Navigator.of(context).pop(json.decode(response.body));
      } else {
        throw Exception('Cập nhật thất bại: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
    setState(() => _loading = false);
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? hintText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: AppColor.secondary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppColor.secondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.primary, width: 1),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Color _lighterPrimary(double amount) {
    // Nhạt màu primary theo % amount (0.0 - 1.0)
    return Color.alphaBlend(Colors.white.withOpacity(amount), AppColor.primary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // toàn trang trắng như login
      appBar: AppBar(
        backgroundColor: _lighterPrimary(0.1), // nhạt 20%
        elevation: 1,
        centerTitle: false,
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(
            color: AppColor.primarySoft,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primarySoft),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: AppColor.primary))
          else ...[
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColor.primarySoft,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (widget.user?['avartar'] != null
                              ? NetworkImage(widget.user!['avartar'])
                              : const AssetImage('assets/images/pp.jpg')
                                  as ImageProvider),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child:
                          const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Name
            _buildTextField(
                label: 'Họ tên',
                controller: _nameController,
                hintText: 'Nhập họ tên'),
            const SizedBox(height: 16),
            // Phone
            _buildTextField(
              label: 'Số điện thoại',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              readOnly: false,
            ),

            const SizedBox(height: 16),
            // Role (read-only)
            _buildTextField(
              label: 'Vai trò',
              controller: TextEditingController(text: 'Khách hàng'),
              readOnly: true,
            ),
            const SizedBox(height: 32),
            // Save button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 74, 74, 146),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Lưu thông tin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ]
        ],
      ),
    );
  }
}
