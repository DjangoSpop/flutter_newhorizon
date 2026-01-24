import 'package:uuid/uuid.dart';
import 'product.dart';

/// Wishlist item model
class WishlistItem {
  String id;
  String userId;
  String productId;
  Product product;
  DateTime addedAt;
  String? notes;

  WishlistItem({
    String? id,
    required this.userId,
    required this.productId,
    required this.product,
    DateTime? addedAt,
    this.notes,
  })  : this.id = id ?? Uuid().v4(),
        this.addedAt = addedAt ?? DateTime.now();

  /// Check if product is in stock
  bool get isInStock => product.inStock;

  /// Check if product has discount
  bool get hasDiscount {
    return product.discountedPrice > 0 &&
        product.discountedPrice < product.price;
  }

  /// Get discount percentage
  double get discountPercentage {
    if (hasDiscount) {
      return ((product.price - product.discountedPrice) / product.price) * 100;
    }
    return 0.0;
  }

  /// Get effective price
  double get effectivePrice {
    return hasDiscount ? product.discountedPrice : product.price;
  }

  /// Create from JSON
  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      productId: json['productId'] ?? json['product_id'],
      product: Product.fromJson(json['product']),
      addedAt: json['addedAt'] != null || json['added_at'] != null
          ? DateTime.parse(json['addedAt'] ?? json['added_at'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'product': product.toJson(),
      'addedAt': addedAt.toIso8601String(),
      'notes': notes,
    };
  }

  /// Convert to API JSON (snake_case)
  Map<String, dynamic> toApiJson() {
    return {
      'product_id': productId,
      'notes': notes,
    };
  }

  /// Create a copy with updated fields
  WishlistItem copyWith({
    Product? product,
    String? notes,
  }) {
    return WishlistItem(
      id: id,
      userId: userId,
      productId: productId,
      product: product ?? this.product,
      addedAt: addedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistItem &&
        other.userId == userId &&
        other.productId == productId;
  }

  @override
  int get hashCode => userId.hashCode ^ productId.hashCode;
}
