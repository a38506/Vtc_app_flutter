import 'package:flutter/material.dart';
import 'order_detail_page.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  // Map trạng thái BE sang tiếng Việt
  final Map<String, String> orderStatusMap = {
    'pending': 'Đang xử lý',
    'confirmed': 'Xác nhận',
    'shipping': 'Vận chuyển',
    'delivered': 'Đã nhận',
    'cancel': 'Đã hủy',
    'closed': 'Đóng hàng',
  };

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final token = await AuthService.getToken();
      final fetchedOrders = await OrderService.getMyOrders(token!);
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (error) {
      print('Failed to load orders: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.red;
      case 'confirmed':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancel':
        return Colors.grey;
      case 'closed':
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('Không có đơn hàng nào.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bộ lọc trạng thái đơn hàng
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            FilterButton(title: 'Tất cả'),
                            SizedBox(width: 8),
                            FilterButton(title: 'Đang xử lý'),
                            SizedBox(width: 8),
                            FilterButton(title: 'Xác nhận'),
                            SizedBox(width: 8),
                            FilterButton(title: 'Đóng hàng'),
                            SizedBox(width: 8),
                            FilterButton(title: 'Vận chuyển'),
                            SizedBox(width: 8),
                            FilterButton(title: 'Đã nhận'),
                            SizedBox(width: 8),
                            FilterButton(title: 'Đã hủy'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Danh sách đơn hàng
                      Expanded(
                        child: ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return OrderCard(
                              order: order,
                              orderStatusMap: orderStatusMap,
                              onTap: () {
                                final orderId = order['id'] ?? '';
                                if (orderId.isNotEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderDetailPage(orderId: orderId),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String title;

  const FilterButton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Thêm logic lọc trạng thái đơn hàng tại đây
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;
  final Map<String, String> orderStatusMap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.orderStatusMap,
  });

  Color getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.red;
      case 'confirmed':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancel':
        return Colors.grey;
      case 'closed':
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['order_status'] ?? '';
    final totalAmount = order['total_amount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đơn hàng ${order['order_number'] ?? 'N/A'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order['order_date'] != null
                  ? '${DateTime.parse(order['order_date']).toLocal()}'
                  : '',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${totalAmount.toStringAsFixed(0)} ₫',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  orderStatusMap[status] ?? 'Không rõ',
                  style: TextStyle(
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onTap,
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
