import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marketky/core/models/cart_model.dart';
import 'package:marketky/core/models/address_model.dart';
import 'package:marketky/core/services/cart_service.dart';
import 'package:marketky/core/services/order_service.dart';
import 'package:marketky/core/services/address_service.dart';
import 'package:marketky/views/screens/order_success_page.dart';
import 'package:marketky/views/screens/address_page.dart';
import 'package:marketky/constants/app_color.dart';
import 'package:marketky/views/screens/momo_payment_page.dart';

class CartPage extends StatefulWidget {
  final List<CartItemWithProductDetails> initialCartItems;
  const CartPage({Key? key, required this.initialCartItems}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItemWithProductDetails> cartItems = [];
  double _productsTotal = 0.0;
  double _shippingFee = 0.0;
  double _discount = 0.0;
  String _paymentMethod = 'COD';
  bool _isLoading = false;

  Address? selectedAddress;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.initialCartItems);
    _calculateProductsTotal();
    _loadDefaultAddress();
  }

  void _calculateProductsTotal() {
    _productsTotal = cartItems.fold(
        0.0, (sum, item) => sum + item.quantity * item.variant.price);
  }

  void _calculateShippingFee() async {
    if (selectedAddress == null) return;

    try {
      final carrierCode = 'ghn';
      final toDistrictId = int.parse(selectedAddress!.districtCode ?? '0');
      final toWardCode = selectedAddress!.wardCode ?? '';
      final items = cartItems.map((item) {
        return {
          'quantity': item.quantity,
          'weight': item.variant.weight ?? 500,
          'price': item.variant.price,
        };
      }).toList();

      final fee = await OrderService.calculateShippingFee(
        carrierCode: carrierCode,
        toDistrictId: toDistrictId,
        toWardCode: toWardCode,
        items: items,
      );

      setState(() {
        _shippingFee = fee;
      });
    } catch (e) {
      setState(() {
        _shippingFee = 0.0;
      });
    }
  }

  void _loadDefaultAddress() async {
    try {
      final addresses = await AddressService.getAddresses();
      if (addresses.isEmpty) return;

      final defaultAddr = addresses.firstWhere((addr) => addr.isDefault,
          orElse: () => addresses[0]);

      setState(() {
        selectedAddress = defaultAddr;
        _addressController.text = _formatAddress(defaultAddr);
      });
      _calculateShippingFee();
    } catch (e) {
      print('Cannot load addresses: $e');
    }
  }

  String _formatAddress(Address addr) {
    return '${addr.address}, ${addr.wardName ?? ''}, ${addr.districtName ?? ''}, ${addr.provinceName ?? ''}';
  }

  void _applyVoucher() async {
    try {
      final discount = await OrderService.applyVoucher(_voucherController.text);
      setState(() {
        _discount = discount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher áp dụng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Áp dụng voucher thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateCartItem(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) return;
    final success = await CartService.updateItemQuantity(
      cartItemId: cartItemId,
      quantity: newQuantity,
    );

    if (success) {
      setState(() {
        final index = cartItems.indexWhere((item) => item.id == cartItemId);
        if (index != -1) {
          cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
          _calculateProductsTotal();
          _calculateShippingFee();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật số lượng thất bại')),
      );
    }
  }

  void _removeCartItem(int cartItemId) async {
    final success = await CartService.removeItemFromCart(cartItemId);
    if (success) {
      setState(() {
        cartItems.removeWhere((item) => item.id == cartItemId);
        _calculateProductsTotal();
        _calculateShippingFee();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa sản phẩm thất bại')),
      );
    }
  }

  Future<void> _checkout() async {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
      );
      return;
    }

    // Nếu payment method là momo => yêu cầu xác nhận trước khi gửi đơn
    if ((_paymentMethod ?? '').toString().toLowerCase() == 'momo') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận thanh toán'),
          content: const Text(
            'Bạn sẽ được chuyển tới trang thanh toán MoMo. '
            'Nếu bạn hủy thanh toán, đơn sẽ không được gửi.\n\n'
            'Bạn có muốn tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        // Người dùng hủy => không gửi đơn
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final items = cartItems
          .map((item) => {
                "product_id": item.product.id,
                "variant_id": item.variant.id,
                "quantity": item.quantity,
              })
          .toList();

      final shippingOption = {
        "fee": _shippingFee.toInt(),
        "service_id": 53321,
        "service_type_id": 2,
      };

      final body = {
        "addressId": selectedAddress!.id,
        "shippingOption": shippingOption,
        "paymentMethod": _paymentMethod.toLowerCase(),
        "notes": _noteController.text,
        "items": items,
      };

      print('===== CREATE ORDER =====');
      print('Payment Method: $_paymentMethod');
      print(body);

      final createdOrder = await OrderService.createOrder(body);

      print('===== ORDER RESPONSE =====');
      print(createdOrder);

      if (!mounted) return;

      if (_paymentMethod.toLowerCase() == 'momo' &&
          createdOrder['paymentUrl'] != null) {
        final paymentUrl = createdOrder['paymentUrl'];
        final orderId = createdOrder['order']['id'];
        final totalAmount =
            double.parse(createdOrder['order']['total_amount'].toString());

        print('Redirecting to MoMo: $paymentUrl');

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MoMoPaymentPage(
              orderId: int.parse(orderId.toString()),
              totalAmount: totalAmount,
              momoQrUrl: paymentUrl,
            ),
          ),
        );
        return;
      }

      // COD hoặc fallback
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            order: createdOrder['order'] as Map<String, dynamic>,
          ),
        ),
      );
    } catch (e) {
      print('Checkout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán thất bại: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkOrderPayment(int orderId) async {
    try {
      final order = await OrderService.getOrderById(orderId);
      if (order.paymentStatus == 'paid' || order.paymentStatus == 'completed') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order.toJson())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa thanh toán. Vui lòng thử lại sau vài phút.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi kiểm tra: $e')),
      );
    }
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColor.secondary),
      ),
    );
  }

  Widget priceRow(String label, double value,
      {bool isBold = false, Color color = AppColor.secondary}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: AppColor.secondary,
                  fontSize: isBold ? 15 : 14)),
          Text('${value.toStringAsFixed(0)} ₫',
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                  fontSize: isBold ? 15 : 14)),
        ],
      ),
    );
  }

  Widget paymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Phương thức thanh toán'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _paymentMethod = 'COD'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _paymentMethod == 'COD'
                  ? AppColor.primary.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _paymentMethod == 'COD'
                    ? AppColor.primary
                    : AppColor.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'COD'
                        ? AppColor.primary
                        : AppColor.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delivery_dining,
                      color: _paymentMethod == 'COD'
                          ? Colors.white
                          : AppColor.primary,
                      size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thanh toán khi nhận (COD)',
                        style: TextStyle(
                          color: _paymentMethod == 'COD'
                              ? AppColor.primary
                              : AppColor.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Thanh toán tại nhà khi nhân hàng',
                        style: TextStyle(
                          color: AppColor.secondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'COD',
                  groupValue: _paymentMethod,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                  activeColor: AppColor.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _paymentMethod = 'MOMO'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _paymentMethod == 'MOMO'
                  ? AppColor.primary.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _paymentMethod == 'MOMO'
                    ? AppColor.primary
                    : AppColor.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'MOMO'
                        ? AppColor.primary
                        : AppColor.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.account_balance_wallet,
                      color: _paymentMethod == 'MOMO'
                          ? Colors.white
                          : AppColor.primary,
                      size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thanh toán MoMo',
                        style: TextStyle(
                          color: _paymentMethod == 'MOMO'
                              ? AppColor.primary
                              : AppColor.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Thanh toán qua ví MoMo',
                        style: TextStyle(
                          color: AppColor.secondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'MOMO',
                  groupValue: _paymentMethod,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                  activeColor: AppColor.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final subtotal = _productsTotal + _shippingFee - _discount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Giỏ hàng",
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColor.primary),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: AppColor.primarySoft),
                  const SizedBox(height: 16),
                  Text(
                    'Giỏ hàng của bạn trống',
                    style: TextStyle(
                        color: AppColor.secondary.withOpacity(0.8),
                        fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Địa chỉ
                  sectionTitle('Địa chỉ giao hàng'),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<Address>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddressPage(selectMode: true)),
                      );
                      if (result != null) {
                        setState(() {
                          selectedAddress = result;
                          _addressController.text = _formatAddress(result);
                        });
                        _calculateShippingFee();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.border),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6)
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: AppColor.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _addressController.text.isEmpty
                                  ? 'Chọn địa chỉ giao hàng'
                                  : _addressController.text,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: _addressController.text.isEmpty
                                      ? Colors.grey
                                      : AppColor.secondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: AppColor.primary, size: 16)
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  // Sản phẩm
                  sectionTitle('Sản phẩm trong giỏ (${cartItems.length})'),
                  ...cartItems.map(
                    (item) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.border),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6)
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.primarySoft,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (() {
                                final variantImage = item.variant.image;
                                final galleryProduct = item.product.images;
                                final hasVariantImage = variantImage != null &&
                                    variantImage.isNotEmpty;
                                final hasGallery = galleryProduct != null &&
                                    galleryProduct.gallery.isNotEmpty;

                                if (hasVariantImage) {
                                  return Image.network(
                                    variantImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                color: AppColor.secondary),
                                  );
                                } else if (hasGallery) {
                                  return Image.network(
                                    galleryProduct.gallery[0],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                color: AppColor.secondary),
                                  );
                                } else {
                                  return const Icon(Icons.image,
                                      color: AppColor.secondary);
                                }
                              })(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.variant.name.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.secondary,
                                        fontSize: 14)),
                                const SizedBox(height: 6),
                                Text(
                                    '${item.variant.price.toStringAsFixed(0)} ₫',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.primary,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _updateCartItem(
                                        item.id, item.quantity - 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColor.primarySoft,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.remove,
                                          color: AppColor.primary, size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _updateCartItem(
                                        item.id, item.quantity + 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColor.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _removeCartItem(item.id),
                                child: const Text('Xóa',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  // Voucher
                  sectionTitle('Mã khuyến mãi'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.border)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voucherController,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nhập mã khuyến mãi',
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          ),
                        ),
                        TextButton(
                            onPressed: _applyVoucher,
                            child: const Text('Áp dụng',
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),

                  // Phương thức thanh toán
                  const SizedBox(height: 18),
                  paymentMethodSection(),

                  // Ghi chú
                  const SizedBox(height: 18),
                  sectionTitle('Ghi chú'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.border)),
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ghi chú đơn hàng...',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                      maxLines: 3,
                    ),
                  ),

                  const SizedBox(height: 18),
                  // Tổng tiền
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColor.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.border)),
                    child: Column(
                      children: [
                        priceRow('Tạm tính', _productsTotal),
                        priceRow('Phí vận chuyển', _shippingFee),
                        if (_discount > 0)
                          priceRow('Giảm giá', -_discount, color: Colors.red),
                        const Divider(color: AppColor.border),
                        priceRow('Tổng cộng', subtotal,
                            isBold: true, color: AppColor.primary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  // Thanh toán
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          disabledBackgroundColor:
                              AppColor.primary.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Thanh toán ${subtotal.toStringAsFixed(0)} ₫',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }
}

extension CartItemCopy on CartItemWithProductDetails {
  CartItemWithProductDetails copyWith({int? quantity}) {
    return CartItemWithProductDetails(
      id: id,
      product: product,
      variant: variant,
      quantity: quantity ?? this.quantity,
    );
  }
}
