import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/views/screens/my_order_page.dart';

class OrderSuccessPage extends StatelessWidget {
  // Receive raw order map returned from API
  final Map<String, dynamic> order;

  const OrderSuccessPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String orderNumber =
        (order['order_number'] ?? order['orderNumber'] ?? '').toString();
    return Scaffold(
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 184,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          MyOrdersPage(orderId: orderNumber),
                    ),
                  );
                },
                child: Text(
                  'Xem đơn hàng của bạn',
                  style: TextStyle(
                      color: AppColor.secondary, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColor.primary,
                  backgroundColor: AppColor.border,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Tiếp tục mua sắm',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 124,
              height: 124,
              child: SvgPicture.asset('assets/icons/Success.svg'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Đặt hàng thành công! 😆',
              style: TextStyle(
                  color: AppColor.secondary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Chúng tôi đã nhận được đơn hàng của bạn\nMã đơn hàng: $orderNumber',
              style: TextStyle(
                color: AppColor.secondary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
