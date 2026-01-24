import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../service/cart_service.dart';

/// Controller for managing shopping cart state and operations
class CartController extends GetxController {
  final CartService _cartService = Get.find<CartService>();

  // Observables
  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;
  var cartSummary = Rx<CartSummary?>(null);
  var promoCode = ''.obs;
  var promoDiscount = 0.0.obs;

  // Tax and shipping (can be configured or fetched from settings)
  var taxRate = 0.08.obs; // 8% tax rate
  var shippingCost = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  // ============================================
  // Cart Operations
  // ============================================

  /// Load cart from backend
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      final items = await _cartService.fetchCart();
      cartItems.value = items;
      await _calculateSummary();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add product to cart
  Future<void> addToCart({
    required Product product,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  }) async {
    try {
      isLoading.value = true;

      // Check if item with same variant already exists
      final existingItemIndex = cartItems.indexWhere(
        (item) =>
            item.productId == product.id &&
            item.selectedSize == selectedSize &&
            item.selectedColor == selectedColor,
      );

      if (existingItemIndex != -1) {
        // Update quantity of existing item
        final existingItem = cartItems[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;
        await updateQuantity(existingItem.id, newQuantity);
      } else {
        // Add new item
        final cartItem = await _cartService.addToCart(
          productId: product.id,
          product: product,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
        );

        cartItems.add(cartItem);
      }

      await _calculateSummary();

      Get.snackbar(
        'Success',
        'Added ${product.name} to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      isLoading.value = true;

      await _cartService.removeFromCart(cartItemId);

      cartItems.removeWhere((item) => item.id == cartItemId);

      await _calculateSummary();

      Get.snackbar(
        'Success',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove item: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update cart item quantity
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    try {
      final updatedItem = await _cartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: newQuantity,
      );

      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        cartItems[index] = updatedItem;
        await _calculateSummary();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update quantity: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Increment quantity
  Future<void> incrementQuantity(String cartItemId) async {
    final item = cartItems.firstWhere((item) => item.id == cartItemId);
    await updateQuantity(cartItemId, item.quantity + 1);
  }

  /// Decrement quantity
  Future<void> decrementQuantity(String cartItemId) async {
    final item = cartItems.firstWhere((item) => item.id == cartItemId);
    await updateQuantity(cartItemId, item.quantity - 1);
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      isLoading.value = true;

      await _cartService.clearCart();

      cartItems.clear();
      cartSummary.value = null;
      promoCode.value = '';
      promoDiscount.value = 0.0;

      Get.snackbar(
        'Success',
        'Cart cleared',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Promo Code Operations
  // ============================================

  /// Apply promo code
  Future<void> applyPromoCode(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a promo code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final result = await _cartService.applyPromoCode(code);

      promoCode.value = code;
      promoDiscount.value = result['discount_amount']?.toDouble() ?? 0.0;

      await _calculateSummary();

      Get.snackbar(
        'Success',
        'Promo code applied successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid promo code',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove promo code
  void removePromoCode() {
    promoCode.value = '';
    promoDiscount.value = 0.0;
    _calculateSummary();
  }

  // ============================================
  // Calculations
  // ============================================

  /// Calculate cart summary
  Future<void> _calculateSummary() async {
    if (cartItems.isEmpty) {
      cartSummary.value = null;
      return;
    }

    cartSummary.value = CartSummary.fromCartItems(
      items: cartItems,
      taxRate: taxRate.value,
      shippingCost: shippingCost.value,
      discountAmount: promoDiscount.value,
    );
  }

  /// Update tax rate
  void updateTaxRate(double rate) {
    taxRate.value = rate;
    _calculateSummary();
  }

  /// Update shipping cost
  void updateShippingCost(double cost) {
    shippingCost.value = cost;
    _calculateSummary();
  }

  // ============================================
  // Getters
  // ============================================

  /// Get total items count
  int get itemCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get subtotal
  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Get total
  double get total {
    return cartSummary.value?.total ?? 0.0;
  }

  /// Get total savings
  double get totalSavings {
    return cartSummary.value?.totalSavings ?? 0.0;
  }

  /// Check if cart is empty
  bool get isEmpty => cartItems.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => cartItems.isNotEmpty;

  /// Check if product is in cart
  bool isProductInCart(String productId, {String? size, String? color}) {
    return cartItems.any((item) =>
        item.productId == productId &&
        (size == null || item.selectedSize == size) &&
        (color == null || item.selectedColor == color));
  }

  /// Get cart item for product
  CartItem? getCartItemForProduct(String productId, {String? size, String? color}) {
    try {
      return cartItems.firstWhere(
        (item) =>
            item.productId == productId &&
            (size == null || item.selectedSize == size) &&
            (color == null || item.selectedColor == color),
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // Sync Operations
  // ============================================

  /// Sync local cart with backend (after login)
  Future<void> syncCart() async {
    try {
      isLoading.value = true;
      await _cartService.syncCart();
      await loadCart();
    } catch (e) {
      print('Failed to sync cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Validation
  // ============================================

  /// Validate cart before checkout
  bool validateCart() {
    if (isEmpty) {
      Get.snackbar(
        'Error',
        'Your cart is empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Check if all items are in stock
    final outOfStockItems = cartItems.where((item) => !item.product.inStock).toList();

    if (outOfStockItems.isNotEmpty) {
      Get.snackbar(
        'Error',
        'Some items in your cart are out of stock',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Check if quantities are available
    final insufficientStockItems = cartItems
        .where((item) => item.quantity > item.product.quantity)
        .toList();

    if (insufficientStockItems.isNotEmpty) {
      Get.snackbar(
        'Error',
        'Some items have insufficient stock',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
}
