import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';
import 'api_service.dart';

/// Service for managing wishlist operations
class WishlistService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  static const String _wishlistCacheKey = 'wishlist_cache';

  /// Fetch wishlist from backend
  Future<List<WishlistItem>> fetchWishlist() async {
    try {
      final response = await _apiService.get('/wishlist/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        final wishlistItems = items.map((item) => WishlistItem.fromJson(item)).toList();

        // Save to cache
        await _saveWishlistToCache(wishlistItems);

        return wishlistItems;
      } else {
        throw Exception('Failed to fetch wishlist');
      }
    } catch (e) {
      // If backend fails, try to load from local cache
      return await _loadWishlistFromCache();
    }
  }

  /// Add product to wishlist
  Future<WishlistItem> addToWishlist({
    required String productId,
    required Product product,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post('/wishlist/items/', {
        'product_id': productId,
        'notes': notes,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return WishlistItem.fromJson(data);
      } else {
        throw Exception('Failed to add to wishlist');
      }
    } catch (e) {
      // Create local wishlist item if backend fails
      final wishlistItem = WishlistItem(
        productId: productId,
        product: product,
        notes: notes,
      );

      // Save to local cache
      await _addToLocalCache(wishlistItem);

      return wishlistItem;
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String wishlistItemId) async {
    try {
      final response = await _apiService.delete('/wishlist/items/$wishlistItemId/');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove from wishlist');
      }
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  /// Update wishlist item notes
  Future<WishlistItem> updateWishlistItem({
    required String wishlistItemId,
    String? notes,
  }) async {
    try {
      final response = await _apiService.patch('/wishlist/items/$wishlistItemId/', {
        'notes': notes,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WishlistItem.fromJson(data);
      } else {
        throw Exception('Failed to update wishlist item');
      }
    } catch (e) {
      throw Exception('Failed to update wishlist item: $e');
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    try {
      final response = await _apiService.delete('/wishlist/');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to clear wishlist');
      }

      // Clear local cache
      await _clearLocalCache();
    } catch (e) {
      throw Exception('Failed to clear wishlist: $e');
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      final items = await fetchWishlist();
      return items.any((item) => item.productId == productId);
    } catch (e) {
      return false;
    }
  }

  /// Get wishlist item count
  Future<int> getWishlistItemCount() async {
    try {
      final items = await fetchWishlist();
      return items.length;
    } catch (e) {
      return 0;
    }
  }

  /// Move wishlist item to cart
  Future<void> moveToCart(String wishlistItemId) async {
    try {
      final response = await _apiService.post(
        '/wishlist/items/$wishlistItemId/move-to-cart/',
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to move to cart');
      }
    } catch (e) {
      throw Exception('Failed to move to cart: $e');
    }
  }

  /// Move all wishlist items to cart
  Future<void> moveAllToCart() async {
    try {
      final response = await _apiService.post('/wishlist/move-all-to-cart/', {});

      if (response.statusCode != 200) {
        throw Exception('Failed to move all to cart');
      }
    } catch (e) {
      throw Exception('Failed to move all to cart: $e');
    }
  }

  // ============================================
  // Local Cache Methods
  // ============================================

  /// Save wishlist to local cache
  Future<void> _saveWishlistToCache(List<WishlistItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = items.map((item) => item.toJson()).toList();
      await prefs.setString(_wishlistCacheKey, json.encode(wishlistJson));
    } catch (e) {
      print('Failed to save wishlist to cache: $e');
    }
  }

  /// Load wishlist from local cache
  Future<List<WishlistItem>> _loadWishlistFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistString = prefs.getString(_wishlistCacheKey);

      if (wishlistString != null) {
        final List<dynamic> wishlistJson = json.decode(wishlistString);
        return wishlistJson
            .map((item) => WishlistItem.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Failed to load wishlist from cache: $e');
      return [];
    }
  }

  /// Add item to local cache
  Future<void> _addToLocalCache(WishlistItem item) async {
    try {
      final items = await _loadWishlistFromCache();
      items.add(item);
      await _saveWishlistToCache(items);
    } catch (e) {
      print('Failed to add item to local cache: $e');
    }
  }

  /// Clear local cache
  Future<void> _clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wishlistCacheKey);
    } catch (e) {
      print('Failed to clear local cache: $e');
    }
  }

  /// Sync local wishlist with backend (useful after login)
  Future<void> syncWishlist() async {
    try {
      final localItems = await _loadWishlistFromCache();

      if (localItems.isEmpty) return;

      // Upload local items to backend
      for (var item in localItems) {
        await addToWishlist(
          productId: item.productId,
          product: item.product,
          notes: item.notes,
        );
      }

      // Clear local cache after successful sync
      await _clearLocalCache();
    } catch (e) {
      print('Failed to sync wishlist: $e');
    }
  }
}
