import 'package:flutter/material.dart';
import 'order_detail_page.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/order_model.dart'; // import model Order

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Order> orders = [];
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

      // Lấy JSON từ API
      final fetchedOrdersJson = await OrderService.getMyOrders();

      // In ra JSON gốc
      print('Fetched orders JSON: $fetchedOrdersJson');

      // Parse từng order an toàn
      final List<Order> fetchedOrders = [];
      for (var json in fetchedOrdersJson) {
        try {
          final order = Order.fromJson(json as Map<String, dynamic>);
          print(
              'Parsed order: ${order.orderNumber}, totalAmount: ${order.totalAmount}');
          fetchedOrders.add(order);
        } catch (e, stackTrace) {
          print('Failed to parse order: $json');
          print('Error: $e');
          print(stackTrace);
        }
      }

      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (error, stackTrace) {
      print('Failed to load orders: $error');
      print(stackTrace);
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrderDetailPage(orderId: order.id),
                                  ),
                                );
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
  final Order order;
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
    final status = order.orderStatus;
    final totalAmount = order.totalAmount;
    final orderDate = order.orderDate;

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
              'Đơn hàng ${order.orderNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              orderDate != null ? '${orderDate.toLocal()}' : '',
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
