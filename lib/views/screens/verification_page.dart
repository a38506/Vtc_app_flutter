import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/views/screens/page_switcher.dart';

class OTPVerificationPage extends StatefulWidget {
  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFE),
        elevation: 0,
        title: const Text(
          'Xác minh',
          style: TextStyle(
              color: AppColor.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SvgPicture.asset('assets/icons/Arrow-left.svg',
              colorFilter: const ColorFilter.mode(
                  AppColor.secondary, BlendMode.srcIn)),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 32),

          // Title
          const Text(
            'Xác minh email',
            style: TextStyle(
              color: AppColor.secondary,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Chúng tôi đã gửi email xác minh đến địa chỉ của bạn.\nVui lòng kiểm tra hộp thư và nhấp vào liên kết để xác minh tài khoản.',
            style: TextStyle(
              color: AppColor.secondary.withOpacity(0.75),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),

          // Icon Email Sent - with gradient background
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.mark_email_read_rounded,
                  size: 70,
                  color: AppColor.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.primarySoft.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.border.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.info_outline,
                      color: AppColor.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nếu không thấy email, hãy kiểm tra thư mục Spam',
                    style: TextStyle(
                      color: AppColor.secondary.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Button Quay lại đăng nhập
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              backgroundColor: AppColor.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Text(
              'Quay lại đăng nhập',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary Button - Gửi lại email
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Email xác minh đã được gửi lại'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              side: const BorderSide(color: AppColor.primary, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Gửi lại email xác minh',
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
