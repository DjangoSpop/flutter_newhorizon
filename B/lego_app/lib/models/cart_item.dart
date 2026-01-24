import 'package:uuid/uuid.dart';
import 'product.dart';

/// Represents an item in the shopping cart
class CartItem {
  String id;
  String productId;
  Product product;
  int quantity;
  String? selectedSize;
  String? selectedColor;
  double unitPrice;
  double subtotal;
  DateTime addedAt;
  DateTime? updatedAt;

  CartItem({
    String? id,
    required this.productId,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    required this.unitPrice,
    DateTime? addedAt,
    this.updatedAt,
  })  : this.id = id ?? Uuid().v4(),
        this.addedAt = addedAt ?? DateTime.now(),
        this.subtotal = unitPrice * quantity;

  /// Calculate subtotal based on current quantity and price
  void calculateSubtotal() {
    subtotal = unitPrice * quantity;
  }

  /// Update quantity and recalculate subtotal
  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
    updatedAt = DateTime.now();
    calculateSubtotal();
  }

  /// Get effective price (discounted if available)
  double get effectivePrice {
    return product.discountedPrice > 0 && product.discountedPrice < product.price
        ? product.discountedPrice
        : product.price;
  }

  /// Check if product has discount
  bool get hasDiscount {
    return product.discountedPrice > 0 && product.discountedPrice < product.price;
  }

  /// Get discount amount
  double get discountAmount {
    if (hasDiscount) {
      return (product.price - product.discountedPrice) * quantity;
    }
    return 0.0;
  }

  /// Get discount percentage
  double get discountPercentage {
    if (hasDiscount) {
      return ((product.price - product.discountedPrice) / product.price) * 100;
    }
    return 0.0;
  }

  /// Create from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'] ?? json['product_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      selectedSize: json['selectedSize'] ?? json['selected_size'],
      selectedColor: json['selectedColor'] ?? json['selected_color'],
      unitPrice: (json['unitPrice'] ?? json['unit_price']).toDouble(),
      addedAt: json['addedAt'] != null || json['added_at'] != null
          ? DateTime.parse(json['addedAt'] ?? json['added_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for API (snake_case)
  Map<String, dynamic> toApiJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
    };
  }

  /// Create a copy with updated fields
  CartItem copyWith({
    String? id,
    String? productId,
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    double? unitPrice,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      unitPrice: unitPrice ?? this.unitPrice,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, product: ${product.name}, quantity: $quantity, '
        'size: $selectedSize, color: $selectedColor, subtotal: $subtotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.productId == productId &&
        other.selectedSize == selectedSize &&
        other.selectedColor == selectedColor;
  }

  @override
  int get hashCode {
    return productId.hashCode ^ selectedSize.hashCode ^ selectedColor.hashCode;
  }
}

/// Cart summary information
class CartSummary {
  List<CartItem> items;
  double subtotal;
  double tax;
  double shipping;
  double discount;
  double total;
  int totalItems;

  CartSummary({
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.shipping = 0.0,
    this.discount = 0.0,
    required this.total,
    required this.totalItems,
  });

  /// Calculate cart summary from list of cart items
  factory CartSummary.fromCartItems({
    required List<CartItem> items,
    double taxRate = 0.0,
    double shippingCost = 0.0,
    double discountAmount = 0.0,
  }) {
    double subtotal = items.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    double tax = subtotal * taxRate;
    double total = subtotal + tax + shippingCost - discountAmount;

    int totalItems = items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    return CartSummary(
      items: items,
      subtotal: subtotal,
      tax: tax,
      shipping: shippingCost,
      discount: discountAmount,
      total: total,
      totalItems: totalItems,
    );
  }

  /// Get total savings from discounts
  double get totalSavings {
    return items.fold(
      0.0,
      (sum, item) => sum + item.discountAmount,
    ) + discount;
  }

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;
}
