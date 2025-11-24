import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import '../../core/services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _loading = false;
  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String hint, bool isHidden, VoidCallback toggle) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Container(
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset("assets/icons/Lock.svg", color: AppColor.primary),
      ),
      suffixIcon: IconButton(
        onPressed: toggle,
        icon: isHidden
            ? SvgPicture.asset("assets/icons/Hide.svg", color: AppColor.primary)
            : SvgPicture.asset("assets/icons/Show.svg", color: AppColor.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
    );
  }

  Future<void> _reset() async {
    final oldPass = _oldPassword.text.trim();
    final newPass = _newPassword.text.trim();
    final confirm = _confirmPassword.text.trim();

    if (oldPass.isEmpty) {
      _show("Vui lòng nhập mật khẩu hiện tại");
      return;
    }
    if (newPass.length < 6) {
      _show("Mật khẩu phải ≥ 6 ký tự");
      return;
    }
    if (newPass != confirm) {
      _show("Mật khẩu nhập lại không khớp");
      return;
    }

    setState(() => _loading = true);

    final response = await AuthService.resetPassword(oldPass, newPass);

    setState(() => _loading = false);

    final error = response["error"] ?? true;
    final message = response["message"] ?? "Có lỗi xảy ra";

    _show(message);

    if (!error) {
      // Reset form, giữ người dùng ở trang này
      _oldPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đổi mật khẩu"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          Text(
            "Đổi mật khẩu",
            style: TextStyle(
              color: AppColor.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 32),

          // Mật khẩu hiện tại
          TextField(
            controller: _oldPassword,
            obscureText: _hideOld,
            decoration: _inputDecoration("Mật khẩu hiện tại", _hideOld, () {
              setState(() => _hideOld = !_hideOld);
            }),
          ),
          const SizedBox(height: 16),

          // Mật khẩu mới
          TextField(
            controller: _newPassword,
            obscureText: _hideNew,
            decoration: _inputDecoration("Mật khẩu mới", _hideNew, () {
              setState(() => _hideNew = !_hideNew);
            }),
          ),
          const SizedBox(height: 16),

          // Nhập lại mật khẩu mới
          TextField(
            controller: _confirmPassword,
            obscureText: _hideConfirm,
            decoration:
                _inputDecoration("Nhập lại mật khẩu mới", _hideConfirm, () {
              setState(() => _hideConfirm = !_hideConfirm);
            }),
          ),
          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: _loading ? null : _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Cập nhật mật khẩu",
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
