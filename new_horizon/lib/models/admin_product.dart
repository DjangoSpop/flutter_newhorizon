/// Admin product management models
class ProductInventory {
  final String productId;
  final String productName;
  final String sku;
  final int totalStock;
  final int availableStock;
  final int reservedStock;
  final int soldStock;
  final int lowStockThreshold;
  final bool isLowStock;
  final bool isOutOfStock;
  final DateTime? lastRestocked;
  final List<VariantInventory> variants;

  ProductInventory({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.totalStock,
    required this.availableStock,
    required this.reservedStock,
    required this.soldStock,
    required this.lowStockThreshold,
    required this.isLowStock,
    required this.isOutOfStock,
    this.lastRestocked,
    this.variants = const [],
  });

  factory ProductInventory.fromJson(Map<String, dynamic> json) {
    return ProductInventory(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      sku: json['sku'] ?? '',
      totalStock: json['total_stock'] ?? 0,
      availableStock: json['available_stock'] ?? 0,
      reservedStock: json['reserved_stock'] ?? 0,
      soldStock: json['sold_stock'] ?? 0,
      lowStockThreshold: json['low_stock_threshold'] ?? 10,
      isLowStock: json['is_low_stock'] ?? false,
      isOutOfStock: json['is_out_of_stock'] ?? false,
      lastRestocked: json['last_restocked'] != null
          ? DateTime.parse(json['last_restocked'])
          : null,
      variants: (json['variants'] as List?)
              ?.map((v) => VariantInventory.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'total_stock': totalStock,
      'available_stock': availableStock,
      'reserved_stock': reservedStock,
      'sold_stock': soldStock,
      'low_stock_threshold': lowStockThreshold,
      'is_low_stock': isLowStock,
      'is_out_of_stock': isOutOfStock,
      'last_restocked': lastRestocked?.toIso8601String(),
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }

  double get stockTurnoverRate {
    if (totalStock == 0) return 0;
    return soldStock / totalStock;
  }

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}

class VariantInventory {
  final String variantId;
  final String size;
  final String? color;
  final int stock;
  final String sku;

  VariantInventory({
    required this.variantId,
    required this.size,
    this.color,
    required this.stock,
    required this.sku,
  });

  factory VariantInventory.fromJson(Map<String, dynamic> json) {
    return VariantInventory(
      variantId: json['variant_id'] ?? '',
      size: json['size'] ?? '',
      color: json['color'],
      stock: json['stock'] ?? 0,
      sku: json['sku'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'size': size,
      'color': color,
      'stock': stock,
      'sku': sku,
    };
  }
}

class BulkOperation {
  final String id;
  final BulkOperationType type;
  final int totalItems;
  final int processedItems;
  final int successfulItems;
  final int failedItems;
  final BulkOperationStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> errors;
  final String? fileUrl;

  BulkOperation({
    required this.id,
    required this.type,
    required this.totalItems,
    this.processedItems = 0,
    this.successfulItems = 0,
    this.failedItems = 0,
    this.status = BulkOperationStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.errors = const [],
    this.fileUrl,
  });

  factory BulkOperation.fromJson(Map<String, dynamic> json) {
    return BulkOperation(
      id: json['id'] ?? '',
      type: BulkOperationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => BulkOperationType.import_,
      ),
      totalItems: json['total_items'] ?? 0,
      processedItems: json['processed_items'] ?? 0,
      successfulItems: json['successful_items'] ?? 0,
      failedItems: json['failed_items'] ?? 0,
      status: BulkOperationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BulkOperationStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : [],
      fileUrl: json['file_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'total_items': totalItems,
      'processed_items': processedItems,
      'successful_items': successfulItems,
      'failed_items': failedItems,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'errors': errors,
      'file_url': fileUrl,
    };
  }

  double get progress {
    if (totalItems == 0) return 0;
    return processedItems / totalItems;
  }

  bool get isComplete => status == BulkOperationStatus.completed;
  bool get isProcessing => status == BulkOperationStatus.processing;
  bool get hasFailed => status == BulkOperationStatus.failed;
  bool get hasErrors => errors.isNotEmpty || failedItems > 0;
}

enum BulkOperationType {
  import_,
  export,
  update,
  delete,
  priceUpdate,
  stockUpdate,
}

enum BulkOperationStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class ProductCategory {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final String? parentId;
  final int productCount;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.parentId,
    this.productCount = 0,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      parentId: json['parent_id'],
      productCount: json['product_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image_url': imageUrl,
      'parent_id': parentId,
      'product_count': productCount,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isSubcategory => parentId != null;
}

class ProductAnalytics {
  final String productId;
  final int views;
  final int cartAdds;
  final int purchases;
  final int wishlistAdds;
  final double conversionRate;
  final double averageRating;
  final int reviewCount;
  final double revenue;
  final DateTime periodStart;
  final DateTime periodEnd;

  ProductAnalytics({
    required this.productId,
    this.views = 0,
    this.cartAdds = 0,
    this.purchases = 0,
    this.wishlistAdds = 0,
    this.conversionRate = 0.0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.revenue = 0.0,
    required this.periodStart,
    required this.periodEnd,
  });

  factory ProductAnalytics.fromJson(Map<String, dynamic> json) {
    return ProductAnalytics(
      productId: json['product_id'] ?? '',
      views: json['views'] ?? 0,
      cartAdds: json['cart_adds'] ?? 0,
      purchases: json['purchases'] ?? 0,
      wishlistAdds: json['wishlist_adds'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0).toDouble(),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'views': views,
      'cart_adds': cartAdds,
      'purchases': purchases,
      'wishlist_adds': wishlistAdds,
      'conversion_rate': conversionRate,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'revenue': revenue,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  double get cartConversionRate {
    if (cartAdds == 0) return 0;
    return (purchases / cartAdds) * 100;
  }

  double get wishlistConversionRate {
    if (wishlistAdds == 0) return 0;
    return (purchases / wishlistAdds) * 100;
  }
}

class StockAdjustment {
  final String id;
  final String productId;
  final String? variantId;
  final int quantityBefore;
  final int quantityAfter;
  final int adjustment;
  final StockAdjustmentReason reason;
  final String? notes;
  final String? performedBy;
  final DateTime createdAt;

  StockAdjustment({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.adjustment,
    required this.reason,
    this.notes,
    this.performedBy,
    required this.createdAt,
  });

  factory StockAdjustment.fromJson(Map<String, dynamic> json) {
    return StockAdjustment(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      variantId: json['variant_id'],
      quantityBefore: json['quantity_before'] ?? 0,
      quantityAfter: json['quantity_after'] ?? 0,
      adjustment: json['adjustment'] ?? 0,
      reason: StockAdjustmentReason.values.firstWhere(
        (e) => e.toString().split('.').last == json['reason'],
        orElse: () => StockAdjustmentReason.manual,
      ),
      notes: json['notes'],
      performedBy: json['performed_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'variant_id': variantId,
      'quantity_before': quantityBefore,
      'quantity_after': quantityAfter,
      'adjustment': adjustment,
      'reason': reason.toString().split('.').last,
      'notes': notes,
      'performed_by': performedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isIncrease => adjustment > 0;
  bool get isDecrease => adjustment < 0;
}

enum StockAdjustmentReason {
  manual,
  restock,
  sale,
  return_,
  damaged,
  lost,
  correction,
  transfer,
}
