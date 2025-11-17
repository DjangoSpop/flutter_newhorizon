import 'package:uuid/uuid.dart';

/// Order status enum representing the lifecycle of an order
enum OrderStatus {
  PENDING,
  CONFIRMED,
  PROCESSING,
  SHIPPED,
  DELIVERED,
  CANCELLED,
  REFUNDED,
  FAILED
}

/// Payment status enum
enum PaymentStatus {
  PENDING,
  PAID,
  FAILED,
  REFUNDED,
  PARTIALLY_REFUNDED
}

/// Payment method enum
enum PaymentMethod {
  CREDIT_CARD,
  DEBIT_CARD,
  PAYPAL,
  STRIPE,
  CASH_ON_DELIVERY,
  BANK_TRANSFER,
  MOBILE_PAYMENT
}

/// Shipping method enum
enum ShippingMethod {
  STANDARD,
  EXPRESS,
  OVERNIGHT,
  INTERNATIONAL,
  PICKUP
}

/// Extension methods for OrderStatus
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.PENDING:
        return 'Pending';
      case OrderStatus.CONFIRMED:
        return 'Confirmed';
      case OrderStatus.PROCESSING:
        return 'Processing';
      case OrderStatus.SHIPPED:
        return 'Shipped';
      case OrderStatus.DELIVERED:
        return 'Delivered';
      case OrderStatus.CANCELLED:
        return 'Cancelled';
      case OrderStatus.REFUNDED:
        return 'Refunded';
      case OrderStatus.FAILED:
        return 'Failed';
    }
  }

  String get apiValue {
    return toString().split('.').last;
  }

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == status.toUpperCase(),
      orElse: () => OrderStatus.PENDING,
    );
  }

  /// Returns true if the order can be cancelled
  bool get canBeCancelled {
    return this == OrderStatus.PENDING ||
           this == OrderStatus.CONFIRMED;
  }

  /// Returns true if the order is in a final state
  bool get isFinal {
    return this == OrderStatus.DELIVERED ||
           this == OrderStatus.CANCELLED ||
           this == OrderStatus.REFUNDED ||
           this == OrderStatus.FAILED;
  }

  /// Returns true if the order is active
  bool get isActive {
    return !isFinal;
  }
}

/// Extension methods for PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.PENDING:
        return 'Pending';
      case PaymentStatus.PAID:
        return 'Paid';
      case PaymentStatus.FAILED:
        return 'Failed';
      case PaymentStatus.REFUNDED:
        return 'Refunded';
      case PaymentStatus.PARTIALLY_REFUNDED:
        return 'Partially Refunded';
    }
  }

  String get apiValue {
    return toString().split('.').last;
  }

  static PaymentStatus fromString(String status) {
    return PaymentStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == status.toUpperCase(),
      orElse: () => PaymentStatus.PENDING,
    );
  }
}

/// Extension methods for PaymentMethod
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.CREDIT_CARD:
        return 'Credit Card';
      case PaymentMethod.DEBIT_CARD:
        return 'Debit Card';
      case PaymentMethod.PAYPAL:
        return 'PayPal';
      case PaymentMethod.STRIPE:
        return 'Stripe';
      case PaymentMethod.CASH_ON_DELIVERY:
        return 'Cash on Delivery';
      case PaymentMethod.BANK_TRANSFER:
        return 'Bank Transfer';
      case PaymentMethod.MOBILE_PAYMENT:
        return 'Mobile Payment';
    }
  }

  String get apiValue {
    return toString().split('.').last;
  }

  static PaymentMethod fromString(String method) {
    return PaymentMethod.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == method.toUpperCase(),
      orElse: () => PaymentMethod.CASH_ON_DELIVERY,
    );
  }
}

/// Extension methods for ShippingMethod
extension ShippingMethodExtension on ShippingMethod {
  String get displayName {
    switch (this) {
      case ShippingMethod.STANDARD:
        return 'Standard Shipping';
      case ShippingMethod.EXPRESS:
        return 'Express Shipping';
      case ShippingMethod.OVERNIGHT:
        return 'Overnight Shipping';
      case ShippingMethod.INTERNATIONAL:
        return 'International Shipping';
      case ShippingMethod.PICKUP:
        return 'Store Pickup';
    }
  }

  String get apiValue {
    return toString().split('.').last;
  }

