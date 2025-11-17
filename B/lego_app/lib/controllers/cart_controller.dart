import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// CartController manages shopping cart state with persistent storage
/// Uses GetStorage for cart persistence across app restarts
class CartController extends GetxController {
  final Logger _logger = Logger();
  final GetStorage _storage = GetStorage();

  static const String _cartKey = 'shopping_cart';

  // Observable cart items
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  // Observable loading state
  final RxBool isLoading = false.obs;

  // Tax rate (10%)
  static const double _taxRate = 0.10;

  // Shipping cost base
  static const double _baseShippingCost = 10.0;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
    _logger.i('CartController initialized');
  }

  // ============================================================================
  // CART MANAGEMENT
  // ============================================================================

  /// Add product to cart or increase quantity if already exists
  void addToCart(
    Product product, {
    String? selectedSize,
    String? selectedColor,
    int quantity = 1,
  }) {
    try {
      // Create cart item from product
      final cartItem = CartItem(
        productId: product.id,
        productName: product.name,
        productImage: product.imagePaths.isNotEmpty ? product.imagePaths.first : null,
        price: product.price,
        discountedPrice: product.discountedPrice > 0 ? product.discountedPrice : null,
        quantity: quantity,
        size: selectedSize,
        color: selectedColor,
        sku: product.barcode,
        maxStock: product.quantity,
        inStock: product.inStock,
      );

      // Check if item already exists
      final existingIndex = cartItems.indexWhere(
        (item) => item.isSameProduct(cartItem),
      );

      if (existingIndex != -1) {
        // Update existing item quantity
        final existingItem = cartItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        if (newQuantity <= existingItem.maxStock) {
          cartItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);

          Get.snackbar(
            'Updated',
            '${product.name} quantity updated in cart',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Stock Limit',
            'Cannot add more than ${existingItem.maxStock} items',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        // Add new item
        cartItems.add(cartItem);

        Get.snackbar(
          'Added to Cart',
          '${product.name} added to your cart',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      _saveCart();
      _logger.i('Added to cart: ${product.name}');
    } catch (e) {
      _logger.e('Error adding to cart: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove item from cart
  void removeFromCart(CartItem item) {
    try {
      cartItems.remove(item);
      _saveCart();
      _logger.i('Removed from cart: ${item.productName}');

      Get.snackbar(
        'Removed',
        '${item.productName} removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _logger.e('Error removing from cart: $e');
    }
  }

  /// Update item quantity
  void updateQuantity(CartItem item, int newQuantity) {
    try {
      if (newQuantity < 1) {
        removeFromCart(item);
        return;
      }

      if (newQuantity > item.maxStock) {
        Get.snackbar(
          'Stock Limit',
          'Maximum ${item.maxStock} items available',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final index = cartItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        cartItems[index] = item.copyWith(quantity: newQuantity);
        _saveCart();
        _logger.d('Updated quantity for ${item.productName}: $newQuantity');
      }
    } catch (e) {
      _logger.e('Error updating quantity: $e');
    }
  }

  /// Increase item quantity by 1
  void increaseQuantity(CartItem item) {
    if (item.canIncreaseQuantity) {
      updateQuantity(item, item.quantity + 1);
    } else {
      Get.snackbar(
        'Stock Limit',
        'Maximum ${item.maxStock} items available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Decrease item quantity by 1
  void decreaseQuantity(CartItem item) {
    if (item.canDecreaseQuantity) {
      updateQuantity(item, item.quantity - 1);
    } else {
      removeFromCart(item);
    }
  }

  /// Clear all items from cart
  void clearCart() {
    try {
      cartItems.clear();
      _saveCart();
      _logger.i('Cart cleared');

      Get.snackbar(
        'Cart Cleared',
        'All items removed from cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _logger.e('Error clearing cart: $e');
    }
  }

  // ============================================================================
  // CALCULATIONS
  // ============================================================================

  /// Get cart subtotal (sum of all item totals)
  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Calculate tax
  double get tax {
    return subtotal * _taxRate;
  }

  /// Calculate shipping cost
  double get shippingCost {
    if (subtotal >= 100) return 0.0; // Free shipping over $100
    return _baseShippingCost;
  }

  /// Get total discount/savings
  double get totalSavings {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalSavings);
  }

  /// Calculate cart total
  double get total {
    return subtotal + tax + shippingCost;
  }

  /// Get total number of items in cart
  int get itemCount {
    return cartItems.length;
  }

  /// Get total quantity of all items
  int get totalQuantity {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if cart is empty
  bool get isEmpty => cartItems.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => cartItems.isNotEmpty;

  // ============================================================================
  // PERSISTENCE
  // ============================================================================

  /// Save cart to persistent storage
  void _saveCart() {
    try {
      final cartData = cartItems.map((item) => item.toJson()).toList();
      _storage.write(_cartKey, jsonEncode(cartData));
      _logger.d('Cart saved: ${cartItems.length} items');
    } catch (e) {
      _logger.e('Error saving cart: $e');
    }
  }

  /// Load cart from persistent storage
  void _loadCart() {
    try {
      isLoading.value = true;

      final cartDataString = _storage.read<String>(_cartKey);

      if (cartDataString != null && cartDataString.isNotEmpty) {
        final cartData = jsonDecode(cartDataString) as List;
        final loadedItems = cartData
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();

        cartItems.value = loadedItems;
        _logger.i('Cart loaded: ${cartItems.length} items');
      } else {
        _logger.d('No saved cart found');
      }
    } catch (e) {
      _logger.e('Error loading cart: $e');
      cartItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if product is in cart
  bool isInCart(String productId, {String? size, String? color}) {
    return cartItems.any((item) =>
        item.productId == productId &&
        item.size == size &&
        item.color == color);
  }

  /// Get cart item for a product
  CartItem? getCartItem(String productId, {String? size, String? color}) {
    try {
      return cartItems.firstWhere(
        (item) =>
            item.productId == productId &&
            item.size == size &&
            item.color == color,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get quantity of a specific product in cart
  int getProductQuantity(String productId, {String? size, String? color}) {
    final item = getCartItem(productId, size: size, color: color);
    return item?.quantity ?? 0;
  }

  /// Validate cart before checkout
  bool validateCart() {
    if (isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Please add items to cart before checkout',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Check stock availability
    for (final item in cartItems) {
      if (!item.inStock) {
        Get.snackbar(
          'Out of Stock',
          '${item.productName} is out of stock',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (item.quantity > item.maxStock) {
        Get.snackbar(
          'Stock Limit Exceeded',
          'Only ${item.maxStock} ${item.productName} available',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    return true;
  }

  /// Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'item_count': itemCount,
      'total_quantity': totalQuantity,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shippingCost,
      'discount': totalSavings,
      'total': total,
    };
  }

  /// Refresh cart (reload from storage)
  void refreshCart() {
    _loadCart();
  }
}
