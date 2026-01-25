import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/promotion.dart';

class PromotionService extends GetxService {
  final String baseUrl = 'http://your-backend-url.com/api';

  /// Fetch active promotions
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/promotions/active/'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> promotionsJson = data['results'] ?? data;

        final promotions = promotionsJson
            .map((json) => Promotion.fromJson(json))
            .toList();

        // Cache promotions
        await _cachePromotions(promotions);

        return promotions;
      } else {
        return _getCachedPromotions();
      }
    } catch (e) {
      print('Error fetching active promotions: $e');
      return _getCachedPromotions();
    }
  }

  /// Validate promo code
  Future<PromoCodeValidation> validatePromoCode({
    required String code,
    required double cartTotal,
    List<String>? productIds,
    bool? isFirstOrder,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/promotions/validate/'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'code': code,
          'cart_total': cartTotal,
          'product_ids': productIds,
          'is_first_order': isFirstOrder,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['is_valid'] == true) {
          final promotion = Promotion.fromJson(data['promotion']);
          final discountAmount = (data['discount_amount'] ?? 0).toDouble();

          return PromoCodeValidation.valid(promotion, discountAmount);
        } else {
          return PromoCodeValidation.invalid(
            data['error_message'] ?? 'Invalid promo code',
          );
        }
      } else {
        final data = jsonDecode(response.body);
        return PromoCodeValidation.invalid(
          data['error'] ?? 'Failed to validate promo code',
        );
      }
    } catch (e) {
      print('Error validating promo code: $e');
      return PromoCodeValidation.invalid('Error validating promo code');
    }
  }

  /// Apply automatic discounts
  Future<List<Promotion>> getApplicableAutomaticDiscounts({
    required double cartTotal,
    List<String>? productIds,
    List<String>? categoryIds,
    bool? isFirstOrder,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/promotions/automatic/'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'cart_total': cartTotal,
          'product_ids': productIds,
          'category_ids': categoryIds,
          'is_first_order': isFirstOrder,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> promotionsJson = data['applicable_promotions'] ?? [];

        return promotionsJson
            .map((json) => Promotion.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching automatic discounts: $e');
      return [];
    }
  }

  /// Get flash sales
  Future<List<FlashSale>> getActiveFlashSales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/flash-sales/active/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> flashSalesJson = data['results'] ?? data;

        final flashSales = flashSalesJson
            .map((json) => FlashSale.fromJson(json))
            .toList();

        // Cache flash sales
        await _cacheFlashSales(flashSales);

        return flashSales;
      } else {
        return _getCachedFlashSales();
      }
    } catch (e) {
      print('Error fetching flash sales: $e');
      return _getCachedFlashSales();
    }
  }

  /// Get upcoming flash sales
  Future<List<FlashSale>> getUpcomingFlashSales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/flash-sales/upcoming/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> flashSalesJson = data['results'] ?? data;

        return flashSalesJson
            .map((json) => FlashSale.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching upcoming flash sales: $e');
      return [];
    }
  }

  /// Get flash sale details
  Future<FlashSale?> getFlashSaleDetails(String flashSaleId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/flash-sales/$flashSaleId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FlashSale.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching flash sale details: $e');
      return null;
    }
  }

  /// Get bundle offers
  Future<List<BundleOffer>> getBundleOffers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/bundles/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> bundlesJson = data['results'] ?? data;

        final bundles = bundlesJson
            .map((json) => BundleOffer.fromJson(json))
            .toList();

        // Cache bundles
        await _cacheBundleOffers(bundles);

        return bundles;
      } else {
        return _getCachedBundleOffers();
      }
    } catch (e) {
      print('Error fetching bundle offers: $e');
      return _getCachedBundleOffers();
    }
  }

  /// Get bundle offer details
  Future<BundleOffer?> getBundleOfferDetails(String bundleId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/bundles/$bundleId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BundleOffer.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching bundle offer details: $e');
      return null;
    }
  }

  /// Get personalized promotions
  Future<List<Promotion>> getPersonalizedPromotions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/promotions/personalized/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> promotionsJson = data['results'] ?? data;

        return promotionsJson
            .map((json) => Promotion.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching personalized promotions: $e');
      return [];
    }
  }

  /// Calculate best discount for cart
  Future<Promotion?> calculateBestDiscount({
    required double cartTotal,
    List<String>? productIds,
    List<String>? categoryIds,
    String? promoCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/promotions/best-discount/'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'cart_total': cartTotal,
          'product_ids': productIds,
          'category_ids': categoryIds,
          'promo_code': promoCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['promotion'] != null) {
          return Promotion.fromJson(data['promotion']);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error calculating best discount: $e');
      return null;
    }
  }

  /// Track promotion usage
  Future<void> trackPromotionUsage(String promotionId, String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) return;

      await http.post(
        Uri.parse('$baseUrl/promotions/$promotionId/track-usage/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'order_id': orderId}),
      );
    } catch (e) {
      print('Error tracking promotion usage: $e');
    }
  }

  /// Cache promotions locally
  Future<void> _cachePromotions(List<Promotion> promotions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final promotionsJson = promotions.map((p) => p.toJson()).toList();
      await prefs.setString('cached_promotions', jsonEncode(promotionsJson));
    } catch (e) {
      print('Error caching promotions: $e');
    }
  }

  /// Get cached promotions
  Future<List<Promotion>> _getCachedPromotions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_promotions');

      if (cachedData != null) {
        final List<dynamic> promotionsJson = jsonDecode(cachedData);
        return promotionsJson.map((json) => Promotion.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error getting cached promotions: $e');
      return [];
    }
  }

  /// Cache flash sales locally
  Future<void> _cacheFlashSales(List<FlashSale> flashSales) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flashSalesJson = flashSales.map((f) => f.toJson()).toList();
      await prefs.setString('cached_flash_sales', jsonEncode(flashSalesJson));
    } catch (e) {
      print('Error caching flash sales: $e');
    }
  }

  /// Get cached flash sales
  Future<List<FlashSale>> _getCachedFlashSales() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_flash_sales');

      if (cachedData != null) {
        final List<dynamic> flashSalesJson = jsonDecode(cachedData);
        return flashSalesJson.map((json) => FlashSale.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error getting cached flash sales: $e');
      return [];
    }
  }

  /// Cache bundle offers locally
  Future<void> _cacheBundleOffers(List<BundleOffer> bundles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bundlesJson = bundles.map((b) => b.toJson()).toList();
      await prefs.setString('cached_bundle_offers', jsonEncode(bundlesJson));
    } catch (e) {
      print('Error caching bundle offers: $e');
    }
  }

  /// Get cached bundle offers
  Future<List<BundleOffer>> _getCachedBundleOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_bundle_offers');

      if (cachedData != null) {
        final List<dynamic> bundlesJson = jsonDecode(cachedData);
        return bundlesJson.map((json) => BundleOffer.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error getting cached bundle offers: $e');
      return [];
    }
  }

  /// Clear promotion cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_promotions');
      await prefs.remove('cached_flash_sales');
      await prefs.remove('cached_bundle_offers');
    } catch (e) {
      print('Error clearing promotion cache: $e');
    }
  }
}
