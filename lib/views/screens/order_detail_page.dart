import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/order_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/review_service.dart';
import '../../core/services/product_service.dart';
import '../../core/models/order_model.dart';
import '../../core/models/product_model.dart';
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
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    bool _submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Đánh giá sản phẩm',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final index = i + 1;
                        return IconButton(
                          iconSize: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          icon: Icon(
                            index <= _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () => setState(() => _rating = index),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Tiêu đề',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Nhập tiêu đề' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'Nội dung đánh giá',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            maxLines: 4,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Nhập nội dung'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitting
                            ? null
                            : () async {
                                if (!(_formKey.currentState?.validate() ?? false)) {
                                  return;
                                }
                                setState(() => _submitting = true);
                                try {
                                  await ReviewService.submitReview(
                                    productId: productId,
                                    rating: _rating,
                                    title: _titleController.text.trim(),
                                    content: _contentController.text.trim(),
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gửi đánh giá thành công.'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gửi đánh giá thất bại.'),
                                    ),
                                  );
                                } finally {
                                  // nếu vẫn mở (nếu có lỗi), cho phép gửi lại
                                  if (mounted) setState(() => _submitting = false);
                                }
                              },
                        child: _submitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Gửi đánh giá'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget productImageWidget(Product product, int? variantId) {
  String? img;

  if (variantId != null && product.variants != null) {
    ProductVariant? variant;
    try {
      variant = product.variants!.firstWhere((v) => v.id == variantId);
    } catch (e) {
      variant = null; // Không tìm thấy thì gán null
    }

    if (variant != null && variant.image != null && variant.image!.isNotEmpty) {
      img = variant.image;
    }
  }

  if (img == null && product.images != null) {
    if (product.images!.gallery.isNotEmpty) {
      img = product.images!.gallery[0];
    } else if (product.images!.thumbnail != null &&
        product.images!.thumbnail!.isNotEmpty) {
      img = product.images!.thumbnail;
    }
  }

  if (img == null || img.isEmpty) {
    return const Icon(Icons.image, color: AppColor.secondary);
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      img,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: AppColor.secondary),
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
        backgroundColor: _lighterPrimary(0.06),
        elevation: 0,
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(color: AppColor.primary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColor.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Đơn #${orderDetail!.orderNumber}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColor.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Ngày đặt: ${formatDate(orderDetail!.orderDate)}",
                          style: TextStyle(color: AppColor.secondary.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (statusInfo['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusInfo['text'],
                            style: TextStyle(color: statusInfo['color'] as Color, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Shipping info
            sectionTitle("Thông tin giao hàng"),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.border),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (orderDetail!.recipientName != null)
                    infoRow("Người nhận", orderDetail!.recipientName!),
                  if (orderDetail!.shippingAddress != null)
                    infoRow("Địa chỉ", orderDetail!.shippingAddress!),
                  if (orderDetail!.shippingWard != null)
                    infoRow("Phường/Xã", orderDetail!.shippingWard!),
                  if (orderDetail!.shippingDistrict != null)
                    infoRow("Quận/Huyện", orderDetail!.shippingDistrict!),
                  if (orderDetail!.shippingProvince != null)
                    infoRow("Tỉnh/TP", orderDetail!.shippingProvince!),
                  infoRow(
                    "Ghi chú",
                    orderDetail!.notes != null && orderDetail!.notes!.isNotEmpty
                        ? orderDetail!.notes!
                        : "Vui lòng gọi điện trước khi giao hàng",
                    valueStyle: TextStyle(color: AppColor.secondary.withOpacity(0.9)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Payment info
            sectionTitle("Thanh toán"),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                children: [
                  infoRow("Phương thức", formatPaymentMethod(orderDetail!.paymentMethod)),
                  if (paymentInfo != null)
                    infoRow("Trạng thái", paymentInfo['text'], valueStyle: TextStyle(color: (paymentInfo['color'] as Color))),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng cộng", style: TextStyle(fontWeight: FontWeight.w700)),
                  Text("${orderDetail!.totalAmount.toStringAsFixed(0)} ₫",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColor.primary)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Products
            sectionTitle("Sản phẩm trong đơn"),
            Column(
              children: displayItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.border),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColor.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FutureBuilder<Product?>(
                          future: ProductService.getProductById(item.productId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              // fallback to order item image if available
                              if (item.image != null && item.image!.isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(item.image!, fit: BoxFit.cover, width: 64, height: 64),
                                );
                              }
                              return const Center(child: Icon(Icons.broken_image, color: AppColor.secondary));
                            }
                            final product = snapshot.data!;
                            return ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 64, height: 64, child: productImageWidget(product, item.variantId)));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            
                            
                            Row(
                              children: [
                                Text("Số lượng: ${item.quantity}", style: TextStyle(color: AppColor.secondary.withOpacity(0.8))),
                                const SizedBox(width: 12),
                                Text("${item.unitPrice.toStringAsFixed(0)} ₫", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColor.secondary)),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (orderDetail!.orderStatus == 'completed')
                        IconButton(
                          icon: const Icon(Icons.rate_review, color: AppColor.primary),
                          onPressed: () => _showReviewDialog(item.productId),
                          tooltip: 'Đánh giá',
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            if (items.length > 2)
              TextButton(
                onPressed: () => setState(() => showAllItems = !showAllItems),
                child: Text(
                  showAllItems ? "Thu gọn" : "Xem thêm (${items.length - 2}) sản phẩm",
                  style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.w700),
                ),
              ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
