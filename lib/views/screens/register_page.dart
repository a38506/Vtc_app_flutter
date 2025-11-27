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
  final _formKey = GlobalKey<FormState>();
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
    return _hasMinLength && _hasUpperCase && _hasLowerCase && _hasNumber;
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
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      _showSnackBar('Vui lòng đồng ý điều khoản');
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();

    if (password != repeatPassword) {
      _showSnackBar('Mật khẩu không khớp');
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
              MaterialPageRoute(builder: (c) => OTPVerificationPage()));
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
    return Row(
      children: [
        Icon(isValid ? Icons.check_circle : Icons.cancel,
            size: 14, color: isValid ? Colors.green : AppColor.border),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              fontSize: 12,
              color: isValid
                  ? Colors.green
                  : AppColor.secondary.withOpacity(0.6)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use same form layout/padding as LoginPage for UI consistency
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Đăng ký',
          style:
              TextStyle(color: AppColor.secondary, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 48,
        alignment: Alignment.center,
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã có tài khoản?',
                style: TextStyle(
                    color: AppColor.secondary.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              Text(
                'Đăng nhập',
                style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              )
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20),
          Text(
            'Tạo tài khoản mới',
            style: TextStyle(
                color: AppColor.secondary,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Điền thông tin để đăng ký và quản lý đơn hàng của bạn.',
            style: TextStyle(
                color: AppColor.secondary.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Họ và tên',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset('assets/icons/User.svg',
                          color: AppColor.primary),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.primary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: AppColor.primarySoft,
                    filled: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'email@domain.com',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset('assets/icons/Message.svg',
                          color: AppColor.primary),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.primary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: AppColor.primarySoft,
                    filled: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child:
                          SvgPicture.asset('assets/icons/Lock.svg', color: AppColor.primary),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.primary, width: 1),
                      borderRadius: BorderRadius.circular(8),
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (!_isPasswordValid()) {
                      return 'Mật khẩu yếu (ít nhất 8 ký tự, chữ hoa, chữ thường, số)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Password requirements (compact)
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _passwordRequirement('Ít nhất 8 ký tự', _hasMinLength),
                      const SizedBox(height: 4),
                      _passwordRequirement('Chứa chữ hoa', _hasUpperCase),
                      const SizedBox(height: 4),
                      _passwordRequirement('Chứa chữ thường', _hasLowerCase),
                      const SizedBox(height: 4),
                      _passwordRequirement('Chứa số', _hasNumber),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Confirm password
                TextFormField(
                  controller: _repeatPasswordController,
                  obscureText: _obscureRepeatPassword,
                  decoration: InputDecoration(
                    hintText: 'Xác nhận mật khẩu',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child:
                          SvgPicture.asset('assets/icons/Lock.svg', color: AppColor.primary),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColor.primary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: AppColor.primarySoft,
                    filled: true,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                          () => _obscureRepeatPassword = !_obscureRepeatPassword),
                      icon: Icon(
                        _obscureRepeatPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                    if (v != _passwordController.text) return 'Mật khẩu không khớp';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Agree terms
                Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                      activeColor: AppColor.primary,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Tôi đồng ý với ',
                          style: TextStyle(color: AppColor.secondary.withOpacity(0.8)),
                          children: [
                            TextSpan(text: 'Điều khoản dịch vụ', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w700)),
                            TextSpan(text: ' và '),
                            TextSpan(text: 'Chính sách bảo mật', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Register button (styled like Login)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Đăng ký',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
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
