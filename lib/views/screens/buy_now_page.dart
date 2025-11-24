// import 'package:flutter/material.dart';
// import 'package:marketky/core/models/cart_model.dart';
// import 'package:marketky/core/models/address_model.dart';
// import 'package:marketky/core/services/order_service.dart';
// import 'package:marketky/core/services/address_service.dart';
// import 'package:marketky/views/screens/order_success_page.dart';
// import 'package:marketky/views/screens/address_page.dart';
// import 'package:marketky/constants/app_color.dart';

// class BuyNowPage extends StatefulWidget {
//   final CartItemWithProductDetails item; // sản phẩm mua ngay
//   const BuyNowPage({Key? key, required this.item}) : super(key: key);

//   @override
//   _BuyNowPageState createState() => _BuyNowPageState();
// }

// class _BuyNowPageState extends State<BuyNowPage> {
//   late int _quantity;
//   double _productsTotal = 0.0;
//   double _shippingFee = 0.0;
//   double _discount = 0.0;
//   String _paymentMethod = 'COD';
//   bool _isLoading = false;

//   Address? selectedAddress;
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//   final TextEditingController _voucherController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _quantity = widget.item.quantity;
//     _calculateProductsTotal();
//     _loadDefaultAddress();
//   }

//   void _calculateProductsTotal() {
//     _productsTotal = _quantity * widget.item.variant.price;
//   }

//   Future<void> _calculateShippingFee() async {
//     if (selectedAddress == null) return;

//     try {
//       final carrierCode = 'ghn';
//       final toDistrictId = int.parse(selectedAddress!.districtCode ?? '0');
//       final toWardCode = selectedAddress!.wardCode ?? '';
//       final weight = widget.item.variant.weight != null
//           ? (double.tryParse(widget.item.variant.weight!)?.toInt() ?? 500)
//           : 500;

//       final items = [
//         {
//           'quantity': _quantity,
//           'weight': weight,
//           'price': widget.item.variant.price,
//         }
//       ];

//       final fee = await OrderService.calculateShippingFee(
//         carrierCode: carrierCode,
//         toDistrictId: toDistrictId,
//         toWardCode: toWardCode,
//         items: items,
//       );

//       setState(() {
//         _shippingFee = fee;
//       });
//     } catch (e) {
//       setState(() {
//         _shippingFee = 0.0;
//       });
//       print('Lỗi tính phí vận chuyển: $e');
//     }
//   }

//   void _loadDefaultAddress() async {
//     try {
//       final addresses = await AddressService.getAddresses();
//       if (addresses.isEmpty) return;

//       final defaultAddr = addresses.firstWhere((addr) => addr.isDefault,
//           orElse: () => addresses[0]);

//       setState(() {
//         selectedAddress = defaultAddr;
//         _addressController.text = _formatAddress(defaultAddr);
//       });

//       _calculateShippingFee();
//     } catch (e) {
//       print('Không load được địa chỉ: $e');
//     }
//   }

//   String _formatAddress(Address addr) {
//     return '${addr.address}, ${addr.wardName ?? ''}, ${addr.districtName ?? ''}, ${addr.provinceName ?? ''}';
//   }

//   void _applyVoucher() async {
//     try {
//       final discount = await OrderService.applyVoucher(_voucherController.text);
//       setState(() {
//         _discount = discount;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Voucher áp dụng thành công!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Áp dụng voucher thất bại')),
//       );
//     }
//   }

//   Future<void> _checkout() async {
//     if (selectedAddress == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final items = [
//         {
//           "product_id": widget.item.product.id,
//           "variant_id": widget.item.variant.id,
//           "quantity": _quantity,
//         }
//       ];

//       final shippingOption = {
//         "fee": _shippingFee.toInt(),
//         "service_id": 53321,
//         "service_type_id": 2,
//       };

//       final body = {
//         "addressId": selectedAddress!.id,
//         "shippingOption": shippingOption,
//         "paymentMethod": _paymentMethod.toLowerCase(),
//         "notes": _noteController.text,
//         "items": items, // chỉ gửi sản phẩm mua ngay
//       };

