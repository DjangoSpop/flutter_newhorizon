import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'api_service.dart';

/// Service for managing shopping cart operations
class CartService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  static const String _cartCacheKey = 'cart_items_cache';

  /// Fetch cart from backend
  Future<List<CartItem>> fetchCart() async {
    try {
      final response = await _apiService.get('/cart/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items.map((item) => CartItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch cart');
      }
    } catch (e) {
      // If backend fails, try to load from local cache
      return await _loadCartFromCache();
    }
  }

  /// Add item to cart
  Future<CartItem> addToCart({
    required String productId,
    required Product product,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  }) async {
    try {
      final response = await _apiService.post('/cart/items/', {
        'product_id': productId,
        'quantity': quantity,
        'selected_size': selectedSize,
        'selected_color': selectedColor,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return CartItem.fromJson(data);
      } else {
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      // Create local cart item if backend fails
      final cartItem = CartItem(
        productId: productId,
        product: product,
        quantity: quantity,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        unitPrice: product.discountedPrice > 0 ? product.discountedPrice : product.price,
      );

      // Save to local cache
      await _addToLocalCache(cartItem);

      return cartItem;
    }
  }

  /// Update cart item quantity
  Future<CartItem> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.patch('/cart/items/$cartItemId/', {
        'quantity': quantity,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CartItem.fromJson(data);
      } else {
        throw Exception('Failed to update cart item');
      }
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await _apiService.delete('/cart/items/$cartItemId/');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove item from cart');
      }
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      final response = await _apiService.delete('/cart/');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to clear cart');
      }

      // Also clear local cache
      await _clearLocalCache();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  /// Get cart summary
  Future<CartSummary> getCartSummary({
    double taxRate = 0.0,
    double shippingCost = 0.0,
    double discountAmount = 0.0,
  }) async {
    try {
      final items = await fetchCart();

      return CartSummary.fromCartItems(
        items: items,
        taxRate: taxRate,
        shippingCost: shippingCost,
        discountAmount: discountAmount,
      );
    } catch (e) {
      throw Exception('Failed to get cart summary: $e');
    }
  }

  /// Apply promo code
  Future<Map<String, dynamic>> applyPromoCode(String promoCode) async {
    try {
      final response = await _apiService.post('/promotions/validate/', {
        'promo_code': promoCode,
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Invalid promo code');
      }
    } catch (e) {
      throw Exception('Failed to apply promo code: $e');
    }
  }

  // ============================================
  // Local Cache Methods
  // ============================================

  /// Save cart to local cache
  Future<void> _saveCartToCache(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = items.map((item) => item.toJson()).toList();
      await prefs.setString(_cartCacheKey, json.encode(cartJson));
    } catch (e) {
      print('Failed to save cart to cache: $e');
    }
  }

  /// Load cart from local cache
  Future<List<CartItem>> _loadCartFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartCacheKey);

      if (cartString != null) {
        final List<dynamic> cartJson = json.decode(cartString);
        return cartJson.map((item) => CartItem.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Failed to load cart from cache: $e');
      return [];
    }
  }

  /// Add item to local cache
  Future<void> _addToLocalCache(CartItem item) async {
    try {
      final items = await _loadCartFromCache();
      items.add(item);
      await _saveCartToCache(items);
    } catch (e) {
      print('Failed to add item to local cache: $e');
    }
  }

  /// Clear local cache
  Future<void> _clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartCacheKey);
    } catch (e) {
      print('Failed to clear local cache: $e');
    }
  }

  /// Sync local cart with backend (useful after login)
  Future<void> syncCart() async {
    try {
      final localItems = await _loadCartFromCache();

      if (localItems.isEmpty) return;

      // Upload local items to backend
      for (var item in localItems) {
        await addToCart(
          productId: item.productId,
          product: item.product,
          quantity: item.quantity,
          selectedSize: item.selectedSize,
          selectedColor: item.selectedColor,
        );
      }

      // Clear local cache after successful sync
      await _clearLocalCache();
    } catch (e) {
      print('Failed to sync cart: $e');
    }
  }

  /// Check if product is in cart
  Future<bool> isProductInCart(String productId, {String? size, String? color}) async {
    try {
      final items = await fetchCart();

      return items.any((item) =>
          item.productId == productId &&
          (size == null || item.selectedSize == size) &&
          (color == null || item.selectedColor == color));
    } catch (e) {
      return false;
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final items = await fetchCart();
      return items.fold(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      return 0;
    }
  }
}
