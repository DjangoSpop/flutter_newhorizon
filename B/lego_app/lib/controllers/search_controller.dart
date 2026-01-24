import 'package:get/get.dart';
import '../models/product.dart';
import '../models/search_filter.dart';
import '../service/search_service.dart';

/// Controller for search and filtering functionality
class SearchController extends GetxController {
  final SearchService _searchService = Get.find<SearchService>();

  // Search state
  var searchQuery = ''.obs;
  var searchResults = <Product>[].obs;
  var isSearching = false.obs;
  var hasSearched = false.obs;

  // Suggestions
  var suggestions = <SearchSuggestion>[].obs;
  var showSuggestions = false.obs;

  // Search history
  var searchHistory = <SearchHistoryItem>[].obs;
  var trendingSearches = <String>[].obs;

  // Filters
  var currentFilter = SearchFilter().obs;
  var availableFilters = Rx<AvailableFilters?>(null);
  var showFilters = false.obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreResults = true.obs;
  var isLoadingMore = false.obs;

  // Popular/Recommended
  var popularProducts = <Product>[].obs;
  var recommendedProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
    _loadTrendingSearches();
    _loadAvailableFilters();
    _loadPopularProducts();
    _loadRecommendedProducts();
  }

  // ============================================
  // Search Operations
  // ============================================

  /// Perform search
  Future<void> search({String? query, bool resetPage = true}) async {
    try {
      if (resetPage) {
        currentPage.value = 1;
        searchResults.clear();
        hasMoreResults.value = true;
      }

      isSearching.value = true;
      hasSearched.value = true;

      final queryToSearch = query ?? searchQuery.value;

      // Save to history if it's a new search
      if (resetPage && queryToSearch.isNotEmpty) {
        await _searchService.saveSearchHistory(queryToSearch);
        await _loadSearchHistory();
      }

      final results = await _searchService.searchProducts(
        query: queryToSearch.isNotEmpty ? queryToSearch : null,
        filter: currentFilter.value.hasActiveFilters ? currentFilter.value : null,
        page: currentPage.value,
      );

      if (resetPage) {
        searchResults.value = results;
      } else {
        searchResults.addAll(results);
      }

      // Check if there are more results
      hasMoreResults.value = results.length >= 20;

      // Hide suggestions after search
      showSuggestions.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSearching.value = false;
    }
  }

  /// Load more results (pagination)
  Future<void> loadMoreResults() async {
    if (!hasMoreResults.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;
      await search(resetPage: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;

    if (query.isNotEmpty) {
      _getSuggestions(query);
    } else {
      suggestions.clear();
      showSuggestions.value = false;
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    suggestions.clear();
    showSuggestions.value = false;
    hasSearched.value = false;
    currentPage.value = 1;
    hasMoreResults.value = true;
  }

  /// Search from suggestion
  void searchFromSuggestion(SearchSuggestion suggestion) {
    searchQuery.value = suggestion.text;
    search(query: suggestion.text);
  }

  /// Search from history
  void searchFromHistory(String query) {
    searchQuery.value = query;
    search(query: query);
  }

  // ============================================
  // Suggestions
  // ============================================

  /// Get search suggestions
  Future<void> _getSuggestions(String query) async {
    try {
      final results = await _searchService.getSuggestions(query);
      suggestions.value = results;
      showSuggestions.value = results.isNotEmpty;
    } catch (e) {
      print('Failed to get suggestions: $e');
    }
  }

  // ============================================
  // Filters
  // ============================================

  /// Apply filter
  Future<void> applyFilter(SearchFilter filter) async {
    currentFilter.value = filter;
    await search(resetPage: true);
    showFilters.value = false;
  }

  /// Update filter and search
  Future<void> updateFilter({
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
  }) async {
    currentFilter.value = currentFilter.value.copyWith(
      categories: categories,
      subcategories: subcategories,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sizes: sizes,
      colors: colors,
      brands: brands,
      inStockOnly: inStockOnly,
      onSaleOnly: onSaleOnly,
      sortBy: sortBy,
      minRating: minRating,
    );

    await search(resetPage: true);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    currentFilter.value.clear();
    currentFilter.refresh();
    await search(resetPage: true);
  }

  /// Toggle filter panel
  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  /// Load available filters from backend
  Future<void> _loadAvailableFilters() async {
    try {
      final filters = await _searchService.getAvailableFilters();
      availableFilters.value = filters;
    } catch (e) {
      print('Failed to load available filters: $e');
    }
  }

  /// Update sort option
  Future<void> updateSort(SortOption sortOption) async {
    currentFilter.value.sortBy = sortOption;
    currentFilter.refresh();
    await search(resetPage: true);
  }

  // ============================================
  // Search History
  // ============================================

  /// Load search history
  Future<void> _loadSearchHistory() async {
    try {
      final history = await _searchService.getSearchHistory();
      searchHistory.value = history;
    } catch (e) {
      print('Failed to load search history: $e');
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await _searchService.clearSearchHistory();
      searchHistory.clear();

      Get.snackbar(
        'Success',
        'Search history cleared',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear history',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove item from search history
  Future<void> removeHistoryItem(String query) async {
    try {
      await _searchService.removeSearchHistoryItem(query);
      await _loadSearchHistory();
    } catch (e) {
      print('Failed to remove history item: $e');
    }
  }

  // ============================================
  // Trending Searches
  // ============================================

  /// Load trending searches
  Future<void> _loadTrendingSearches() async {
    try {
      final trending = await _searchService.getTrendingSearches();
      trendingSearches.value = trending;
    } catch (e) {
      print('Failed to load trending searches: $e');
    }
  }

  // ============================================
  // Popular & Recommended
  // ============================================

  /// Load popular products
  Future<void> _loadPopularProducts() async {
    try {
      final products = await _searchService.getPopularProducts();
      popularProducts.value = products;
    } catch (e) {
      print('Failed to load popular products: $e');
    }
  }

  /// Load recommended products
  Future<void> _loadRecommendedProducts() async {
    try {
      final products = await _searchService.getRecommendedProducts();
      recommendedProducts.value = products;
    } catch (e) {
      print('Failed to load recommended products: $e');
    }
  }

  // ============================================
  // Quick Filters
  // ============================================

  /// Filter by category
  Future<void> filterByCategory(String category) async {
    currentFilter.value.categories = [category];
    currentFilter.refresh();
    await search(resetPage: true);
  }

  /// Filter by price range
  Future<void> filterByPriceRange(double min, double max) async {
    currentFilter.value.minPrice = min;
    currentFilter.value.maxPrice = max;
    currentFilter.refresh();
    await search(resetPage: true);
  }

  /// Filter by rating
  Future<void> filterByRating(double minRating) async {
    currentFilter.value.minRating = minRating;
    currentFilter.refresh();
    await search(resetPage: true);
  }

  /// Toggle in-stock only filter
  Future<void> toggleInStockOnly() async {
    currentFilter.value.inStockOnly = !(currentFilter.value.inStockOnly ?? false);
    currentFilter.refresh();
    await search(resetPage: true);
  }

  /// Toggle on-sale only filter
  Future<void> toggleOnSaleOnly() async {
    currentFilter.value.onSaleOnly = !(currentFilter.value.onSaleOnly ?? false);
    currentFilter.refresh();
    await search(resetPage: true);
  }

  // ============================================
  // Getters
  // ============================================

  /// Check if any filters are active
  bool get hasActiveFilters => currentFilter.value.hasActiveFilters;

  /// Get active filter count
  int get activeFilterCount => currentFilter.value.activeFilterCount;

  /// Check if results are empty
  bool get hasNoResults => hasSearched.value && searchResults.isEmpty && !isSearching.value;

  /// Get result count
  int get resultCount => searchResults.length;
}
