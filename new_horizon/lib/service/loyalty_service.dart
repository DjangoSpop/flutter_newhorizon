import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loyalty.dart';

class LoyaltyService extends GetxService {
  final String baseUrl = 'http://your-backend-url.com/api';

  /// Get loyalty wallet
  Future<LoyaltyWallet?> getWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return _getCachedWallet();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/loyalty/wallet/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final wallet = LoyaltyWallet.fromJson(data);

        // Cache wallet
        await _cacheWallet(wallet);

        return wallet;
      } else {
        return _getCachedWallet();
      }
    } catch (e) {
      print('Error fetching loyalty wallet: $e');
      return _getCachedWallet();
    }
  }

  /// Get transaction history
  Future<List<LoyaltyTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    LoyaltyTransactionType? type,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return [];
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type.toString().split('.').last,
      };

      final uri = Uri.parse('$baseUrl/loyalty/transactions/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> transactionsJson = data['results'] ?? data;

        return transactionsJson
            .map((json) => LoyaltyTransaction.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  /// Get available rewards
  Future<List<LoyaltyReward>> getAvailableRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/loyalty/rewards/'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rewardsJson = data['results'] ?? data;

        final rewards =
            rewardsJson.map((json) => LoyaltyReward.fromJson(json)).toList();

        // Cache rewards
        await _cacheRewards(rewards);

        return rewards;
      } else {
        return _getCachedRewards();
      }
    } catch (e) {
      print('Error fetching rewards: $e');
      return _getCachedRewards();
    }
  }

  /// Redeem reward
  Future<RedeemedReward?> redeemReward(String rewardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/loyalty/rewards/$rewardId/redeem/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RedeemedReward.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to redeem reward');
      }
    } catch (e) {
      print('Error redeeming reward: $e');
      rethrow;
    }
  }

  /// Get redeemed rewards
  Future<List<RedeemedReward>> getRedeemedRewards({
    RedemptionStatus? status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return [];
      }

      final queryParams = {
        if (status != null) 'status': status.toString().split('.').last,
      };

      final uri = Uri.parse('$baseUrl/loyalty/redeemed-rewards/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rewardsJson = data['results'] ?? data;

        return rewardsJson
            .map((json) => RedeemedReward.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching redeemed rewards: $e');
      return [];
    }
  }

  /// Use redeemed reward
  Future<bool> useRedeemedReward(String redeemedRewardId, String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/loyalty/redeemed-rewards/$redeemedRewardId/use/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'order_id': orderId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error using redeemed reward: $e');
      return false;
    }
  }

  /// Get referral code
  Future<String?> getReferralCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/loyalty/referral-code/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['referral_code'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching referral code: $e');
      return null;
    }
  }

  /// Get referrals
  Future<List<Referral>> getReferrals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/loyalty/referrals/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> referralsJson = data['results'] ?? data;

        return referralsJson.map((json) => Referral.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching referrals: $e');
      return [];
    }
  }

  /// Apply referral code (for new users)
  Future<bool> applyReferralCode(String referralCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/loyalty/apply-referral/'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'referral_code': referralCode}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error applying referral code: $e');
      return false;
    }
  }

  /// Earn points for action
  Future<int> earnPoints({
    required LoyaltyTransactionType type,
    String? orderId,
    String? referenceId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return 0;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/loyalty/earn-points/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'type': type.toString().split('.').last,
          'order_id': orderId,
          'reference_id': referenceId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['points_earned'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error earning points: $e');
      return 0;
    }
  }

  /// Calculate points for order
  Future<int> calculatePointsForOrder(double orderTotal) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/loyalty/calculate-points/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_total': orderTotal}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['points'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error calculating points: $e');
      return 0;
    }
  }

  /// Cache wallet locally
  Future<void> _cacheWallet(LoyaltyWallet wallet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_wallet', jsonEncode(wallet.toJson()));
    } catch (e) {
      print('Error caching wallet: $e');
    }
  }

  /// Get cached wallet
  Future<LoyaltyWallet?> _getCachedWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_wallet');

      if (cachedData != null) {
        return LoyaltyWallet.fromJson(jsonDecode(cachedData));
      }

      return null;
    } catch (e) {
      print('Error getting cached wallet: $e');
      return null;
    }
  }

  /// Cache rewards locally
  Future<void> _cacheRewards(List<LoyaltyReward> rewards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rewardsJson = rewards.map((r) => r.toJson()).toList();
      await prefs.setString('cached_rewards', jsonEncode(rewardsJson));
    } catch (e) {
      print('Error caching rewards: $e');
    }
  }

  /// Get cached rewards
  Future<List<LoyaltyReward>> _getCachedRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_rewards');

      if (cachedData != null) {
        final List<dynamic> rewardsJson = jsonDecode(cachedData);
        return rewardsJson.map((json) => LoyaltyReward.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error getting cached rewards: $e');
      return [];
    }
  }

  /// Clear loyalty cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_wallet');
      await prefs.remove('cached_rewards');
    } catch (e) {
      print('Error clearing loyalty cache: $e');
    }
  }
}
