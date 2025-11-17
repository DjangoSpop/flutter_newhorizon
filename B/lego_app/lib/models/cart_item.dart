import 'package:uuid/uuid.dart';

/// CartItem represents a product in the shopping cart with quantity and variations
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final double? discountedPrice;
  int quantity;
  final String? size;
  final String? color;
  final String? sku;
  final int maxStock;
  final bool inStock;
  final DateTime addedAt;

  CartItem({
    String? id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    this.discountedPrice,
    this.quantity = 1,
    this.size,
    this.color,
    this.sku,
    this.maxStock = 999,
    this.inStock = true,
    DateTime? addedAt,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  /// Get the effective price (discounted or regular)
  double get effectivePrice => discountedPrice ?? price;

  /// Calculate total price for this cart item
  double get totalPrice => effectivePrice * quantity;

  /// Calculate total savings if discounted
  double get totalSavings {
    if (discountedPrice == null) return 0.0;
    return (price - discountedPrice!) * quantity;
  }

  /// Check if this item is the same product with same variations
  bool isSameProduct(CartItem other) {
    return productId == other.productId &&
           size == other.size &&
           color == other.color;
  }

  /// Create a unique key for this cart item based on product and variations
  String get uniqueKey {
    return '$productId-${size ?? 'nosize'}-${color ?? 'nocolor'}';
  }

  /// Check if quantity can be increased
  bool get canIncreaseQuantity => quantity < maxStock;

  /// Check if quantity can be decreased
  bool get canDecreaseQuantity => quantity > 1;

  /// Serialize to JSON for storage
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
      'max_stock': maxStock,
      'in_stock': inStock,
      'added_at': addedAt.toIso8601String(),
    };
  }

  /// Deserialize from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String?,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      quantity: json['quantity'] as int? ?? 1,
      size: json['size'] as String?,
      color: json['color'] as String?,
      sku: json['sku'] as String?,
      maxStock: json['max_stock'] as int? ?? 999,
      inStock: json['in_stock'] as bool? ?? true,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  CartItem copyWith({
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
    int? maxStock,
    bool? inStock,
    DateTime? addedAt,
  }) {
    return CartItem(
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
      maxStock: maxStock ?? this.maxStock,
      inStock: inStock ?? this.inStock,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CartItem{id: $id, productName: $productName, quantity: $quantity, price: \$${effectivePrice.toStringAsFixed(2)}}';
  }
}
