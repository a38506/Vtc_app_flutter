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
    final headerGradient = LinearGradient(
      colors: [AppColor.primary.withOpacity(0.06), AppColor.primarySoft],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: headerGradient,
            border: Border(
              bottom: BorderSide(color: AppColor.border),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / summary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản lý đơn hàng',
                          style: TextStyle(
                              color: AppColor.primary, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Xem trạng thái đơn, chi tiết và lịch sử giao hàng',
                          style: TextStyle(color: AppColor.secondary.withOpacity(0.8), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _loadOrders,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Làm mới'),
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Filters as chips
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
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterButton(
                        title: e.value['text'],
                        isSelected: selectedFilter == e.value['text'],
                        onTap: () => applyFilter(e.value['text']),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List or empty
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColor.primary))
                  : filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2, size: 64, color: AppColor.primarySoft),
                              const SizedBox(height: 12),
                              Text(
                                'Không có đơn hàng',
                                style: TextStyle(color: AppColor.secondary.withOpacity(0.8), fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          color: AppColor.primary,
                          child: ListView.separated(
                            itemCount: filteredOrders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return OrderCard(
                                order: filteredOrders[index],
                                orderStatus: orderStatus,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailPage(orderId: filteredOrders[index].id),
                                    ),
                                  ).then((_) => _loadOrders());
                                },
                              );
                            },
                          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColor.primary : AppColor.border),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColor.primary.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColor.secondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
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
    final statusInfo = orderStatus[order.orderStatus] ?? {'text': 'Không rõ', 'color': AppColor.secondary};
    final statusColor = statusInfo['color'] as Color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Thumbnail: if order has items with image try to show first, fallback to icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: order.items != null && order.items!.isNotEmpty && order.items!.first.image != null && order.items!.first.image!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          order.items!.first.image!,
                          fit: BoxFit.cover,
                          width: 64,
                          height: 64,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: AppColor.secondary),
                        ),
                      )
                    : const Icon(Icons.shopping_bag, color: AppColor.primary, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đơn #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(
                    order.orderDate != null ? DateFormat('dd/MM/yyyy – HH:mm').format(order.orderDate!) : '',
                    style: TextStyle(color: AppColor.secondary.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} ₫',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusInfo['text'], style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(foregroundColor: AppColor.primary),
                  child: const Text('Xem chi tiết'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
