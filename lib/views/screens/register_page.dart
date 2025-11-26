import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/views/screens/login_page.dart';
import 'package:marketky/views/screens/verification_page.dart';
import '../../core/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _agreeTerms = false;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength &&
        _hasUpperCase &&
        _hasLowerCase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();

    // Validation
    if (name.isEmpty) {
      _showSnackBar('Vui lòng nhập họ và tên');
      return;
    }

    if (email.isEmpty) {
      _showSnackBar('Vui lòng nhập email');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showSnackBar('Email không hợp lệ');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu');
      return;
    }

    if (!_isPasswordValid()) {
      _showSnackBar(
          'Mật khẩu phải có ít nhất 8 ký tự, chứa chữ hoa, chữ thường và số');
      return;
    }

    if (password != repeatPassword) {
      _showSnackBar('Mật khẩu không khớp');
      return;
    }

    if (!_agreeTerms) {
      _showSnackBar('Vui lòng đồng ý với điều khoản và điều kiện');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await AuthService.register(name, email, password);

      if (message != null) {
        _showSnackBar(message,
            isSuccess: message.contains("Đăng ký thành công"));
        if (message.contains("Đăng ký thành công")) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OTPVerificationPage()),
          );
        }
      } else {
        _showSnackBar('Đăng ký thất bại. Vui lòng thử lại');
      }
    } catch (e) {
      _showSnackBar('Đăng ký thất bại: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _passwordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isValid ? Colors.green : AppColor.border,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color:
                  isValid ? Colors.green : AppColor.secondary.withOpacity(0.6),
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Color _lighterPrimary(double amount) {
    return Color.alphaBlend(Colors.white.withOpacity(amount), AppColor.primary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: _lighterPrimary(0.08),
        elevation: 0,
        title: const Text(
          'Đăng ký',
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColor.primary),
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 56,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()));
          },
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Đã có tài khoản? ',
                  style: TextStyle(
                    color: AppColor.secondary.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(
                  text: 'Đăng nhập',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 24),
          const Text(
            'Chào mừng đến với Nông sản sạch 👋',
            style: TextStyle(
              color: AppColor.secondary,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng điền thông tin để tạo tài khoản mới.',
            style: TextStyle(
              color: AppColor.secondary.withOpacity(0.7),
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),

          // Họ và tên
          Text(
            'Họ và tên',
            style: TextStyle(
              color: AppColor.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nhập họ và tên của bạn',
              hintStyle: TextStyle(
                color: AppColor.secondary.withOpacity(0.5),
              ),
              prefixIcon: const Icon(Icons.person, color: AppColor.primary),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.border),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.primary, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: AppColor.primarySoft,
              filled: true,
            ),
          ),
          const SizedBox(height: 18),

          // Email
          Text(
            'Email',
            style: TextStyle(
              color: AppColor.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Nhập email của bạn',
              hintStyle: TextStyle(
                color: AppColor.secondary.withOpacity(0.5),
              ),
              prefixIcon: const Icon(Icons.email, color: AppColor.primary),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.border),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.primary, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: AppColor.primarySoft,
              filled: true,
            ),
          ),
          const SizedBox(height: 18),

          // Mật khẩu
          Text(
            'Mật khẩu',
            style: TextStyle(
              color: AppColor.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu',
              hintStyle: TextStyle(
                color: AppColor.secondary.withOpacity(0.5),
              ),
              prefixIcon: const Icon(Icons.lock, color: AppColor.primary),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.border),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.primary, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: AppColor.primarySoft,
              filled: true,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Nhập lại mật khẩu
          Text(
            'Xác nhận mật khẩu',
            style: TextStyle(
              color: AppColor.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _repeatPasswordController,
            obscureText: _obscureRepeatPassword,
            decoration: InputDecoration(
              hintText: 'Nhập lại mật khẩu',
              hintStyle: TextStyle(
                color: AppColor.secondary.withOpacity(0.5),
              ),
              prefixIcon: const Icon(Icons.lock, color: AppColor.primary),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.border),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.primary, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: AppColor.primarySoft,
              filled: true,
              suffixIcon: IconButton(
                onPressed: () => setState(
                    () => _obscureRepeatPassword = !_obscureRepeatPassword),
                icon: Icon(
                  _obscureRepeatPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColor.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Agree to terms
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.border),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _agreeTerms,
                  onChanged: (value) =>
                      setState(() => _agreeTerms = value ?? false),
                  activeColor: AppColor.primary,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tôi đồng ý với ',
                          style: TextStyle(
                            color: AppColor.secondary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const TextSpan(
                          text: 'Điều khoản dịch vụ',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' và ',
                          style: TextStyle(
                            color: AppColor.secondary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const TextSpan(
                          text: 'Chính sách bảo mật',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Button đăng ký
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              backgroundColor: AppColor.primary,
              disabledBackgroundColor: AppColor.primary.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }
}
