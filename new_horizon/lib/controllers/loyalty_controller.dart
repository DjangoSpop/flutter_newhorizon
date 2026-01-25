import 'package:get/get.dart';
import '../models/loyalty.dart';
import '../service/loyalty_service.dart';

class LoyaltyController extends GetxController {
  final LoyaltyService _loyaltyService = Get.find<LoyaltyService>();

  // Observable state
  var wallet = Rx<LoyaltyWallet?>(null);
  var transactions = <LoyaltyTransaction>[].obs;
  var availableRewards = <LoyaltyReward>[].obs;
  var redeemedRewards = <RedeemedReward>[].obs;
  var activeRedeemedRewards = <RedeemedReward>[].obs;
  var referrals = <Referral>[].obs;
  var referralCode = ''.obs;

  var isLoading = false.obs;
  var isLoadingTransactions = false.obs;
  var isLoadingRewards = false.obs;
  var hasMoreTransactions = true.obs;
  var currentTransactionPage = 1.obs;

  // Filtered transactions
  var selectedTransactionFilter = Rx<LoyaltyTransactionType?>(null);

  @override
  void onInit() {
    super.onInit();
    loadWallet();
    loadTransactions();
    loadAvailableRewards();
    loadRedeemedRewards();
    loadReferralCode();
  }

