import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/order_model.dart';
import '../../constants/app_color.dart';
import '../screens/order_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Order> orderNotifications = [];
  bool isLoading = true;

  // Trạng thái đơn hàng
  final Map<String, Map<String, dynamic>> orderStatus = {
    'pending': {'text': 'Chờ xử lý', 'color': AppColor.accent},
    'processing': {'text': 'Đang xử lý', 'color': AppColor.primary},
    'shipped': {'text': 'Đang vận chuyển', 'color': Colors.blue},
    'completed': {'text': 'Đã nhận', 'color': Colors.green},
    'cancelled': {'text': 'Đã hủy', 'color': Colors.grey},
  };

  final List<Map<String, String>> promos = [
    {
      'title': '11.11 Nhận ngay 1000 xu',
      'subtitle': 'Áp dụng cho mọi đơn hàng từ 0đ',
    },
    {
      'title': 'Black Friday Giảm 50%',
      'subtitle': 'Chỉ áp dụng hôm nay',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadOrderNotifications();
  }

  Future<void> _loadOrderNotifications() async {
    setState(() {
      isLoading = true;
    });
    try {
      await AuthService.getToken();
      final orders = await OrderService.getMyOrders();
      setState(() {
        orderNotifications = orders.map((e) => Order.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Load notifications failed: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy – HH:mm').format(dt);
  }

  Color _lighterPrimary(double amount) {
    return Color.alphaBlend(Colors.white.withOpacity(amount), AppColor.primary);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColor.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _lighterPrimary(0.1),
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: AppColor.primarySoft,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primarySoft),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= VOUCHER / PROMO =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dành riêng cho bạn",
                  style: TextStyle(
                      color: AppColor.secondary.withOpacity(0.7),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...promos.map((promo) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        bottom: 12), // cách nhau giữa các promo
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          promo['subtitle']!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),

            const SizedBox(height: 16),

            // ================= DANH SÁCH THÔNG BÁO =================
            Text(
              "Thông báo đơn hàng",
              style: TextStyle(
                  color: AppColor.secondary.withOpacity(0.7), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...orderNotifications.map((order) {
              final status = orderStatus[order.orderStatus] ??
                  {'text': order.orderStatus, 'color': Colors.grey};
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.border),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  onTap: () async {
                    // Mở chi tiết đơn hàng
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailPage(orderId: order.id),
                      ),
                    );
                    _loadOrderNotifications();
                  },
                  title: Text(
                    "Đơn #${order.orderNumber}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColor.secondary),
                  ),
                  subtitle: Text(
                    "Ngày đặt: ${formatDate(order.orderDate)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (status['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status['text'],
                      style: TextStyle(
                          color: status['color'], fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
