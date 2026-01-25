/// Promotion model for managing discounts and offers
class Promotion {
  final String id;
  final String code;
  final String title;
  final String description;
  final PromotionType type;
  final double discountValue;
  final DiscountType discountType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final int usageCount;
  final List<String>? applicableCategories;
  final List<String>? applicableProducts;
  final List<String>? excludedProducts;
  final bool isFirstOrderOnly;
  final bool isNewCustomersOnly;
  final String? imageUrl;
  final String? bannerUrl;
  final int priority;

  Promotion({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.discountValue,
    required this.discountType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    this.usageCount = 0,
    this.applicableCategories,
    this.applicableProducts,
    this.excludedProducts,
    this.isFirstOrderOnly = false,
    this.isNewCustomersOnly = false,
    this.imageUrl,
    this.bannerUrl,
    this.priority = 0,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: PromotionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PromotionType.couponCode,
      ),
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      discountType: DiscountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['discount_type'],
        orElse: () => DiscountType.percentage,
      ),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? false,
      minPurchaseAmount: json['min_purchase_amount']?.toDouble(),
      maxDiscountAmount: json['max_discount_amount']?.toDouble(),
      usageLimit: json['usage_limit'],
      usageCount: json['usage_count'] ?? 0,
      applicableCategories: json['applicable_categories'] != null
          ? List<String>.from(json['applicable_categories'])
          : null,
      applicableProducts: json['applicable_products'] != null
          ? List<String>.from(json['applicable_products'])
          : null,
      excludedProducts: json['excluded_products'] != null
          ? List<String>.from(json['excluded_products'])
          : null,
      isFirstOrderOnly: json['is_first_order_only'] ?? false,
      isNewCustomersOnly: json['is_new_customers_only'] ?? false,
      imageUrl: json['image_url'],
      bannerUrl: json['banner_url'],
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'discount_value': discountValue,
      'discount_type': discountType.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'min_purchase_amount': minPurchaseAmount,
      'max_discount_amount': maxDiscountAmount,
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'applicable_categories': applicableCategories,
      'applicable_products': applicableProducts,
      'excluded_products': excludedProducts,
      'is_first_order_only': isFirstOrderOnly,
      'is_new_customers_only': isNewCustomersOnly,
      'image_url': imageUrl,
      'banner_url': bannerUrl,
      'priority': priority,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || usageCount < usageLimit!);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  String get status {
    if (isExpired) return 'Expired';
    if (isUpcoming) return 'Upcoming';
    if (!isActive) return 'Inactive';
    if (usageLimit != null && usageCount >= usageLimit!) return 'Limit Reached';
    return 'Active';
  }

  String get timeRemaining {
    if (isExpired) return 'Expired';

    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} left';
    } else {
      return 'Ending soon';
    }
  }

  double calculateDiscount(double amount) {
    if (!isValid) return 0.0;

    if (minPurchaseAmount != null && amount < minPurchaseAmount!) {
      return 0.0;
    }

    double discount;

    if (discountType == DiscountType.percentage) {
      discount = amount * (discountValue / 100);
    } else {
      discount = discountValue;
    }

    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }

    return discount;
  }
}

enum PromotionType {
  couponCode,
  automaticDiscount,
  flashSale,
  buyOneGetOne,
  freeShipping,
  bundleDiscount,
  seasonalSale,
  categoryDiscount,
  firstOrder,
  loyaltyReward,
}

enum DiscountType {
  percentage,
  fixed,
}

class FlashSale {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<FlashSaleProduct> products;
  final String? bannerUrl;
  final bool isActive;

  FlashSale({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.products,
    this.bannerUrl,
    this.isActive = true,
  });

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    return FlashSale(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      products: (json['products'] as List?)
              ?.map((p) => FlashSaleProduct.fromJson(p))
              .toList() ??
          [],
      bannerUrl: json['banner_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
      'banner_url': bannerUrl,
      'is_active': isActive,
    };
  }

  bool get isLive {
    final now = DateTime.now();
    return isActive && now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endTime);
  }

  String get timeRemaining {
    if (isExpired) return 'Ended';

    final now = DateTime.now();
    final difference = isUpcoming
        ? startTime.difference(now)
        : endTime.difference(now);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    }
  }
}

class FlashSaleProduct {
  final String productId;
  final String productName;
  final String? imageUrl;
  final double originalPrice;
  final double salePrice;
  final int stockQuantity;
  final int soldQuantity;
  final int? limitPerCustomer;

  FlashSaleProduct({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.originalPrice,
    required this.salePrice,
    required this.stockQuantity,
    this.soldQuantity = 0,
    this.limitPerCustomer,
  });

  factory FlashSaleProduct.fromJson(Map<String, dynamic> json) {
    return FlashSaleProduct(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      imageUrl: json['image_url'],
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      soldQuantity: json['sold_quantity'] ?? 0,
      limitPerCustomer: json['limit_per_customer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'image_url': imageUrl,
      'original_price': originalPrice,
      'sale_price': salePrice,
      'stock_quantity': stockQuantity,
      'sold_quantity': soldQuantity,
      'limit_per_customer': limitPerCustomer,
    };
  }

  double get discountPercentage {
    if (originalPrice == 0) return 0;
    return ((originalPrice - salePrice) / originalPrice) * 100;
  }

  int get remainingStock {
    return stockQuantity - soldQuantity;
  }

  bool get isInStock {
    return remainingStock > 0;
  }

  double get stockProgress {
    if (stockQuantity == 0) return 0;
    return soldQuantity / stockQuantity;
  }
}

class PromoCodeValidation {
  final bool isValid;
  final String? errorMessage;
  final double discountAmount;
  final Promotion? promotion;

  PromoCodeValidation({
    required this.isValid,
    this.errorMessage,
    this.discountAmount = 0.0,
    this.promotion,
  });

  factory PromoCodeValidation.invalid(String message) {
    return PromoCodeValidation(
      isValid: false,
      errorMessage: message,
    );
  }

  factory PromoCodeValidation.valid(Promotion promotion, double discount) {
    return PromoCodeValidation(
      isValid: true,
      discountAmount: discount,
      promotion: promotion,
    );
  }
}

class BundleOffer {
  final String id;
  final String title;
  final String description;
  final List<String> productIds;
  final double bundlePrice;
  final double originalTotalPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imageUrl;
  final bool isActive;

  BundleOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.productIds,
    required this.bundlePrice,
    required this.originalTotalPrice,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.isActive = true,
  });

  factory BundleOffer.fromJson(Map<String, dynamic> json) {
    return BundleOffer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      productIds: List<String>.from(json['product_ids'] ?? []),
      bundlePrice: (json['bundle_price'] ?? 0).toDouble(),
      originalTotalPrice: (json['original_total_price'] ?? 0).toDouble(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'product_ids': productIds,
      'bundle_price': bundlePrice,
      'original_total_price': originalTotalPrice,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  double get savings {
    return originalTotalPrice - bundlePrice;
  }

  double get savingsPercentage {
    if (originalTotalPrice == 0) return 0;
    return (savings / originalTotalPrice) * 100;
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        (startDate == null || now.isAfter(startDate!)) &&
        (endDate == null || now.isBefore(endDate!));
  }
}
