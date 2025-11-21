import 'product_model.dart';

/// ----------------------------
/// 🧩 MODEL: CartItem
/// ----------------------------
class CartItem {
  final int id;
  final int customerId;
  final int variantId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.customerId,
    required this.variantId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      customerId: json['customer_id'],
      variantId: json['variant_id'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'variant_id': variantId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// ----------------------------
/// 🧩 MODEL: CartItemWithProductDetails
/// ----------------------------
class CartItemWithProductDetails {
  final int id;
  final int quantity;
  final CartVariant variant;
  final Product product;

  CartItemWithProductDetails({
    required this.id,
    required this.quantity,
    required this.variant,
    required this.product,
  });

  factory CartItemWithProductDetails.fromJson(Map<String, dynamic> json) {
    return CartItemWithProductDetails(
      id: int.parse(json['id'].toString()),
      quantity: int.parse(json['quantity'].toString()),
      variant: CartVariant.fromJson(json['variant']),
      product: Product.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'variant': variant.toJson(),
      'product': product.toJson(),
    };
  }
}

/// ----------------------------
/// 🧩 MODEL: CartVariant
/// ----------------------------
class CartVariant {
  final int id;
  final String? name;
  final double price;
  final String? image;
  final String? sku;
  final String? weight;

  CartVariant({
    required this.id,
    this.name,
    required this.price,
    this.image,
    this.sku,
    this.weight,
  });

  factory CartVariant.fromJson(Map<String, dynamic> json) {
    return CartVariant(
      id: int.parse(json['id'].toString()), // parse String -> int
      name: json['name'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : double.parse(json['price'].toString()), // parse int/String -> double
      image: json['image'],
      sku: json['sku'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'sku': sku,
      'weight': weight,
    };
  }
}

/// ----------------------------
/// 🧩 MODEL: AddItemInput
/// ----------------------------
class AddItemInput {
  final int customerId;
  final int variantId;
  final int quantity;

  AddItemInput({
    required this.customerId,
    required this.variantId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'variant_id': variantId,
      'quantity': quantity,
    };
  }
}

/// ----------------------------
/// 🧩 MODEL: Cart
/// ----------------------------
class Cart {
  final List<CartItemWithProductDetails> items;
  final double totalAmount;

  Cart({
    required this.items,
    required this.totalAmount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List)
        .map((item) => CartItemWithProductDetails.fromJson(item))
        .toList();

    final totalAmount = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.variant.price * item.quantity),
    );

    return Cart(
      items: items,
      totalAmount: totalAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}
