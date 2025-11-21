import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
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
    if (pickedFile != null) {
      setState(() => _avatarFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);

    try {
      String? avatarPath = widget.user?['avartar'];

      if (_avatarFile != null) {
        final uploadRequest =
            http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/me/upload-avatar'));
        uploadRequest.files
            .add(await http.MultipartFile.fromPath('avatar', _avatarFile!.path));
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
          SnackBar(content: Text('Cập nhật thông tin thành công')),
        );
        Navigator.of(context).pop(json.decode(response.body));
      } else {
        throw Exception('Cập nhật thất bại: ${response.body}');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        backgroundColor: AppColor.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : (widget.user?['avartar'] != null
                                  ? NetworkImage(widget.user!['avartar'])
                                  : AssetImage('assets/images/pp.jpg')
                                      as ImageProvider),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColor.primary,
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Họ tên
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ tên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Số điện thoại
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Vai trò (read-only)
                  TextFormField(
                    initialValue: widget.user?['role_name'] ?? 'Khách hàng',
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Nút lưu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lưu thông tin',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