//       // Gọi API /orders chung, nhưng chỉ có sản phẩm mua ngay
//       final createdOrder = await OrderService.createOrder(body);

//       if (!mounted) return;

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => OrderSuccessPage(order: createdOrder),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Thanh toán thất bại: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget sectionTitle(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: AppColor.secondary),
//       ),
//     );
//   }

//   Widget priceRow(String label, double value,
//       {bool isBold = false, Color color = Colors.black}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: TextStyle(
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//           Text('${value.toStringAsFixed(0)} ₫',
//               style: TextStyle(
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                   color: color)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final subtotal = _productsTotal + _shippingFee - _discount;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Mua ngay',
//           style: TextStyle(color: AppColor.secondary),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         iconTheme: const IconThemeData(color: AppColor.secondary),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             sectionTitle('Địa chỉ giao hàng'),
//             GestureDetector(
//               onTap: () async {
//                 final result = await Navigator.push<Address>(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => AddressPage(selectMode: true)),
//                 );
//                 if (result != null) {
//                   setState(() {
//                     selectedAddress = result;
//                     _addressController.text = _formatAddress(result);
//                   });
//                   _calculateShippingFee();
//                 }
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColor.border),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         _addressController.text.isEmpty
//                             ? 'Chọn địa chỉ giao hàng'
//                             : _addressController.text,
//                         style: TextStyle(
//                             fontSize: 14,
//                             color: _addressController.text.isEmpty
//                                 ? Colors.grey
//                                 : Colors.black),
//                       ),
//                     ),
//                     const Icon(Icons.arrow_drop_down, color: Colors.grey)
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//             sectionTitle('Sản phẩm'),
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColor.border),
//               ),
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 55,
//                     height: 55,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: AppColor.primarySoft,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: (widget.item.variant.image != null &&
//                               widget.item.variant.image!.isNotEmpty)
//                           ? Image.network(
//                               widget.item.variant.image!,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const Icon(Icons.image,
//                                       color: AppColor.secondary),
//                             )
//                           : const Icon(Icons.image, color: AppColor.secondary),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(widget.item.product.name,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColor.secondary)),
//                         const SizedBox(height: 4),
//                         Text('x$_quantity',
//                             style: const TextStyle(color: Colors.grey)),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text('${widget.item.variant.price.toStringAsFixed(0)} ₫',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: AppColor.secondary)),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           IconButton(
//                               icon: const Icon(Icons.remove_circle_outline),
//                               onPressed: () {
//                                 if (_quantity > 1) {
//                                   setState(() {
//                                     _quantity--;
//                                     _calculateProductsTotal();
//                                     _calculateShippingFee();
//                                   });
//                                 }
//                               }),
//                           IconButton(
//                               icon: const Icon(Icons.add_circle_outline),
//                               onPressed: () {
//                                 setState(() {
//                                   _quantity++;
//                                   _calculateProductsTotal();
//                                   _calculateShippingFee();
//                                 });
//                               }),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),
//             sectionTitle('Mã khuyến mãi'),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColor.border)),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _voucherController,
//                       decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           hintText: 'Nhập mã khuyến mãi'),
//                     ),
//                   ),
//                   TextButton(
//                       onPressed: _applyVoucher,
//                       child: const Text('Áp dụng',
//                           style: TextStyle(color: AppColor.primary))),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),
//             sectionTitle('Ghi chú'),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColor.border)),
//               child: TextField(
//                 controller: _noteController,
//                 decoration: const InputDecoration(
//                     border: InputBorder.none, hintText: 'Ghi chú đơn hàng'),
//                 maxLines: 3,
//               ),
//             ),

//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                   color: AppColor.primarySoft,
//                   borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 children: [
//                   priceRow('Tạm tính', _productsTotal),
//                   priceRow('Phí vận chuyển', _shippingFee),
//                   if (_discount > 0) priceRow('Giảm giá', -_discount),
//                   const Divider(),
//                   priceRow('Tổng cộng', subtotal,
//                       isBold: true, color: AppColor.primary),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _checkout,
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColor.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50))),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : Text('Thanh toán ${subtotal.toStringAsFixed(0)} ₫',
//                         style:
//                             const TextStyle(fontSize: 16, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
