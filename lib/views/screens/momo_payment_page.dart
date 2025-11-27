import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/views/screens/order_success_page.dart';
import 'package:marketky/core/services/auth_service.dart';
import 'package:marketky/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class MoMoPaymentPage extends StatefulWidget {
  final int orderId;
  final double totalAmount;
  final String momoQrUrl;
  final String? returnUrl;

  const MoMoPaymentPage({
    Key? key,
    required this.orderId,
    required this.totalAmount,
    required this.momoQrUrl,
    this.returnUrl,
  }) : super(key: key);

  @override
  State<MoMoPaymentPage> createState() => _MoMoPaymentPageState();
}

class _MoMoPaymentPageState extends State<MoMoPaymentPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchMoMoPayment() async {
    try {
      final uri = Uri.parse(widget.momoQrUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Không thể mở liên kết thanh toán';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchOrderRaw(int orderId) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${ApiConstants.API_BASE}/orders/$orderId');
      final res = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          if (data.containsKey('order') && data['order'] is Map<String, dynamic>) {
            return Map<String, dynamic>.from(data['order']);
          }
          return data;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _isLoading = true);
    
    final orderMap = await _fetchOrderRaw(widget.orderId);
    
    setState(() => _isLoading = false);
    
    if (orderMap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy thông tin đơn. Thử lại sau.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final paymentStatus =
        (orderMap['payment_status'] ?? '').toString().toLowerCase();
    
    if (paymentStatus == 'paid' ||
        paymentStatus == 'completed' ||
        paymentStatus == 'success') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(order: orderMap),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa thanh toán. Vui lòng hoàn tất thanh toán.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary.withOpacity(0.08),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Thanh toán MoMo',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.qr_code_2,
                size: 60,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quét mã QR để thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColor.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nhấn nút bên dưới để mở ứng dụng MoMo hoặc trang thanh toán',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.secondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số tiền:',
                        style: TextStyle(
                          color: AppColor.secondary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${widget.totalAmount.toStringAsFixed(0)} ₫',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColor.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã đơn hàng:',
                        style: TextStyle(
                          color: AppColor.secondary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '#${widget.orderId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchMoMoPayment,
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  'Mở trang thanh toán MoMo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _checkPaymentStatus,
                icon: Icon(
                  Icons.check_circle,
                  color: _isLoading ? Colors.grey : AppColor.primary,
                ),
                label: Text(
                  _isLoading ? 'Đang kiểm tra...' : 'Tôi đã thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isLoading ? Colors.grey : AppColor.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isLoading ? Colors.grey : AppColor.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sau khi thanh toán thành công, nhấn "Tôi đã thanh toán" để xác nhận.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColor.secondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
