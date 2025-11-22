// order.dart

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int? variantId;
  final String productName;
  final String? productSku;
  final int quantity;
  final double unitPrice;
  final String? batchNumber;
  final DateTime? expiryDate;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.variantId,
    required this.productName,
    this.productSku,
    required this.quantity,
    required this.unitPrice,
    this.batchNumber,
    this.expiryDate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return OrderItem(
      id: parseInt(json['id']),
      orderId: parseInt(json['order_id']),
      productId: parseInt(json['product_id']),
      variantId: json['variant_id'] != null ? parseInt(json['variant_id']) : null,
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'],
      quantity: parseInt(json['quantity']),
      unitPrice: parseDouble(json['unit_price']),
      batchNumber: json['batch_number'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'variant_id': variantId,
        'product_name': productName,
        'product_sku': productSku,
        'quantity': quantity,
        'unit_price': unitPrice,
        'batch_number': batchNumber,
        'expiry_date': expiryDate?.toIso8601String(),
      };
}

class Order {
  final int id;
  final String orderNumber;
  final int? customerId;
  final DateTime orderDate;
  final String orderStatus;
  final double totalAmount;
  final int? shippingAddressId;
  final String? paymentMethod;
  final String? paymentStatus;

  final String? recipientName;
  final String? recipientPhone;
  final String? accountCustomerName;
  final String? accountCustomerPhone;
  final String? customerEmail;

  final String? shippingAddress;
  final String? shippingProvince;
  final String? shippingDistrict;
  final String? shippingWard;

  final double subtotal;
  final double? shippingFee;
  final double? discountAmount;
  final double? taxAmount;
  final DateTime? requiredDate;
  final int? shippingStatus;
  final String? couponCode;
  final String? notes;
  final String? internalNotes;
  final int? assignedTo;
  final int? confirmedBy;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    this.customerId,
    required this.orderDate,
    required this.orderStatus,
    required this.totalAmount,
    this.shippingAddressId,
    this.paymentMethod,
    this.paymentStatus,
    this.recipientName,
    this.recipientPhone,
    this.accountCustomerName,
    this.accountCustomerPhone,
    this.customerEmail,
    this.shippingAddress,
    this.shippingProvince,
    this.shippingDistrict,
    this.shippingWard,
    required this.subtotal,
    this.shippingFee,
    this.discountAmount,
    this.taxAmount,
    this.requiredDate,
    this.shippingStatus,
    this.couponCode,
    this.notes,
    this.internalNotes,
    this.assignedTo,
    this.confirmedBy,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelReason,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return Order(
      id: parseInt(json['id']),
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer_id'] != null ? parseInt(json['customer_id']) : null,
      orderDate: parseDate(json['order_date']) ?? DateTime.now(),
      orderStatus: json['order_status'] ?? '',
      totalAmount: parseDouble(json['total_amount']),
      shippingAddressId: json['shipping_address_id'] != null ? parseInt(json['shipping_address_id']) : null,
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      accountCustomerName: json['account_customer_name'],
      accountCustomerPhone: json['account_customer_phone'],
      customerEmail: json['customer_email'],
      shippingAddress: json['shipping_address'],
      shippingProvince: json['shipping_province'],
      shippingDistrict: json['shipping_district'],
      shippingWard: json['shipping_ward'],
      subtotal: parseDouble(json['subtotal']) != 0.0 ? parseDouble(json['subtotal']) : parseDouble(json['total_amount']),
      shippingFee: json['shipping_fee'] != null ? parseDouble(json['shipping_fee']) : null,
      discountAmount: json['discount_amount'] != null ? parseDouble(json['discount_amount']) : null,
      taxAmount: json['tax_amount'] != null ? parseDouble(json['tax_amount']) : null,
      requiredDate: parseDate(json['required_date']),
      shippingStatus: json['shipping_status'] != null ? parseInt(json['shipping_status']) : null,
      couponCode: json['coupon_code'],
      notes: json['notes'],
      internalNotes: json['internal_notes'],
      assignedTo: json['assigned_to'] != null ? parseInt(json['assigned_to']) : null,
      confirmedBy: json['confirmed_by'] != null ? parseInt(json['confirmed_by']) : null,
      confirmedAt: parseDate(json['confirmed_at']),
      shippedAt: parseDate(json['shipped_at']),
      deliveredAt: parseDate(json['delivered_at']),
      cancelledAt: parseDate(json['cancelled_at']),
      cancelReason: json['cancel_reason'],
      createdBy: json['created_by'] != null ? parseInt(json['created_by']) : null,
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? []).map((e) => OrderItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'customer_id': customerId,
        'order_date': orderDate.toIso8601String(),
        'order_status': orderStatus,
        'total_amount': totalAmount,
        'shipping_address_id': shippingAddressId,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'account_customer_name': accountCustomerName,
        'account_customer_phone': accountCustomerPhone,
        'customer_email': customerEmail,
        'shipping_address': shippingAddress,
        'shipping_province': shippingProvince,
        'shipping_district': shippingDistrict,
        'shipping_ward': shippingWard,
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'discount_amount': discountAmount,
        'tax_amount': taxAmount,
        'required_date': requiredDate?.toIso8601String(),
        'shipping_status': shippingStatus,
        'coupon_code': couponCode,
        'notes': notes,
        'internal_notes': internalNotes,
        'assigned_to': assignedTo,
        'confirmed_by': confirmedBy,
        'confirmed_at': confirmedAt?.toIso8601String(),
        'shipped_at': shippedAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
        'cancel_reason': cancelReason,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderStatusHistory {
  final int id;
  final int orderId;
  final String? fromStatus;
  final String toStatus;
  final String? notes;
  final int? changedBy;
  final DateTime createdAt;

  OrderStatusHistory({
    required this.id,
    required this.orderId,
    this.fromStatus,
    required this.toStatus,
    this.notes,
    this.changedBy,
    required this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return OrderStatusHistory(
      id: parseInt(json['id']),
      orderId: parseInt(json['order_id']),
      fromStatus: json['from_status'],
      toStatus: json['to_status'] ?? '',
      notes: json['notes'],
      changedBy: json['changed_by'] != null ? parseInt(json['changed_by']) : null,
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'from_status': fromStatus,
        'to_status': toStatus,
        'notes': notes,
        'changed_by': changedBy,
        'created_at': createdAt.toIso8601String(),
      };
}

class Payment {
  final int id;
  final int orderId;
  final String paymentMethod;
  final double amount;
  final String? transactionId;
  final String? gateway;
  final String status;
  final DateTime? paymentDate;
  final String? notes;

  Payment({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    this.transactionId,
    this.gateway,
    required this.status,
    this.paymentDate,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return Payment(
      id: parseInt(json['id']),
      orderId: parseInt(json['order_id']),
      paymentMethod: json['payment_method'] ?? '',
      amount: parseDouble(json['amount']),
      transactionId: json['transaction_id'],
      gateway: json['gateway'],
      status: json['status'] ?? 'pending',
      paymentDate: parseDate(json['payment_date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'payment_method': paymentMethod,
        'amount': amount,
        'transaction_id': transactionId,
        'gateway': gateway,
        'status': status,
        'payment_date': paymentDate?.toIso8601String(),
        'notes': notes,
      };
}
