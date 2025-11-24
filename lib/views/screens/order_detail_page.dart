import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/review_service.dart';
import '../../core/models/order_model.dart';
import '../../constants/app_color.dart';

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

  final Map<String, Map<String, dynamic>> orderStatus = {
    'pending': {'text': 'Chờ xử lý', 'color': AppColor.accent},
    'processing': {'text': 'Đang xử lý', 'color': AppColor.primary},
    'shipped': {'text': 'Vận chuyển', 'color': Colors.blue},
    'completed': {'text': 'Đã nhận', 'color': Colors.green},
    'cancelled': {'text': 'Đã hủy', 'color': Colors.grey},
  };

  final Map<String, Map<String, dynamic>> paymentStatus = {
    'pending': {'text': 'Chưa thanh toán', 'color': AppColor.accent},
    'paid': {'text': 'Đã thanh toán', 'color': Colors.green},
    'failed': {'text': 'Thanh toán thất bại', 'color': Colors.red},
  };

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    try {
      await AuthService.getToken();
      final detail = await OrderService.getOrderDetail(widget.orderId);
      setState(() {
        orderDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      print("Load failed: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy – HH:mm').format(dt);
  }

  String formatPaymentMethod(String? method) {
    if (method == null) return '—';
    if (method.toLowerCase() == 'cod') return 'COD';
    return method.toUpperCase();
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.secondary,
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColor.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(color: AppColor.secondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(int productId) {
    final _formKey = GlobalKey<FormState>();
    int _rating = 5;
    String _title = '';
    String _content = '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Đánh giá sản phẩm"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Chọn số sao"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Tiêu đề"),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nhập tiêu đề' : null,
                    onSaved: (value) => _title = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Nội dung"),
                    maxLines: 4,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nhập nội dung' : null,
                    onSaved: (value) => _content = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                    await ReviewService.submitReview(
                      productId: productId,
                      rating: _rating,
                      title: _title,
                      content: _content,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Gửi đánh giá thành công. Đánh giá của bạn đang chờ duyệt."),
                      ),
                    );
                  } catch (e) {
                    print("Submit review error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gửi đánh giá thất bại!"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Gửi"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColor.primary)),
      );
    }

    if (orderDetail == null) {
      return const Scaffold(
        body: Center(child: Text('Không thể tải chi tiết đơn hàng')),
      );
    }

    final items = orderDetail!.items;
    final displayItems = showAllItems ? items : items.take(2).toList();

    final statusInfo = orderStatus[orderDetail!.orderStatus] ??
        {'text': 'Không rõ', 'color': Colors.black};

    final paymentInfo = orderDetail!.paymentStatus != null
        ? paymentStatus[orderDetail!.paymentStatus!] ??
            {'text': orderDetail!.paymentStatus!, 'color': Colors.black}
        : null;

    Color _lighterPrimary(double amount) {
      return Color.alphaBlend(
          Colors.white.withOpacity(amount), AppColor.primary);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _lighterPrimary(0.1),
        elevation: 1,
        centerTitle: false,
        title: const Text(
          'Chi tiết đơn hàng',
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
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mã đơn hàng: ${orderDetail!.orderNumber}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ngày đặt: ${formatDate(orderDetail!.orderDate)}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        "Trạng thái: ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        statusInfo['text'],
                        style: TextStyle(
                          color: statusInfo['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= THÔNG TIN GIAO HÀNG =================
            sectionTitle("Thông tin giao hàng"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                children: [
                  if (orderDetail!.recipientName != null)
                    infoRow("Người nhận", orderDetail!.recipientName!),
                  if (orderDetail!.recipientPhone != null)
                    infoRow("SĐT", orderDetail!.recipientPhone!),
                  if (orderDetail!.shippingAddress != null)
                    infoRow("Địa chỉ", orderDetail!.shippingAddress!),
                  if (orderDetail!.shippingWard != null)
                    infoRow("Phường/Xã", orderDetail!.shippingWard!),
                  if (orderDetail!.shippingDistrict != null)
                    infoRow("Quận/Huyện", orderDetail!.shippingDistrict!),
                  if (orderDetail!.shippingProvince != null)
                    infoRow("Tỉnh/TP", orderDetail!.shippingProvince!),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= THANH TOÁN =================
            sectionTitle("Thanh toán"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                children: [
                  infoRow(
                    "Phương thức",
                    formatPaymentMethod(orderDetail!.paymentMethod),
                  ),
                  if (paymentInfo != null)
                    infoRow(
                      "Trạng thái",
                      paymentInfo['text'],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= TỔNG TIỀN =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tổng cộng:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${orderDetail!.totalAmount.toStringAsFixed(0)} ₫",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= SẢN PHẨM =================
            sectionTitle("Sản phẩm trong đơn"),
            ...displayItems.map(
              (item) => Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppColor.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: AppColor.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text("x${item.quantity}",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text(
                        "${item.unitPrice.toStringAsFixed(0)} ₫",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: AppColor.secondary),
                      ),
                      if (orderDetail!.orderStatus == 'completed')
                        IconButton(
                          icon: const Icon(Icons.rate_review, color: AppColor.primary),
                          onPressed: () => _showReviewDialog(item.productId),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            if (items.length > 2)
              TextButton(
                onPressed: () => setState(() => showAllItems = !showAllItems),
                child: Text(
                  showAllItems
                      ? "Thu gọn"
                      : "Xem thêm (${items.length - 2}) sản phẩm",
                  style: const TextStyle(color: AppColor.primary),
                ),
              ),

            const SizedBox(height: 10),

            if (orderDetail!.notes != null && orderDetail!.notes!.isNotEmpty)
              Text("Ghi chú: ${orderDetail!.notes}",
                  style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
