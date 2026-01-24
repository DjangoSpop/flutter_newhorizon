import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/search_filter.dart';
import 'api_service.dart';

/// Service for product search and filtering
class SearchService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 20;

  /// Search products with query and filters
  Future<List<Product>> searchProducts({
    String? query,
    SearchFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> params = {
        'page': page,
        'page_size': pageSize,
      };

      if (query != null && query.isNotEmpty) {
        params['q'] = query;
      }

      // Add filter parameters
      if (filter != null) {
        params.addAll(filter.toJson());
      }

      // Convert params to query string
      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final response = await _apiService.get('/products/search/?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? data['products'] ?? [];

        return results.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get search suggestions
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _apiService.get(
        '/products/suggestions/?q=${Uri.encodeComponent(query)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> suggestions = data['suggestions'] ?? [];

        return suggestions
            .map((item) => SearchSuggestion.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Failed to get suggestions: $e');
      return [];
    }
  }

  /// Get available filters
  Future<AvailableFilters> getAvailableFilters() async {
    try {
      final response = await _apiService.get('/products/filters/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AvailableFilters.fromJson(data);
      } else {
        throw Exception('Failed to get filters');
      }
    } catch (e) {
      throw Exception('Failed to get available filters: $e');
    }
  }

  /// Get trending searches
  Future<List<String>> getTrendingSearches() async {
    try {
      final response = await _apiService.get('/products/trending-searches/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> trending = data['trending'] ?? [];

        return trending.map((item) => item.toString()).toList();
      }

      return [];
    } catch (e) {
      print('Failed to get trending searches: $e');
      return [];
    }
  }

  // ============================================
  // Search History
  // ============================================

  /// Save search query to history
  Future<void> saveSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getSearchHistory();

      // Remove duplicate if exists
      history.removeWhere((item) => item.query == query);

      // Add new item at the beginning
      history.insert(
        0,
        SearchHistoryItem(
          query: query,
          timestamp: DateTime.now(),
        ),
      );

      // Limit history size
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Save to preferences
      final historyJson = history.map((item) => item.toJson()).toList();
      await prefs.setString(_searchHistoryKey, json.encode(historyJson));
    } catch (e) {
      print('Failed to save search history: $e');
    }
  }

  /// Get search history
  Future<List<SearchHistoryItem>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(_searchHistoryKey);

      if (historyString != null) {
        final List<dynamic> historyJson = json.decode(historyString);
        return historyJson
            .map((item) => SearchHistoryItem.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Failed to get search history: $e');
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      print('Failed to clear search history: $e');
    }
  }

  /// Remove item from search history
  Future<void> removeSearchHistoryItem(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getSearchHistory();

      history.removeWhere((item) => item.query == query);

      final historyJson = history.map((item) => item.toJson()).toList();
      await prefs.setString(_searchHistoryKey, json.encode(historyJson));
    } catch (e) {
      print('Failed to remove search history item: $e');
    }
  }

  // ============================================
  // Popular/Recommended Products
  // ============================================

  /// Get popular products
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/products/popular/?limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data['products'] ?? data['results'] ?? [];

        return products.map((item) => Product.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Failed to get popular products: $e');
      return [];
    }
  }

  /// Get recommended products (personalized)
  Future<List<Product>> getRecommendedProducts({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/products/recommended/?limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data['products'] ?? data['results'] ?? [];

        return products.map((item) => Product.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Failed to get recommended products: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory({
    required String category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/products/?category=$category&page=$page&page_size=$pageSize',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data['results'] ?? data['products'] ?? [];

        return products.map((item) => Product.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Failed to get products by category: $e');
      return [];
    }
  }
}