  static ShippingMethod fromString(String method) {
    return ShippingMethod.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == method.toUpperCase(),
      orElse: () => ShippingMethod.STANDARD,
    );
  }

  /// Estimated delivery days based on shipping method
  int get estimatedDays {
    switch (this) {
      case ShippingMethod.STANDARD:
        return 7;
      case ShippingMethod.EXPRESS:
        return 3;
      case ShippingMethod.OVERNIGHT:
        return 1;
      case ShippingMethod.INTERNATIONAL:
        return 14;
      case ShippingMethod.PICKUP:
        return 0;
    }
  }

  /// Shipping cost multiplier
  double get costMultiplier {
    switch (this) {
      case ShippingMethod.STANDARD:
        return 1.0;
      case ShippingMethod.EXPRESS:
        return 2.0;
      case ShippingMethod.OVERNIGHT:
        return 3.5;
      case ShippingMethod.INTERNATIONAL:
        return 5.0;
      case ShippingMethod.PICKUP:
        return 0.0;
    }
  }
}

/// Order tracking event model
class OrderTrackingEvent {
  final String id;
  final OrderStatus status;
  final String description;
  final String? location;
  final DateTime timestamp;
  final String? updatedBy;

  OrderTrackingEvent({
    String? id,
    required this.status,
    required this.description,
    this.location,
    required this.timestamp,
    this.updatedBy,
  }) : id = id ?? const Uuid().v4();

