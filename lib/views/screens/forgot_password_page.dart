import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import '../../core/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _show("Vui lòng nhập email");
      return;
    }

    setState(() => _loading = true);

    final response = await AuthService.forgotPassword(email);

    setState(() => _loading = false);

    if (response["error"] == false) {
      _show("📩 Nếu email đúng, liên kết đặt lại mật khẩu đã được gửi.");
    } else {
      _show("❌ ${response["message"] ?? "Gửi yêu cầu thất bại"}");
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quên mật khẩu"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        children: [
          SizedBox(height: 20),

          Text(
            "Khôi phục mật khẩu",
            style: TextStyle(
              color: AppColor.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 12),

          Text(
            "Nhập email để nhận hướng dẫn đặt lại mật khẩu.",
            style: TextStyle(
              color: AppColor.secondary.withOpacity(0.7),
              fontSize: 12,
            ),
          ),

          SizedBox(height: 32),

          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "email@domain.com",
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: SvgPicture.asset("assets/icons/Message.svg",
                    color: AppColor.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.border, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.primary, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: AppColor.primarySoft,
              filled: true,
            ),
          ),

          SizedBox(height: 25),

          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _loading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    "Gửi yêu cầu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
