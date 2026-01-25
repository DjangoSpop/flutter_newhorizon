import 'dart:async';
import 'package:get/get.dart';
import '../models/promotion.dart';
import '../service/promotion_service.dart';

class PromotionController extends GetxController {
  final PromotionService _promotionService = Get.find<PromotionService>();

  // Observable state
  var activePromotions = <Promotion>[].obs;
  var personalizedPromotions = <Promotion>[].obs;
  var activeFlashSales = <FlashSale>[].obs;
  var upcomingFlashSales = <FlashSale>[].obs;
  var bundleOffers = <BundleOffer>[].obs;

  var isLoading = false.obs;
  var appliedPromoCode = Rx<Promotion?>(null);
  var appliedDiscount = 0.0.obs;
  var selectedFlashSale = Rx<FlashSale?>(null);

  // Flash sale countdown timer
  Timer? _flashSaleTimer;

  @override
  void onInit() {
    super.onInit();
    loadPromotions();
    loadFlashSales();
    loadBundleOffers();
    _startFlashSaleTimer();
  }

  @override
  void onClose() {
    _flashSaleTimer?.cancel();
    super.onClose();
  }

  /// Load all active promotions
  Future<void> loadPromotions() async {
    try {
      isLoading.value = true;

      final promotions = await _promotionService.getActivePromotions();
      activePromotions.value = promotions;

      // Load personalized promotions
      final personalized = await _promotionService.getPersonalizedPromotions();
      personalizedPromotions.value = personalized;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load promotions',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load flash sales
  Future<void> loadFlashSales() async {
    try {
      final active = await _promotionService.getActiveFlashSales();
      activeFlashSales.value = active;

      final upcoming = await _promotionService.getUpcomingFlashSales();
      upcomingFlashSales.value = upcoming;
    } catch (e) {
      print('Error loading flash sales: $e');
    }
  }

  /// Load flash sale details
  Future<void> loadFlashSaleDetails(String flashSaleId) async {
    try {
      isLoading.value = true;

      final flashSale = await _promotionService.getFlashSaleDetails(flashSaleId);
      selectedFlashSale.value = flashSale;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load flash sale details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load bundle offers
  Future<void> loadBundleOffers() async {
    try {
      final bundles = await _promotionService.getBundleOffers();
      bundleOffers.value = bundles;
    } catch (e) {
      print('Error loading bundle offers: $e');
    }
  }

  /// Apply promo code
  Future<bool> applyPromoCode({
    required String code,
    required double cartTotal,
    List<String>? productIds,
    bool? isFirstOrder,
  }) async {
    try {
      isLoading.value = true;

      final validation = await _promotionService.validatePromoCode(
        code: code,
        cartTotal: cartTotal,
        productIds: productIds,
        isFirstOrder: isFirstOrder,
      );

      if (validation.isValid && validation.promotion != null) {
        appliedPromoCode.value = validation.promotion;
        appliedDiscount.value = validation.discountAmount;

        Get.snackbar(
          'Success',
          'Promo code applied successfully! You saved \$${validation.discountAmount.toStringAsFixed(2)}',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          validation.errorMessage ?? 'Invalid promo code',
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to apply promo code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove applied promo code
  void removePromoCode() {
    appliedPromoCode.value = null;
    appliedDiscount.value = 0.0;

    Get.snackbar(
      'Removed',
      'Promo code removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Get applicable automatic discounts
  Future<List<Promotion>> getAutomaticDiscounts({
    required double cartTotal,
    List<String>? productIds,
    List<String>? categoryIds,
    bool? isFirstOrder,
  }) async {
    try {
      final discounts = await _promotionService.getApplicableAutomaticDiscounts(
        cartTotal: cartTotal,
        productIds: productIds,
        categoryIds: categoryIds,
        isFirstOrder: isFirstOrder,
      );

      return discounts;
    } catch (e) {
      print('Error getting automatic discounts: $e');
      return [];
    }
  }

  /// Calculate total discount for cart
  Future<double> calculateTotalDiscount({
    required double cartTotal,
    List<String>? productIds,
    List<String>? categoryIds,
    String? promoCode,
  }) async {
    try {
      double totalDiscount = 0.0;

      // Apply promo code discount if available
      if (appliedPromoCode.value != null) {
        totalDiscount += appliedDiscount.value;
      }

      // Get automatic discounts
      final automaticDiscounts = await getAutomaticDiscounts(
        cartTotal: cartTotal,
        productIds: productIds,
        categoryIds: categoryIds,
      );

      // Add automatic discounts
      for (var promotion in automaticDiscounts) {
        totalDiscount += promotion.calculateDiscount(cartTotal);
      }

      return totalDiscount;
    } catch (e) {
      print('Error calculating total discount: $e');
      return 0.0;
    }
  }

  /// Get best available discount
  Future<Promotion?> getBestDiscount({
    required double cartTotal,
    List<String>? productIds,
    List<String>? categoryIds,
    String? promoCode,
  }) async {
    try {
      final bestPromotion = await _promotionService.calculateBestDiscount(
        cartTotal: cartTotal,
        productIds: productIds,
        categoryIds: categoryIds,
        promoCode: promoCode,
      );

      return bestPromotion;
    } catch (e) {
      print('Error getting best discount: $e');
      return null;
    }
  }

  /// Track promotion usage
  Future<void> trackPromotionUsage(String promotionId, String orderId) async {
    try {
      await _promotionService.trackPromotionUsage(promotionId, orderId);
    } catch (e) {
      print('Error tracking promotion usage: $e');
    }
  }

  /// Start flash sale countdown timer
  void _startFlashSaleTimer() {
    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Force update to refresh countdown displays
      if (activeFlashSales.isNotEmpty) {
        activeFlashSales.refresh();
      }
      if (selectedFlashSale.value != null) {
        selectedFlashSale.refresh();
      }
    });
  }

  /// Refresh all promotions
  Future<void> refreshPromotions() async {
    await Future.wait([
      loadPromotions(),
      loadFlashSales(),
      loadBundleOffers(),
    ]);
  }

  /// Get active flash sale count
  int get activeFlashSaleCount => activeFlashSales.length;

  /// Get upcoming flash sale count
  int get upcomingFlashSaleCount => upcomingFlashSales.length;

  /// Get active promotion count
  int get activePromotionCount => activePromotions.length;

  /// Get personalized promotion count
  int get personalizedPromotionCount => personalizedPromotions.length;

  /// Get bundle offer count
  int get bundleOfferCount => bundleOffers.length;

  /// Check if any promotions are available
  bool get hasPromotions => activePromotionCount > 0 || personalizedPromotionCount > 0;

  /// Check if any flash sales are live
  bool get hasLiveFlashSales => activeFlashSales.any((fs) => fs.isLive);

  /// Get featured promotions (highest priority)
  List<Promotion> get featuredPromotions {
    final allPromotions = [...activePromotions, ...personalizedPromotions];
    allPromotions.sort((a, b) => b.priority.compareTo(a.priority));
    return allPromotions.take(5).toList();
  }

  /// Get promotions by type
  List<Promotion> getPromotionsByType(PromotionType type) {
    return activePromotions.where((p) => p.type == type).toList();
  }

  /// Get valid bundle offers
  List<BundleOffer> get validBundleOffers {
    return bundleOffers.where((b) => b.isValid).toList();
  }

  /// Get live flash sales
  List<FlashSale> get liveFlashSales {
    return activeFlashSales.where((fs) => fs.isLive).toList();
  }

  /// Clear promotion cache
  Future<void> clearCache() async {
    try {
      await _promotionService.clearCache();
      activePromotions.clear();
      personalizedPromotions.clear();
      activeFlashSales.clear();
      upcomingFlashSales.clear();
      bundleOffers.clear();
      appliedPromoCode.value = null;
      appliedDiscount.value = 0.0;
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
