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
        const SnackBar(content: Text('Voucher áp dụng thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Áp dụng voucher thất bại')),
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

      final createdOrder = await OrderService.createOrder(body);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(order: createdOrder),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán thất bại: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.secondary),
      ),
    );
  }

  Widget priceRow(String label, double value,
      {bool isBold = false, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('${value.toStringAsFixed(0)} ₫',
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }

  Color _lighterPrimary(double amount) {
    // Nhạt màu primary theo % amount (0.0 - 1.0)
    return Color.alphaBlend(Colors.white.withOpacity(amount), AppColor.primary);
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _productsTotal + _shippingFee - _discount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _lighterPrimary(0.1), // nhạt 20%
        elevation: 1,
        centerTitle: false,
        title: const Text(
          'Giỏ hàng',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _addressController.text.isEmpty
                            ? 'Chọn địa chỉ giao hàng'
                            : _addressController.text,
                        style: TextStyle(
                            fontSize: 14,
                            color: _addressController.text.isEmpty
                                ? Colors.grey
                                : Colors.black),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Sản phẩm
            sectionTitle('Sản phẩm trong giỏ'),
            ...cartItems.map(
              (item) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.border),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColor.primarySoft,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (item.variant.image != null &&
                                item.variant.image!.isNotEmpty)
                            ? Image.network(
                                item.variant.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image,
                                        color: AppColor.secondary),
                              )
                            : const Icon(Icons.image,
                                color: AppColor.secondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.secondary)),
                          const SizedBox(height: 4),
                          Text('x${item.quantity}',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.variant.price.toStringAsFixed(0)} ₫',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _updateCartItem(
                                    item.id, item.quantity - 1)),
                            IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _updateCartItem(
                                    item.id, item.quantity + 1)),
                            IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _removeCartItem(item.id)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
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
                          hintText: 'Nhập mã khuyến mãi'),
                    ),
                  ),
                  TextButton(
                      onPressed: _applyVoucher,
                      child: const Text('Áp dụng',
                          style: TextStyle(color: AppColor.primary))),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Ghi chú
            sectionTitle('Ghi chú'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.border)),
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: 'Ghi chú đơn hàng'),
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 16),
            // Tổng tiền
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColor.primarySoft,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  priceRow('Tạm tính', _productsTotal),
                  priceRow('Phí vận chuyển', _shippingFee),
                  if (_discount > 0) priceRow('Giảm giá', -_discount),
                  const Divider(),
                  priceRow('Tổng cộng', subtotal,
                      isBold: true, color: AppColor.primary),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Thanh toán
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkout,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Thanh toán ${subtotal.toStringAsFixed(0)} ₫',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
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