  /// Load loyalty wallet
  Future<void> loadWallet() async {
    try {
      isLoading.value = true;
      final walletData = await _loyaltyService.getWallet();
      wallet.value = walletData;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load loyalty wallet',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load transaction history
  Future<void> loadTransactions({bool resetPage = false}) async {
    if (resetPage) {
      currentTransactionPage.value = 1;
      hasMoreTransactions.value = true;
    }

    if (isLoadingTransactions.value) return;

    try {
      isLoadingTransactions.value = true;

      final fetchedTransactions = await _loyaltyService.getTransactions(
        page: currentTransactionPage.value,
        limit: 20,
        type: selectedTransactionFilter.value,
      );

      if (currentTransactionPage.value == 1) {
        transactions.value = fetchedTransactions;
      } else {
        transactions.addAll(fetchedTransactions);
      }

      if (fetchedTransactions.length < 20) {
        hasMoreTransactions.value = false;
      }

      currentTransactionPage.value++;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load transactions',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  /// Load more transactions
  Future<void> loadMoreTransactions() async {
    if (hasMoreTransactions.value && !isLoadingTransactions.value) {
      await loadTransactions();
    }
  }

  /// Filter transactions by type
  Future<void> filterTransactions(LoyaltyTransactionType? type) async {
    selectedTransactionFilter.value = type;
    await loadTransactions(resetPage: true);
  }

  /// Load available rewards
  Future<void> loadAvailableRewards() async {
    try {
      isLoadingRewards.value = true;
      final rewards = await _loyaltyService.getAvailableRewards();
      availableRewards.value = rewards;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load rewards',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRewards.value = false;
    }
  }

  /// Load redeemed rewards
  Future<void> loadRedeemedRewards() async {
    try {
      final redeemed = await _loyaltyService.getRedeemedRewards();
      redeemedRewards.value = redeemed;

      // Filter active rewards
      activeRedeemedRewards.value = redeemed
          .where((r) => r.status == RedemptionStatus.active && !r.isExpired)
          .toList();
    } catch (e) {
      print('Error loading redeemed rewards: $e');
    }
  }

  /// Redeem reward
  Future<bool> redeemReward(String rewardId) async {
    try {
      isLoading.value = true;

      // Check if user has enough points
      final reward = availableRewards.firstWhere((r) => r.id == rewardId);
      if (wallet.value == null ||
          wallet.value!.availablePoints < reward.pointsRequired) {
        Get.snackbar(
          'Error',
          'Not enough points to redeem this reward',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final redeemedReward = await _loyaltyService.redeemReward(rewardId);

      if (redeemedReward != null) {
        // Refresh wallet and rewards
        await Future.wait([
          loadWallet(),
          loadTransactions(resetPage: true),
          loadRedeemedRewards(),
        ]);

        Get.snackbar(
          'Success',
          'Reward redeemed successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to redeem reward',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Use redeemed reward for order
  Future<bool> useRedeemedReward(String redeemedRewardId, String orderId) async {
    try {
      final success = await _loyaltyService.useRedeemedReward(
        redeemedRewardId,
        orderId,
      );

      if (success) {
        await loadRedeemedRewards();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error using redeemed reward: $e');
      return false;
    }
  }

  /// Load referral code
  Future<void> loadReferralCode() async {
    try {
      final code = await _loyaltyService.getReferralCode();
      if (code != null) {
        referralCode.value = code;
      }
    } catch (e) {
      print('Error loading referral code: $e');
    }
  }

  /// Load referrals
  Future<void> loadReferrals() async {
    try {
      final refs = await _loyaltyService.getReferrals();
      referrals.value = refs;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load referrals',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Apply referral code
  Future<bool> applyReferralCode(String code) async {
    try {
      isLoading.value = true;

      final success = await _loyaltyService.applyReferralCode(code);

      if (success) {
        Get.snackbar(
          'Success',
          'Referral code applied! You earned bonus points',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Refresh wallet
        await loadWallet();

        return true;
      } else {
        Get.snackbar(
          'Error',
          'Invalid or expired referral code',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to apply referral code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Earn points for action
  Future<void> earnPoints({
    required LoyaltyTransactionType type,
    String? orderId,
    String? referenceId,
  }) async {
    try {
      final pointsEarned = await _loyaltyService.earnPoints(
        type: type,
        orderId: orderId,
        referenceId: referenceId,
      );

      if (pointsEarned > 0) {
        // Refresh wallet and transactions
        await Future.wait([
          loadWallet(),
          loadTransactions(resetPage: true),
        ]);

        Get.snackbar(
          'Points Earned!',
          'You earned $pointsEarned points',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error earning points: $e');
    }
  }

  /// Calculate points for order
  Future<int> calculatePointsForOrder(double orderTotal) async {
    try {
      return await _loyaltyService.calculatePointsForOrder(orderTotal);
    } catch (e) {
      print('Error calculating points: $e');
      return 0;
    }
  }

  /// Refresh all loyalty data
  Future<void> refreshLoyaltyData() async {
    await Future.wait([
      loadWallet(),
      loadTransactions(resetPage: true),
      loadAvailableRewards(),
      loadRedeemedRewards(),
    ]);
  }

  /// Get rewards that user can afford
  List<LoyaltyReward> get affordableRewards {
    if (wallet.value == null) return [];

    return availableRewards
        .where((r) =>
            r.isAvailable && r.pointsRequired <= wallet.value!.availablePoints)
        .toList();
  }

  /// Get rewards user cannot afford yet
  List<LoyaltyReward> get unaffordableRewards {
    if (wallet.value == null) return availableRewards;

    return availableRewards
        .where((r) =>
            r.isAvailable && r.pointsRequired > wallet.value!.availablePoints)
        .toList();
  }

  /// Get expiring soon redeemed rewards
  List<RedeemedReward> get expiringSoonRewards {
    return redeemedRewards.where((r) => r.reward.isExpiringSoon).toList();
  }

  /// Get completed referrals count
  int get completedReferralsCount {
    return referrals
        .where((r) => r.status == ReferralStatus.completed)
        .length;
  }

  /// Get total points earned from referrals
  int get totalReferralPoints {
    return referrals.fold(0, (sum, ref) => sum + ref.pointsEarned);
  }

  /// Check if user can redeem reward
  bool canRedeemReward(LoyaltyReward reward) {
    if (wallet.value == null) return false;
    return reward.isAvailable &&
        wallet.value!.availablePoints >= reward.pointsRequired;
  }

  /// Get tier progress percentage
  double get tierProgressPercentage {
    return wallet.value?.tierProgress ?? 0.0;
  }

  /// Get points needed for next tier
  int get pointsToNextTier {
    return wallet.value?.pointsToNextTier ?? 0;
  }

  /// Clear loyalty cache
  Future<void> clearCache() async {
    try {
      await _loyaltyService.clearCache();
      wallet.value = null;
      transactions.clear();
      availableRewards.clear();
      redeemedRewards.clear();
      activeRedeemedRewards.clear();
      referrals.clear();
      referralCode.value = '';
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
