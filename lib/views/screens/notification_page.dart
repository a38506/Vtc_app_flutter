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
      'subtitle': 'Áp dụng cho đơn hàng từ 0đ',
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

  @override
  Widget build(BuildContext context) {
    final headerBg = LinearGradient(
      colors: [AppColor.primary.withOpacity(0.06), AppColor.primarySoft],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primary),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.primary))
          : RefreshIndicator(
              onRefresh: _loadOrderNotifications,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header / Promo area
                  Container(
                    decoration: BoxDecoration(
                      gradient: headerBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColor.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_active, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Cập nhật đơn hàng & chương trình',
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Nhận thông báo về trạng thái đơn hàng và khuyến mãi mới nhất.',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _loadOrderNotifications(),
                          child: const Text('Làm mới', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Promo horizontal list
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: promos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final promo = promos[idx];
                        return Container(
                          width: 260,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColor.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.primary,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                promo['subtitle']!,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.accent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {},
                                  child: const Text('Xem', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section title
                  const Text(
                    "Thông báo đơn hàng",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.secondary),
                  ),
                  const SizedBox(height: 12),

                  // Notifications list
                  if (orderNotifications.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: AppColor.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.border),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.notifications_off, size: 48, color: AppColor.primary),
                          SizedBox(height: 12),
                          Text('Chưa có thông báo', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderNotifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final order = orderNotifications[i];
                        final status = orderStatus[order.orderStatus] ??
                            {'text': order.orderStatus, 'color': Colors.grey};
                        final statusColor = status['color'] as Color;
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailPage(orderId: order.id),
                              ),
                            );
                            _loadOrderNotifications();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColor.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColor.primarySoft,
                                  child: Icon(Icons.shopping_bag, color: AppColor.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Đơn #${order.orderNumber}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700, color: AppColor.secondary),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Ngày: ${formatDate(order.orderDate)}",
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status['text'],
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Icon(Icons.chevron_right, color: Colors.black26),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
