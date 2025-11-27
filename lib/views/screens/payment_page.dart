// // Thêm debug log để kiểm tra MoMo payment

// import 'package:flutter/material.dart';
// import 'package:marketky/constants/app_color.dart';
// import 'package:marketky/core/services/order_service.dart';
// import 'dart:convert';

// class PaymentPage extends StatefulWidget {
//   final int orderId;
//   final double totalAmount;
//   final String paymentMethod;

//   const PaymentPage({
//     Key? key,
//     required this.orderId,
//     required this.totalAmount,
//     required this.paymentMethod,
//   }) : super(key: key);

//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   String? momoQrUrl;
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initiateMoMoPayment();
//   }

//   Future<void> _initiateMoMoPayment() async {
//     print('===== MOMO PAYMENT INITIATION =====');
//     print('Order ID: ${widget.orderId}');
//     print('Total Amount: ${widget.totalAmount}');
//     print('Payment Method: ${widget.paymentMethod}');

//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = null;
//       });

//       // Gọi API tạo payment
//       final response = await OrderService.createOrder(
//         orderId: widget.orderId,
//         amount: widget.totalAmount.toInt(),
//       );

//       print('===== MOMO API RESPONSE =====');
//       print('Response: $response');
//       print('Response Type: ${response.runtimeType}');
//       print('==============================');

//       if (response != null) {
//         // Kiểm tra response có QR URL không
//         String? qrUrl;

//         if (response is Map<String, dynamic>) {
//           print('Response is Map');
//           print('Keys: ${response.keys.toList()}');

//           // Thử các key khác nhau
//           qrUrl = response['qrCodeUrl'] ??
//               response['qr_code_url'] ??
//               response['qr'] ??
//               response['url'] ??
//               response['paymentUrl'] ??
//               response['payment_url'];

//           print('Extracted QR URL: $qrUrl');

//           // In toàn bộ response
//           print('Full Response: ${jsonEncode(response)}');
//         } else if (response is String) {
//           print('Response is String: $response');
//           qrUrl = response;
//         }

//         if (qrUrl != null && qrUrl.isNotEmpty) {
//           print('MoMo QR URL found: $qrUrl');
//           setState(() {
//             momoQrUrl = qrUrl;
//             isLoading = false;
//           });
//         } else {
//           print('ERROR: QR URL is null or empty');
//           setState(() {
//             errorMessage = 'Không lấy được mã QR từ MoMo';
//             isLoading = false;
//           });
//         }
//       } else {
//         print('ERROR: API response is null');
//         setState(() {
//           errorMessage = 'Không thể kết nối với MoMo';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('EXCEPTION in MoMo Payment: $e');
//       print('Stack trace: ${StackTrace.current}');

//       setState(() {
//         errorMessage = 'Lỗi: ${e.toString()}';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColor.primary.withOpacity(0.08),
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'Thanh toán MoMo',
//           style: TextStyle(
//             color: AppColor.primary,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: const Icon(Icons.arrow_back, color: AppColor.primary),
//         ),
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: AppColor.primary),
//             )
//           : errorMessage != null
//               ? Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.error_outline,
//                             size: 64, color: Colors.red.withOpacity(0.6)),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Lỗi thanh toán',
//                           style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                               color: AppColor.secondary),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           errorMessage!,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: AppColor.secondary.withOpacity(0.7),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: _initiateMoMoPayment,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColor.primary,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 32, vertical: 12),
//                           ),
//                           child: const Text(
//                             'Thử lại',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : momoQrUrl != null
//                   ? Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Text(
//                               'Quét mã QR để thanh toán',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColor.secondary,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: AppColor.border, width: 2),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Image.network(
//                                 momoQrUrl!,
//                                 width: 300,
//                                 height: 300,
//                                 fit: BoxFit.contain,
//                                 errorBuilder:
//                                     (context, error, stackTrace) {
//                                   print('ERROR loading QR image: $error');
//                                   return Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(Icons.broken_image,
//                                           size: 64,
//                                           color: AppColor.primary
//                                               .withOpacity(0.5)),
//                                       const SizedBox(height: 8),
//                                       const Text(
//                                         'Không thể tải QR code',
//                                         style: TextStyle(
//                                             color: AppColor.secondary),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'URL: $momoQrUrl',
//                                         style: TextStyle(
//                                             fontSize: 10,
//                                             color: AppColor.secondary
//                                                 .withOpacity(0.6)),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             Container(
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: AppColor.primarySoft,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: AppColor.border),
//                               ),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Số tiền thanh toán:',
//                                         style: TextStyle(
//                                           color: AppColor.secondary,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       Text(
//                                         '${widget.totalAmount.toStringAsFixed(0)} ₫',
//                                         style: const TextStyle(
//                                           color: AppColor.primary,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Mã đơn hàng:',
//                                         style: TextStyle(
//                                           color: AppColor.secondary,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       Text(
//                                         '#${widget.orderId}',
//                                         style: const TextStyle(
//                                           color: AppColor.primary,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   : Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.warning_amber_rounded,
//                               size: 64,
//                               color: AppColor.primary.withOpacity(0.5)),
//                           const SizedBox(height: 12),
//                           const Text(
//                             'Không lấy được mã QR',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: AppColor.secondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//     );
//   }
// }