  factory OrderTrackingEvent.fromJson(Map<String, dynamic> json) {
    return OrderTrackingEvent(
      id: json['id'] as String?,
      status: OrderStatusExtension.fromString(json['status'] as String),
      description: json['description'] as String,
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      updatedBy: json['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.apiValue,
      'description': description,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  OrderTrackingEvent copyWith({
    String? id,
    OrderStatus? status,
    String? description,
    String? location,
    DateTime? timestamp,
    String? updatedBy,
  }) {
    return OrderTrackingEvent(
      id: id ?? this.id,
      status: status ?? this.status,
      description: description ?? this.description,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Shipping address model
class ShippingAddress {
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final String? email;

  ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    this.email,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['full_name'] as String,
      addressLine1: json['address_line_1'] as String,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'phone_number': phoneNumber,
      'email': email,
    };
  }

  /// Get formatted address as a single string
  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }

  ShippingAddress copyWith({
    String? fullName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phoneNumber,
    String? email,
  }) {
    return ShippingAddress(
      fullName: fullName ?? this.fullName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

/// Order item model representing a product in an order
class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final double? discountedPrice;
  final int quantity;
  final String? size;
  final String? color;
  final String? sku;

  OrderItem({
    String? id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    this.discountedPrice,
    required this.quantity,
    this.size,
    this.color,
    this.sku,
  }) : id = id ?? const Uuid().v4();

  /// Calculate total price for this item
  double get totalPrice {
    final itemPrice = discountedPrice ?? price;
    return itemPrice * quantity;
  }

  /// Get the effective price (discounted or regular)
  double get effectivePrice {
    return discountedPrice ?? price;
  }

  /// Calculate total savings if discounted
  double get totalSavings {
    if (discountedPrice == null) return 0.0;
    return (price - discountedPrice!) * quantity;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String?,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      quantity: json['quantity'] as int,
      size: json['size'] as String?,
      color: json['color'] as String?,
      sku: json['sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'discounted_price': discountedPrice,
      'quantity': quantity,
      'size': size,
      'color': color,
      'sku': sku,
    };
  }

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? discountedPrice,
    int? quantity,
    String? size,
    String? color,
    String? sku,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      sku: sku ?? this.sku,
    );
  }
}

/// Main Order model representing a complete order
class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final String? userName;
  final String? userEmail;
  final List<OrderItem> items;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final ShippingMethod shippingMethod;
  final ShippingAddress shippingAddress;
  final ShippingAddress? billingAddress;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double discount;
  final double total;
  final String? promoCode;
  final String? notes;
  final String? trackingNumber;
  final String? carrierName;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? estimatedDeliveryDate;
  final List<OrderTrackingEvent> trackingEvents;
  final Map<String, dynamic>? metadata;

  Order({
    String? id,
    String? orderNumber,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.items,
    this.status = OrderStatus.PENDING,
    this.paymentStatus = PaymentStatus.PENDING,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.shippingAddress,
    this.billingAddress,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    this.discount = 0.0,
    required this.total,
    this.promoCode,
    this.notes,
    this.trackingNumber,
    this.carrierName,
    DateTime? createdAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.estimatedDeliveryDate,
    List<OrderTrackingEvent>? trackingEvents,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        orderNumber = orderNumber ?? _generateOrderNumber(),
        createdAt = createdAt ?? DateTime.now(),
        trackingEvents = trackingEvents ?? [];

  /// Generate a unique order number
  static String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
  }

  /// Calculate total items in the order
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get total savings from discounts
  double get totalSavings {
    final itemSavings = items.fold(0.0, (sum, item) => sum + item.totalSavings);
    return itemSavings + discount;
  }

  /// Check if order can be cancelled
  bool get canBeCancelled {
    return status.canBeCancelled && paymentStatus != PaymentStatus.REFUNDED;
  }

  /// Check if order can be tracked
  bool get canBeTracked {
    return trackingNumber != null &&
           trackingNumber!.isNotEmpty &&
           (status == OrderStatus.SHIPPED || status == OrderStatus.PROCESSING);
  }

  /// Get the latest tracking event
  OrderTrackingEvent? get latestTrackingEvent {
    if (trackingEvents.isEmpty) return null;
    return trackingEvents.reduce((a, b) =>
      a.timestamp.isAfter(b.timestamp) ? a : b
    );
  }

  /// Get estimated delivery date if not set
  DateTime? get effectiveEstimatedDeliveryDate {
    if (estimatedDeliveryDate != null) return estimatedDeliveryDate;
    if (shippedAt != null) {
      return shippedAt!.add(Duration(days: shippingMethod.estimatedDays));
    }
    if (confirmedAt != null) {
      return confirmedAt!.add(Duration(days: shippingMethod.estimatedDays + 2));
    }
    return createdAt.add(Duration(days: shippingMethod.estimatedDays + 4));
  }

  /// Check if order is delayed
  bool get isDelayed {
    final estimatedDate = effectiveEstimatedDeliveryDate;
    if (estimatedDate == null) return false;
    if (status == OrderStatus.DELIVERED) return false;
    return DateTime.now().isAfter(estimatedDate);
  }

  /// Get order age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String?,
      orderNumber: json['order_number'] as String?,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: OrderStatusExtension.fromString(json['status'] as String? ?? 'PENDING'),
      paymentStatus: PaymentStatusExtension.fromString(
          json['payment_status'] as String? ?? 'PENDING'),
      paymentMethod: PaymentMethodExtension.fromString(
          json['payment_method'] as String? ?? 'CASH_ON_DELIVERY'),
      shippingMethod: ShippingMethodExtension.fromString(
          json['shipping_method'] as String? ?? 'STANDARD'),
      shippingAddress: ShippingAddress.fromJson(
          json['shipping_address'] as Map<String, dynamic>),
      billingAddress: json['billing_address'] != null
          ? ShippingAddress.fromJson(json['billing_address'] as Map<String, dynamic>)
          : null,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0,
      total: (json['total'] as num).toDouble(),
      promoCode: json['promo_code'] as String?,
      notes: json['notes'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      carrierName: json['carrier_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'] as String)
          : null,
      trackingEvents: (json['tracking_events'] as List?)
              ?.map((event) =>
                  OrderTrackingEvent.fromJson(event as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.apiValue,
      'payment_status': paymentStatus.apiValue,
      'payment_method': paymentMethod.apiValue,
      'shipping_method': shippingMethod.apiValue,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress?.toJson(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping_cost': shippingCost,
      'discount': discount,
      'total': total,
      'promo_code': promoCode,
      'notes': notes,
      'tracking_number': trackingNumber,
      'carrier_name': carrierName,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
      'tracking_events': trackingEvents.map((event) => event.toJson()).toList(),
      'metadata': metadata,
    };
  }

  Order copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? userName,
    String? userEmail,
    List<OrderItem>? items,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    ShippingMethod? shippingMethod,
    ShippingAddress? shippingAddress,
    ShippingAddress? billingAddress,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? discount,
    double? total,
    String? promoCode,
    String? notes,
    String? trackingNumber,
    String? carrierName,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    DateTime? estimatedDeliveryDate,
    List<OrderTrackingEvent>? trackingEvents,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      items: items ?? this.items,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      promoCode: promoCode ?? this.promoCode,
      notes: notes ?? this.notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrierName: carrierName ?? this.carrierName,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      trackingEvents: trackingEvents ?? this.trackingEvents,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Order{orderNumber: $orderNumber, status: ${status.displayName}, total: \$$total, items: ${items.length}}';
  }
}
