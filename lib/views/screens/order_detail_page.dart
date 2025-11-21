import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<String, dynamic>? orderDetail;
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
      final token = await AuthService.getToken();
      final detail = await OrderService.getOrderDetail(widget.orderId, token!);
      setState(() {
        orderDetail = detail;
        isLoading = false;
      });
    } catch (error) {
      print('Failed to load order detail: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final dt = DateTime.tryParse(isoDate)?.toLocal();
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

    final items = (orderDetail!['items'] as List<dynamic>? ?? []);
    final displayItems =
        showAllItems ? items : items.take(2).toList(); // chỉ 2 item nếu chưa mở rộng

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
              'Mã đơn hàng: ${orderDetail!['order_number'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text('Ngày đặt: ${formatDate(orderDetail!['order_date'])}'),
            Text(
              'Trạng thái: ${orderStatusMap[orderDetail!['order_status']] ?? 'Không rõ'}',
              style: TextStyle(
                  color: getStatusColor(orderDetail!['order_status']),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Thông tin giao hàng
            if ((orderDetail!['recipient_name'] ?? '').isNotEmpty ||
                (orderDetail!['shipping_address'] ?? '').toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin giao hàng',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if ((orderDetail!['recipient_name'] ?? '').isNotEmpty)
                    _buildInfoRow('Người nhận', orderDetail!['recipient_name']),
                  if ((orderDetail!['recipient_phone'] ?? '').isNotEmpty)
                    _buildInfoRow('SĐT', orderDetail!['recipient_phone']),
                  if ((orderDetail!['shipping_address'] ?? '').isNotEmpty)
                    _buildInfoRow('Địa chỉ', orderDetail!['shipping_address']),
                  if ((orderDetail!['shipping_province'] ?? '').isNotEmpty)
                    _buildInfoRow('Tỉnh/TP', orderDetail!['shipping_province']),
                  if ((orderDetail!['shipping_district'] ?? '').isNotEmpty)
                    _buildInfoRow('Quận/Huyện', orderDetail!['shipping_district']),
                  if ((orderDetail!['shipping_ward'] ?? '').isNotEmpty)
                    _buildInfoRow('Phường/Xã', orderDetail!['shipping_ward']),
                  const SizedBox(height: 16),
                ],
              ),

            // Thanh toán
            if ((orderDetail!['payment_method'] ?? '').isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thanh toán',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildInfoRow('Phương thức', orderDetail!['payment_method']),
                  if ((orderDetail!['payment_status'] ?? '').isNotEmpty)
                    _buildInfoRow(
                        'Trạng thái',
                        paymentStatusMap[orderDetail!['payment_status']] ??
                            orderDetail!['payment_status'],
                        valueColor: (orderDetail!['payment_status'] ?? '') ==
                                'pending'
                            ? Colors.red
                            : Colors.green),
                  const SizedBox(height: 16),
                ],
              ),

            // Vận chuyển
            if (orderDetail!['shipment'] != null &&
                (orderDetail!['shipment'] as Map).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vận chuyển',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      'Tracking',
                      orderDetail!['shipment']?['tracking_number'] ?? 'N/A'),
                  _buildInfoRow('Carrier',
                      orderDetail!['shipment']?['carrier_code'] ?? 'N/A'),
                  if (orderDetail!['shipment']?['shipping_cost'] != null)
                    _buildInfoRow(
                        'Phí vận chuyển',
                        double.tryParse(orderDetail!['shipment']?['shipping_cost']
                                    ?.toString() ??
                                '0')!
                            .toStringAsFixed(0) +
                            ' ₫'),
                  if (orderDetail!['shipment']?['estimated_delivery_date'] != null)
                    _buildInfoRow(
                        'Ngày dự kiến',
                        formatDate(orderDetail!['shipment']?['estimated_delivery_date'])),
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
                  '${double.tryParse(orderDetail!['total_amount']?.toString() ?? '0')!.toStringAsFixed(0)} ₫',
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
                    final quantity = item['quantity'] ?? 0;
                    final unitPrice =
                        double.tryParse(item['unit_price'].toString()) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          if (item['image'] != null &&
                              item['image'].toString().isNotEmpty)
                            Image.network(item['image'],
                                width: 50, height: 50, fit: BoxFit.cover)
                          else
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
                              Text(item['product_name'] ?? ''),
                              Text('Số lượng: $quantity',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          )),
                          Text('${unitPrice.toStringAsFixed(0)} ₫',
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
            if (orderDetail!['notes'] != null &&
                orderDetail!['notes'].toString().isNotEmpty)
              Text(
                'Ghi chú: ${orderDetail!['notes']}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
