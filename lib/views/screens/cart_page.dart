import 'package:flutter/material.dart';
import 'package:marketky/core/models/cart_model.dart';
import 'package:marketky/core/models/order_model.dart';
import 'package:marketky/core/models/address_model.dart';
import 'package:marketky/core/services/cart_service.dart';
import 'package:marketky/core/services/order_service.dart';
import 'package:marketky/core/services/address_service.dart';
import 'package:marketky/views/screens/my_order_page.dart';
import '../widgets/cart_tile.dart';
import '../screens/address_page.dart';
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
    setState(() {});
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

      if (defaultAddr != null) {
        setState(() {
          selectedAddress = defaultAddr;
          _addressController.text = _formatAddress(defaultAddr);
        });
        _calculateShippingFee();
      }
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
        const SnackBar(content: Text('Voucher applied successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply voucher')),
      );
    }
  }

  void _updateCartItem(int cartItemId, int newQuantity) async {
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
        const SnackBar(content: Text('Failed to update quantity')),
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
        const SnackBar(content: Text('Failed to remove item')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _productsTotal + _shippingFee - _discount;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Địa chỉ giao hàng
            Text('Địa chỉ giao hàng:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 5,
                        offset: const Offset(0, 2)),
                  ],
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
            Text('Sản phẩm trong giỏ hàng:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: CartTile(
                    data: item,
                    onQuantityChanged: (newQuantity) =>
                        _updateCartItem(item.id, newQuantity),
                    onRemove: () => _removeCartItem(item.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Nhập voucher
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _voucherController,
                decoration: InputDecoration(
                  hintText: 'Mã khuyến mãi',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, color: Colors.pink),
                    onPressed: _applyVoucher,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phương thức thanh toán
            Text('Phương thức thanh toán:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'COD',
                      groupValue: _paymentMethod,
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value!),
                      title: const Text('COD'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'MOMO',
                      groupValue: _paymentMethod,
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value!),
                      title: const Text('Ví MOMO'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ghi chú
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 16),

            // Tổng cộng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 5,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildPriceRow('Tạm tính', _productsTotal),
                  _buildPriceRow('Phí giao hàng', _shippingFee),
                  if (_discount > 0) _buildPriceRow('Giảm giá', -_discount),
                  const Divider(),
                  _buildPriceRow('Tổng cộng', subtotal,
                      isBold: true, color: Colors.pink),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nút thanh toán full-width
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyOrdersPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Thanh toán ${subtotal.toStringAsFixed(0)} ₫',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isBold = false, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('${amount.toStringAsFixed(0)} ₫',
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
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
