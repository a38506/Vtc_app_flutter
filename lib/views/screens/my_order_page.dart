import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import 'order_detail_page.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/order_model.dart';
import 'package:intl/intl.dart';

class MyOrdersPage extends StatefulWidget {
  final String? orderId;

  const MyOrdersPage({Key? key, this.orderId}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = true;

  String selectedFilter = "Tất cả";

  final Map<String, Map<String, dynamic>> orderStatus = {
    'pending': {'text': 'Chờ xử lý', 'color': AppColor.accent},
    'processing': {'text': 'Đang xử lý', 'color': Colors.orange},
    'shipped': {'text': 'Vận chuyển', 'color': AppColor.primary},
    'completed': {'text': 'Đã nhận', 'color': Colors.green},
    'cancelled': {'text': 'Đã hủy', 'color': Colors.grey},
  };

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == "Tất cả") {
        filteredOrders = List.from(orders);
      } else {
        String key = orderStatus.entries
            .firstWhere((e) => e.value['text'] == filter)
            .key;

        filteredOrders = orders.where((o) => o.orderStatus == key).toList();
      }
    });
  }

  Future<void> _loadOrders() async {
    try {
      await AuthService.getToken();
      final fetchedOrdersJson = await OrderService.getMyOrders();

      List<Order> fetchedOrders = [];
      for (var json in fetchedOrdersJson) {
        try {
          fetchedOrders.add(Order.fromJson(json));
        } catch (e) {
          print("Parse error: $e");
        }
      }

      setState(() {
        orders = fetchedOrders;
        filteredOrders = List.from(fetchedOrders);
        isLoading = false;
      });
    } catch (e) {
      print("Load error: $e");
      setState(() => isLoading = false);
    }
  }

  Color _lighterPrimary(double amount) {
    // Nhạt màu primary theo % amount (0.0 - 1.0)
    return Color.alphaBlend(Colors.white.withOpacity(amount), AppColor.primary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _lighterPrimary(0.1), // nhạt 20%
        elevation: 1,
        centerTitle: false,
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            color: AppColor.primarySoft,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primarySoft),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- luôn hiện FILTER ----------------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                    title: 'Tất cả',
                    isSelected: selectedFilter == "Tất cả",
                    onTap: () => applyFilter("Tất cả"),
                  ),
                  const SizedBox(width: 8),
                  ...orderStatus.entries.map((e) {
                    return Row(
                      children: [
                        FilterButton(
                          title: e.value['text'],
                          isSelected: selectedFilter == e.value['text'],
                          onTap: () => applyFilter(e.value['text']),
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ---------------- LIST OR EMPTY ----------------
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            'Không có đơn hàng nào ở trạng thái này.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            return OrderCard(
                              order: filteredOrders[index],
                              orderStatus: orderStatus,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailPage(
                                        orderId: filteredOrders[index].id),
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
  final VoidCallback onTap;
  final bool isSelected;

  const FilterButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color.fromARGB(255, 74, 74, 146) : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColor.secondary,
        side:
            BorderSide(color: isSelected ? const Color.fromARGB(255, 74, 74, 146) : AppColor.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(title, style: const TextStyle(fontSize: 13)),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final Map<String, Map<String, dynamic>> orderStatus;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = orderStatus[order.orderStatus] ??
        {'text': 'Không rõ', 'color': Colors.black};

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColor.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đơn hàng ${order.orderNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              order.orderDate != null
                  ? DateFormat('dd/MM/yyyy – HH:mm').format(order.orderDate!)
                  : "",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${order.totalAmount.toStringAsFixed(0)} ₫',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  statusInfo['text'],
                  style: TextStyle(
                    color: statusInfo['color'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onTap,
                  child: Text(
                    'Xem chi tiết',
                    style: TextStyle(color: AppColor.primary),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
