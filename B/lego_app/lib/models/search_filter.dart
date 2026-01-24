/// Search and filter models for product discovery

/// Search filter configuration
class SearchFilter {
  // Category filters
  List<String> categories;
  List<String> subcategories;

  // Price range
  double? minPrice;
  double? maxPrice;

  // Product attributes
  List<String> sizes;
  List<String> colors;
  List<String> brands;

  // Availability
  bool? inStockOnly;
  bool? onSaleOnly;

  // Sorting
  SortOption sortBy;

  // Rating
  double? minRating;

  SearchFilter({
    this.categories = const [],
    this.subcategories = const [],
    this.minPrice,
    this.maxPrice,
    this.sizes = const [],
    this.colors = const [],
    this.brands = const [],
    this.inStockOnly,
    this.onSaleOnly,
    this.sortBy = SortOption.relevance,
    this.minRating,
  });

  /// Check if any filters are active
  bool get hasActiveFilters {
    return categories.isNotEmpty ||
        subcategories.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        sizes.isNotEmpty ||
        colors.isNotEmpty ||
        brands.isNotEmpty ||
        inStockOnly == true ||
        onSaleOnly == true ||
        minRating != null;
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (categories.isNotEmpty) count++;
    if (subcategories.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (sizes.isNotEmpty) count++;
    if (colors.isNotEmpty) count++;
    if (brands.isNotEmpty) count++;
    if (inStockOnly == true) count++;
    if (onSaleOnly == true) count++;
    if (minRating != null) count++;
    return count;
  }

  /// Clear all filters
  void clear() {
    categories = [];
    subcategories = [];
    minPrice = null;
    maxPrice = null;
    sizes = [];
    colors = [];
    brands = [];
    inStockOnly = null;
    onSaleOnly = null;
    minRating = null;
  }

  /// Create from JSON
  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      subcategories: json['subcategories'] != null
          ? List<String>.from(json['subcategories'])
          : [],
      minPrice: json['minPrice']?.toDouble() ?? json['min_price']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble() ?? json['max_price']?.toDouble(),
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : [],
      colors: json['colors'] != null ? List<String>.from(json['colors']) : [],
      brands: json['brands'] != null ? List<String>.from(json['brands']) : [],
      inStockOnly: json['inStockOnly'] ?? json['in_stock_only'],
      onSaleOnly: json['onSaleOnly'] ?? json['on_sale_only'],
      sortBy: json['sortBy'] != null || json['sort_by'] != null
          ? SortOption.values.firstWhere(
              (e) =>
                  e.toString().split('.').last ==
                  (json['sortBy'] ?? json['sort_by']),
              orElse: () => SortOption.relevance,
            )
          : SortOption.relevance,
      minRating: json['minRating']?.toDouble() ?? json['min_rating']?.toDouble(),
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (categories.isNotEmpty) {
      data['categories'] = categories;
    }
    if (subcategories.isNotEmpty) {
      data['subcategories'] = subcategories;
    }
    if (minPrice != null) {
      data['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      data['max_price'] = maxPrice;
    }
    if (sizes.isNotEmpty) {
      data['sizes'] = sizes;
    }
    if (colors.isNotEmpty) {
      data['colors'] = colors;
    }
    if (brands.isNotEmpty) {
      data['brands'] = brands;
    }
    if (inStockOnly != null) {
      data['in_stock_only'] = inStockOnly;
    }
    if (onSaleOnly != null) {
      data['on_sale_only'] = onSaleOnly;
    }
    if (minRating != null) {
      data['min_rating'] = minRating;
    }
    data['sort_by'] = sortBy.toString().split('.').last;

    return data;
  }

  /// Create a copy with updated fields
  SearchFilter copyWith({
    List<String>? categories,
    List<String>? subcategories,
    double? minPrice,
    double? maxPrice,
    List<String>? sizes,
    List<String>? colors,
    List<String>? brands,
    bool? inStockOnly,
    bool? onSaleOnly,
    SortOption? sortBy,
    double? minRating,
  }) {
    return SearchFilter(
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      brands: brands ?? this.brands,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
      sortBy: sortBy ?? this.sortBy,
      minRating: minRating ?? this.minRating,
    );
  }
}

/// Sort options for search results
enum SortOption {
  relevance,
  priceLowToHigh,
  priceHighToLow,
  newest,
  bestRating,
  mostReviewed,
  popularity,
}

/// Extension for sort option display names
extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.newest:
        return 'Newest';
      case SortOption.bestRating:
        return 'Best Rating';
      case SortOption.mostReviewed:
        return 'Most Reviewed';
      case SortOption.popularity:
        return 'Popularity';
    }
  }

  String get apiValue {
    switch (this) {
      case SortOption.relevance:
        return 'relevance';
      case SortOption.priceLowToHigh:
        return 'price_asc';
      case SortOption.priceHighToLow:
        return 'price_desc';
      case SortOption.newest:
        return 'newest';
      case SortOption.bestRating:
        return 'rating_desc';
      case SortOption.mostReviewed:
        return 'reviews_desc';
      case SortOption.popularity:
        return 'popularity';
    }
  }
}

/// Search suggestion model
class SearchSuggestion {
  String id;
  String text;
  SuggestionType type;
  int? productCount;
  String? imageUrl;

  SearchSuggestion({
    required this.id,
    required this.text,
    required this.type,
    this.productCount,
    this.imageUrl,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['id'],
      text: json['text'],
      type: SuggestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SuggestionType.query,
      ),
      productCount: json['productCount'] ?? json['product_count'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'productCount': productCount,
      'imageUrl': imageUrl,
    };
  }
}

/// Suggestion types
enum SuggestionType {
  query,
  category,
  brand,
  product,
}

/// Search history item
class SearchHistoryItem {
  String query;
  DateTime timestamp;

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Available filters from backend
class AvailableFilters {
  List<String> categories;
  List<String> brands;
  List<String> sizes;
  List<String> colors;
  double minPrice;
  double maxPrice;

  AvailableFilters({
    required this.categories,
    required this.brands,
    required this.sizes,
    required this.colors,
    required this.minPrice,
    required this.maxPrice,
  });

  factory AvailableFilters.fromJson(Map<String, dynamic> json) {
    return AvailableFilters(
      categories: List<String>.from(json['categories'] ?? []),
      brands: List<String>.from(json['brands'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      minPrice: json['minPrice']?.toDouble() ?? json['min_price']?.toDouble() ?? 0.0,
      maxPrice: json['maxPrice']?.toDouble() ?? json['max_price']?.toDouble() ?? 10000.0,
    );
  }
}
