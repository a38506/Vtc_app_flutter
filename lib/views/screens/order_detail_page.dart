import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/order_model.dart'; // import model Order, OrderItem, Payment

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? orderDetail;
  bool isLoading = true;
  bool showAllItems = false;

  final Map<String, String> orderStatusMap = {
    'pending': 'Đang xử lý',
    'confirmed': 'Xác nhận',
    'shipping': 'Vận chuyển',
    'delivered': 'Đã nhận',
    'cancel': 'Đã hủy',
    'closed': 'Đóng hàng',
    'created': 'Tạo mới',
  };

  final Map<String, String> paymentStatusMap = {
    'pending': 'Chưa thanh toán',
    'paid': 'Đã thanh toán',
    'failed': 'Thanh toán thất bại',
  };

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    try {
      await AuthService.getToken(); // token nếu cần
      final detail = await OrderService.getOrderDetail(widget.orderId);
      setState(() {
        orderDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load order detail: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}';
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
      case 'created':
        return Colors.blueGrey;
      default:
        return Colors.black;
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
              child: Text(
            value,
            style: TextStyle(color: valueColor ?? Colors.black),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (orderDetail == null) {
      return const Scaffold(
        body: Center(child: Text('Không thể tải chi tiết đơn hàng')),
      );
    }

    final items = orderDetail!.items;
    final displayItems = showAllItems ? items : items.take(2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã đơn & trạng thái
            Text(
              'Mã đơn hàng: ${orderDetail!.orderNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text('Ngày đặt: ${formatDate(orderDetail!.orderDate)}'),
            Text(
              'Trạng thái: ${orderStatusMap[orderDetail!.orderStatus] ?? 'Không rõ'}',
              style: TextStyle(
                  color: getStatusColor(orderDetail!.orderStatus),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Thông tin giao hàng
            if ((orderDetail!.recipientName?.isNotEmpty ?? false) ||
                (orderDetail!.shippingAddress?.isNotEmpty ?? false))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin giao hàng',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (orderDetail!.recipientName != null)
                    _buildInfoRow('Người nhận', orderDetail!.recipientName!),
                  if (orderDetail!.recipientPhone != null)
                    _buildInfoRow('SĐT', orderDetail!.recipientPhone!),
                  if (orderDetail!.shippingAddress != null)
                    _buildInfoRow('Địa chỉ', orderDetail!.shippingAddress!),
                  if (orderDetail!.shippingProvince != null)
                    _buildInfoRow('Tỉnh/TP', orderDetail!.shippingProvince!),
                  if (orderDetail!.shippingDistrict != null)
                    _buildInfoRow('Quận/Huyện', orderDetail!.shippingDistrict!),
                  if (orderDetail!.shippingWard != null)
                    _buildInfoRow('Phường/Xã', orderDetail!.shippingWard!),
                  const SizedBox(height: 16),
                ],
              ),

            // Thanh toán
            if (orderDetail!.paymentMethod != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thanh toán',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildInfoRow('Phương thức', orderDetail!.paymentMethod!),
                  if (orderDetail!.paymentStatus != null)
                    _buildInfoRow(
                        'Trạng thái',
                        paymentStatusMap[orderDetail!.paymentStatus!] ??
                            orderDetail!.paymentStatus!,
                        valueColor:
                            orderDetail!.paymentStatus == 'pending'
                                ? Colors.red
                                : Colors.green),
                  const SizedBox(height: 16),
                ],
              ),

            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  orderDetail!.totalAmount.toStringAsFixed(0) + ' ₫',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Danh sách sản phẩm
            if (items.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sản phẩm trong đơn',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...displayItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          
                          
                            Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child:
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName),
                              Text('Số lượng: ${item.quantity}',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          )),
                          Text('${item.unitPrice.toStringAsFixed(0)} ₫',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                  if (items.length > 2)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAllItems = !showAllItems;
                          });
                        },
                        child: Text(showAllItems
                            ? 'Thu gọn'
                            : 'Xem thêm (${items.length - 2} sản phẩm)'),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),

            // Ghi chú
            if (orderDetail!.notes != null && orderDetail!.notes!.isNotEmpty)
              Text(
                'Ghi chú: ${orderDetail!.notes}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
