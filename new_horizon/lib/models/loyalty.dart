/// Loyalty wallet model
class LoyaltyWallet {
  final String id;
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final int expiredPoints;
  final String tier;
  final double tierProgress;
  final String? nextTier;
  final int? pointsToNextTier;
  final List<LoyaltyTierBenefit> tierBenefits;
  final DateTime? lastUpdated;

  LoyaltyWallet({
    required this.id,
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.usedPoints,
    required this.expiredPoints,
    required this.tier,
    required this.tierProgress,
    this.nextTier,
    this.pointsToNextTier,
    this.tierBenefits = const [],
    this.lastUpdated,
  });

  factory LoyaltyWallet.fromJson(Map<String, dynamic> json) {
    return LoyaltyWallet(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      availablePoints: json['available_points'] ?? 0,
      usedPoints: json['used_points'] ?? 0,
      expiredPoints: json['expired_points'] ?? 0,
      tier: json['tier'] ?? 'Bronze',
      tierProgress: (json['tier_progress'] ?? 0).toDouble(),
      nextTier: json['next_tier'],
      pointsToNextTier: json['points_to_next_tier'],
      tierBenefits: (json['tier_benefits'] as List?)
              ?.map((b) => LoyaltyTierBenefit.fromJson(b))
              .toList() ??
          [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_points': totalPoints,
      'available_points': availablePoints,
      'used_points': usedPoints,
      'expired_points': expiredPoints,
      'tier': tier,
      'tier_progress': tierProgress,
      'next_tier': nextTier,
      'points_to_next_tier': pointsToNextTier,
      'tier_benefits': tierBenefits.map((b) => b.toJson()).toList(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  double get pointsValue {
    // 100 points = $1
    return availablePoints / 100;
  }
}

class LoyaltyTierBenefit {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isActive;

  LoyaltyTierBenefit({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isActive = true,
  });

  factory LoyaltyTierBenefit.fromJson(Map<String, dynamic> json) {
    return LoyaltyTierBenefit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_active': isActive,
    };
  }
}

/// Loyalty transaction model
class LoyaltyTransaction {
  final String id;
  final String userId;
  final LoyaltyTransactionType type;
  final int points;
  final String description;
  final String? orderId;
  final String? referenceId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final LoyaltyTransactionStatus status;

  LoyaltyTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.description,
    this.orderId,
    this.referenceId,
    required this.createdAt,
    this.expiresAt,
    this.status = LoyaltyTransactionStatus.completed,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: LoyaltyTransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => LoyaltyTransactionType.purchase,
      ),
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      orderId: json['order_id'],
      referenceId: json['reference_id'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      status: LoyaltyTransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => LoyaltyTransactionStatus.completed,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'points': points,
      'description': description,
      'order_id': orderId,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  bool get isCredit => points > 0;
  bool get isDebit => points < 0;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  String get formattedPoints {
    if (isCredit) {
      return '+$points';
    } else {
      return '$points';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

enum LoyaltyTransactionType {
  purchase,
  refund,
  redemption,
  signup,
  referral,
  review,
  birthday,
  bonus,
  expired,
  adjustment,
}

enum LoyaltyTransactionStatus {
  pending,
  completed,
  cancelled,
  expired,
}

/// Loyalty reward model
class LoyaltyReward {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final RewardType type;
  final double? discountValue;
  final DiscountType? discountType;
  final String? productId;
  final String? imageUrl;
  final bool isActive;
  final int? stockQuantity;
  final int? usageLimit;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? terms;

  LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.type,
    this.discountValue,
    this.discountType,
    this.productId,
    this.imageUrl,
    this.isActive = true,
    this.stockQuantity,
    this.usageLimit,
    this.validFrom,
    this.validUntil,
    this.terms,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pointsRequired: json['points_required'] ?? 0,
      type: RewardType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => RewardType.discount,
      ),
      discountValue: json['discount_value']?.toDouble(),
      discountType: json['discount_type'] != null
          ? DiscountType.values.firstWhere(
              (e) => e.toString().split('.').last == json['discount_type'],
              orElse: () => DiscountType.percentage,
            )
          : null,
      productId: json['product_id'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      stockQuantity: json['stock_quantity'],
      usageLimit: json['usage_limit'],
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      terms: json['terms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'points_required': pointsRequired,
      'type': type.toString().split('.').last,
      'discount_value': discountValue,
      'discount_type': discountType?.toString().split('.').last,
      'product_id': productId,
      'image_url': imageUrl,
      'is_active': isActive,
      'stock_quantity': stockQuantity,
      'usage_limit': usageLimit,
      'valid_from': validFrom?.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'terms': terms,
    };
  }

  bool get isAvailable {
    if (!isActive) return false;
    if (stockQuantity != null && stockQuantity! <= 0) return false;

    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;

    return true;
  }

  bool get isExpiringSoon {
    if (validUntil == null) return false;
    final daysUntilExpiry = validUntil!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }
}

enum RewardType {
  discount,
  freeShipping,
  freeProduct,
  cashback,
}

enum DiscountType {
  percentage,
  fixed,
}

/// Redeemed reward model
class RedeemedReward {
  final String id;
  final String userId;
  final String rewardId;
  final LoyaltyReward reward;
  final int pointsUsed;
  final String? code;
  final DateTime redeemedAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;
  final String? orderId;
  final RedemptionStatus status;

  RedeemedReward({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.reward,
    required this.pointsUsed,
    this.code,
    required this.redeemedAt,
    this.expiresAt,
    this.usedAt,
    this.orderId,
    this.status = RedemptionStatus.active,
  });

  factory RedeemedReward.fromJson(Map<String, dynamic> json) {
    return RedeemedReward(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      rewardId: json['reward_id'] ?? '',
      reward: LoyaltyReward.fromJson(json['reward']),
      pointsUsed: json['points_used'] ?? 0,
      code: json['code'],
      redeemedAt: DateTime.parse(json['redeemed_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      usedAt:
          json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      orderId: json['order_id'],
      status: RedemptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RedemptionStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reward_id': rewardId,
      'reward': reward.toJson(),
      'points_used': pointsUsed,
      'code': code,
      'redeemed_at': redeemedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'order_id': orderId,
      'status': status.toString().split('.').last,
    };
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isUsed => status == RedemptionStatus.used;
  bool get isActive => status == RedemptionStatus.active && !isExpired;

  String get expiryStatus {
    if (isExpired) return 'Expired';
    if (isUsed) return 'Used';
    if (expiresAt != null) {
      final daysLeft = expiresAt!.difference(DateTime.now()).inDays;
      if (daysLeft == 0) return 'Expires today';
      if (daysLeft == 1) return 'Expires tomorrow';
      return 'Expires in $daysLeft days';
    }
    return 'Active';
  }
}

enum RedemptionStatus {
  active,
  used,
  expired,
  cancelled,
}

/// Referral model
class Referral {
  final String id;
  final String referrerId;
  final String? referredUserId;
  final String referralCode;
  final ReferralStatus status;
  final int pointsEarned;
  final DateTime createdAt;
  final DateTime? completedAt;

  Referral({
    required this.id,
    required this.referrerId,
    this.referredUserId,
    required this.referralCode,
    this.status = ReferralStatus.pending,
    this.pointsEarned = 0,
    required this.createdAt,
    this.completedAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] ?? '',
      referrerId: json['referrer_id'] ?? '',
      referredUserId: json['referred_user_id'],
      referralCode: json['referral_code'] ?? '',
      status: ReferralStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReferralStatus.pending,
      ),
      pointsEarned: json['points_earned'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referred_user_id': referredUserId,
      'referral_code': referralCode,
      'status': status.toString().split('.').last,
      'points_earned': pointsEarned,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

enum ReferralStatus {
  pending,
  completed,
  expired,
}
