import 'package:flutter/material.dart';
import 'package:marketky/core/services/cart_service.dart';

class CartHelper {
  /// 🔹 ValueNotifier để thông báo số lượng giỏ hàng thay đổi
  static final ValueNotifier<int> cartItemCount = ValueNotifier<int>(0);

  /// 🔹 Khởi tạo CartHelper, load số lượng ban đầu
  static Future<void> init() async {
    await updateCount();
  }

  /// 🔹 Cập nhật số lượng giỏ hàng từ CartService
  static Future<void> updateCount() async {
    try {
      final cart = await CartService.getCart();
      cartItemCount.value = cart?.items.length ?? 0;
    } catch (e) {
      cartItemCount.value = 0;
      print("CartHelper.updateCount error: $e");
    }
  }

  /// 🔹 Thêm 1 sản phẩm vào giỏ hàng và cập nhật số lượng
  static Future<void> addItem({
    required int customerId,
    required int variantId,
    required int quantity,
  }) async {
    try {
      final success = await CartService.addItemToCart(
        customerId: customerId,
        variantId: variantId,
        quantity: quantity,
      );
      if (success) await updateCount();
    } catch (e) {
      print("CartHelper.addItem error: $e");
    }
  }

  /// 🔹 Xóa 1 sản phẩm trong giỏ hàng và cập nhật số lượng
  static Future<void> removeItem(int cartItemId) async {
    try {
      final success = await CartService.removeItemFromCart(cartItemId);
      if (success) await updateCount();
    } catch (e) {
      print("CartHelper.removeItem error: $e");
    }
  }

  /// 🔹 Xóa toàn bộ giỏ hàng và cập nhật số lượng
  static Future<void> clearCart() async {
    try {
      final success = await CartService.clearCart();
      if (success) await updateCount();
    } catch (e) {
      print("CartHelper.clearCart error: $e");
    }
  }

  /// 🔹 Lấy ValueListenable để dùng trong ValueListenableBuilder
  static ValueNotifier<int> getNotifier() => cartItemCount;

  /// 🔹 Làm mới số lượng giỏ hàng (dùng khi quay lại trang)
  static Future<void> refresh() async {
    await updateCount();
  }
}
