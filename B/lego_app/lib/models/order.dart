import 'package:uuid/uuid.dart';
import 'cart_item.dart';
import 'address.dart';
import 'payment_method.dart';

/// Order model representing a customer purchase
class Order {
  String id;
  String userId;
  String orderNumber;
  List<OrderItem> items;
  OrderStatus status;

  // Pricing
  double subtotal;
  double tax;
  double shipping;
  double discount;
  double total;

  // Addresses
  Address shippingAddress;
  Address? billingAddress;

  // Payment
  PaymentMethod? paymentMethod;
  String? paymentIntentId;
  PaymentStatus paymentStatus;

  // Shipping
  String? shippingMethod;
  String? trackingNumber;
  String? carrier;
  DateTime? estimatedDelivery;
  DateTime? actualDelivery;

  // Metadata
  String? notes;
  String? promoCode;
  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? cancelledAt;
  String? cancellationReason;

  Order({
    String? id,
    required this.userId,
    String? orderNumber,
    required this.items,
    this.status = OrderStatus.pending,
    required this.subtotal,
    this.tax = 0.0,
    this.shipping = 0.0,
    this.discount = 0.0,
    required this.total,
    required this.shippingAddress,
    this.billingAddress,
    this.paymentMethod,
    this.paymentIntentId,
    this.paymentStatus = PaymentStatus.pending,
    this.shippingMethod,
    this.trackingNumber,
    this.carrier,
    this.estimatedDelivery,
    this.actualDelivery,
    this.notes,
    this.promoCode,
    DateTime? createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
  })  : this.id = id ?? Uuid().v4(),
        this.orderNumber = orderNumber ?? _generateOrderNumber(),
        this.createdAt = createdAt ?? DateTime.now();

  /// Generate a unique order number
  static String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD-${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  /// Get total number of items
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if order can be cancelled
  bool get canBeCancelled {
    return status == OrderStatus.pending ||
        status == OrderStatus.confirmed ||
        status == OrderStatus.processing;
  }

  /// Check if order is completed
  bool get isCompleted {
    return status == OrderStatus.delivered;
  }

  /// Check if order is cancelled
  bool get isCancelled {
    return status == OrderStatus.cancelled ||
        status == OrderStatus.refunded;
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return 'warning';
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return 'info';
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return 'primary';
      case OrderStatus.delivered:
        return 'success';
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
      case OrderStatus.failed:
        return 'error';
      default:
        return 'default';
    }
  }

  /// Create from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      orderNumber: json['orderNumber'] ?? json['order_number'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax']?.toDouble() ?? 0.0,
      shipping: json['shipping']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble() ?? 0.0,
      total: json['total'].toDouble(),
      shippingAddress: Address.fromJson(
        json['shippingAddress'] ?? json['shipping_address'],
      ),
      billingAddress: json['billingAddress'] != null ||
              json['billing_address'] != null
          ? Address.fromJson(
              json['billingAddress'] ?? json['billing_address'])
          : null,
      paymentMethod: json['paymentMethod'] != null ||
              json['payment_method'] != null
          ? PaymentMethod.fromJson(
              json['paymentMethod'] ?? json['payment_method'])
          : null,
      paymentIntentId: json['paymentIntentId'] ?? json['payment_intent_id'],
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['paymentStatus'] ?? json['payment_status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      shippingMethod: json['shippingMethod'] ?? json['shipping_method'],
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      carrier: json['carrier'],
      estimatedDelivery: json['estimatedDelivery'] != null ||
              json['estimated_delivery'] != null
          ? DateTime.parse(
              json['estimatedDelivery'] ?? json['estimated_delivery'])
          : null,
      actualDelivery: json['actualDelivery'] != null ||
              json['actual_delivery'] != null
          ? DateTime.parse(json['actualDelivery'] ?? json['actual_delivery'])
          : null,
      notes: json['notes'],
      promoCode: json['promoCode'] ?? json['promo_code'],
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
      cancelledAt: json['cancelledAt'] != null || json['cancelled_at'] != null
          ? DateTime.parse(json['cancelledAt'] ?? json['cancelled_at'])
          : null,
      cancellationReason:
          json['cancellationReason'] ?? json['cancellation_reason'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.toString().split('.').last,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'shippingAddress': shippingAddress.toJson(),
      'billingAddress': billingAddress?.toJson(),
      'paymentMethod': paymentMethod?.toJson(),
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'shippingMethod': shippingMethod,
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'notes': notes,
      'promoCode': promoCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  /// Create a copy with updated fields
  Order copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? trackingNumber,
    String? carrier,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    String? notes,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Order(
      id: id,
      userId: userId,
      orderNumber: orderNumber,
      items: items,
      status: status ?? this.status,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      discount: discount,
      total: total,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      paymentMethod: paymentMethod,
      paymentIntentId: paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingMethod: shippingMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrier: carrier ?? this.carrier,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      notes: notes ?? this.notes,
      promoCode: promoCode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

/// Order item (product in an order)
class OrderItem {
  String id;
  String productId;
  String productName;
  String? productImage;
  int quantity;
  String? selectedSize;
  String? selectedColor;
  double unitPrice;
  double subtotal;

  OrderItem({
    String? id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    required this.unitPrice,
    required this.subtotal,
  }) : this.id = id ?? Uuid().v4();

  /// Create from cart item
  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.productId,
      productName: cartItem.product.name,
      productImage: cartItem.product.imagePaths.isNotEmpty
          ? cartItem.product.imagePaths.first
          : null,
      quantity: cartItem.quantity,
      selectedSize: cartItem.selectedSize,
      selectedColor: cartItem.selectedColor,
      unitPrice: cartItem.unitPrice,
      subtotal: cartItem.subtotal,
    );
  }

  /// Create from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'] ?? json['product_id'],
      productName: json['productName'] ?? json['product_name'],
      productImage: json['productImage'] ?? json['product_image'],
      quantity: json['quantity'],
      selectedSize: json['selectedSize'] ?? json['selected_size'],
      selectedColor: json['selectedColor'] ?? json['selected_color'],
      unitPrice: json['unitPrice']?.toDouble() ?? json['unit_price']?.toDouble(),
      subtotal: json['subtotal'].toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }
}

/// Order status enum
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
  failed,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  succeeded,
  failed,
  refunded,
  cancelled,
}
