import 'package:get/get.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';
import '../service/wishlist_service.dart';
import 'cart_controller.dart';

/// Controller for managing wishlist state and operations
class WishlistController extends GetxController {
  final WishlistService _wishlistService = Get.find<WishlistService>();

  // Observables
  var wishlistItems = <WishlistItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  // ============================================
  // Wishlist Operations
  // ============================================

  /// Load wishlist from backend
  Future<void> loadWishlist() async {
    try {
      isLoading.value = true;
      final items = await _wishlistService.fetchWishlist();
      wishlistItems.value = items;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist({
    required Product product,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      // Check if already in wishlist
      if (isInWishlist(product.id)) {
        Get.snackbar(
          'Info',
          '${product.name} is already in your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        return;
      }

      final wishlistItem = await _wishlistService.addToWishlist(
        productId: product.id,
        product: product,
        notes: notes,
      );

      wishlistItems.add(wishlistItem);

      Get.snackbar(
        'Success',
        'Added ${product.name} to wishlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add to wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String wishlistItemId) async {
    try {
      isLoading.value = true;

      await _wishlistService.removeFromWishlist(wishlistItemId);

      wishlistItems.removeWhere((item) => item.id == wishlistItemId);

      Get.snackbar(
        'Success',
        'Removed from wishlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle wishlist (add if not in wishlist, remove if in wishlist)
  Future<void> toggleWishlist(Product product) async {
    if (isInWishlist(product.id)) {
      final item = getWishlistItem(product.id);
      if (item != null) {
        await removeFromWishlist(item.id);
      }
    } else {
      await addToWishlist(product: product);
    }
  }

  /// Update wishlist item notes
  Future<void> updateNotes(String wishlistItemId, String notes) async {
    try {
      final updatedItem = await _wishlistService.updateWishlistItem(
        wishlistItemId: wishlistItemId,
        notes: notes,
      );

      final index = wishlistItems.indexWhere((item) => item.id == wishlistItemId);
      if (index != -1) {
        wishlistItems[index] = updatedItem;
      }

      Get.snackbar(
        'Success',
        'Notes updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update notes: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Clear Wishlist'),
        content: Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;

      await _wishlistService.clearWishlist();

      wishlistItems.clear();

      Get.snackbar(
        'Success',
        'Wishlist cleared',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Move to Cart
  // ============================================

  /// Move wishlist item to cart
  Future<void> moveToCart(String wishlistItemId) async {
    try {
      isLoading.value = true;

      final wishlistItem = wishlistItems.firstWhere((item) => item.id == wishlistItemId);

      // Add to cart
      final cartController = Get.find<CartController>();
      await cartController.addToCart(product: wishlistItem.product);

      // Remove from wishlist
      await _wishlistService.removeFromWishlist(wishlistItemId);
      wishlistItems.removeWhere((item) => item.id == wishlistItemId);

      Get.snackbar(
        'Success',
        'Moved to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to move to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Move all wishlist items to cart
  Future<void> moveAllToCart() async {
    if (isEmpty) {
      Get.snackbar(
        'Info',
        'Your wishlist is empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final cartController = Get.find<CartController>();

      // Add all to cart
      for (var item in wishlistItems) {
        await cartController.addToCart(product: item.product);
      }

      // Clear wishlist
      await _wishlistService.clearWishlist();
      wishlistItems.clear();

      Get.snackbar(
        'Success',
        'All items moved to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to move items to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Sync Operations
  // ============================================

  /// Sync local wishlist with backend (after login)
  Future<void> syncWishlist() async {
    try {
      isLoading.value = true;
      await _wishlistService.syncWishlist();
      await loadWishlist();
    } catch (e) {
      print('Failed to sync wishlist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Getters
  // ============================================

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return wishlistItems.any((item) => item.productId == productId);
  }

  /// Get wishlist item for product
  WishlistItem? getWishlistItem(String productId) {
    try {
      return wishlistItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Get wishlist count
  int get itemCount => wishlistItems.length;

  /// Check if wishlist is empty
  bool get isEmpty => wishlistItems.isEmpty;

  /// Check if wishlist is not empty
  bool get isNotEmpty => wishlistItems.isNotEmpty;

  /// Get out of stock items
  List<WishlistItem> get outOfStockItems {
    return wishlistItems.where((item) => !item.isInStock).toList();
  }

  /// Get items on sale
  List<WishlistItem> get itemsOnSale {
    return wishlistItems.where((item) => item.hasDiscount).toList();
  }

  /// Get total value of wishlist
  double get totalValue {
    return wishlistItems.fold(
      0.0,
      (sum, item) => sum + (item.product.discountedPrice > 0
          ? item.product.discountedPrice
          : item.product.price),
    );
  }

  /// Get total savings if all items purchased
  double get totalSavings {
    return wishlistItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price - item.product.discountedPrice),
    );
  }
}
