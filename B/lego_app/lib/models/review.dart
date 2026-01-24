import 'package:uuid/uuid.dart';

/// Product review model
class Review {
  String id;
  String productId;
  String userId;
  String userName;
  String? userAvatar;
  int rating; // 1-5
  String? title;
  String comment;
  List<String> images;
  bool isVerifiedPurchase;
  int helpfulCount;
  bool isHelpful; // Current user marked as helpful
  DateTime createdAt;
  DateTime? updatedAt;

  Review({
    String? id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.title,
    required this.comment,
    this.images = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.isHelpful = false,
    DateTime? createdAt,
    this.updatedAt,
  })  : this.id = id ?? Uuid().v4(),
        this.createdAt = createdAt ?? DateTime.now(),
        assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');

  /// Get time ago string
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['productId'] ?? json['product_id'],
      userId: json['userId'] ?? json['user_id'],
      userName: json['userName'] ?? json['user_name'],
      userAvatar: json['userAvatar'] ?? json['user_avatar'],
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      isVerifiedPurchase:
          json['isVerifiedPurchase'] ?? json['is_verified_purchase'] ?? false,
      helpfulCount: json['helpfulCount'] ?? json['helpful_count'] ?? 0,
      isHelpful: json['isHelpful'] ?? json['is_helpful'] ?? false,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'isHelpful': isHelpful,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to API JSON (snake_case)
  Map<String, dynamic> toApiJson() {
    return {
      'product_id': productId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
    };
  }

  /// Create a copy with updated fields
  Review copyWith({
    int? rating,
    String? title,
    String? comment,
    List<String>? images,
    int? helpfulCount,
    bool? isHelpful,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id,
      productId: productId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isVerifiedPurchase: isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isHelpful: isHelpful ?? this.isHelpful,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// Review summary for a product
class ReviewSummary {
  int totalReviews;
  double averageRating;
  Map<int, int> ratingDistribution; // star -> count
  int verifiedPurchases;

  ReviewSummary({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.verifiedPurchases,
  });

  /// Get percentage for a specific rating
  double getPercentage(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }

  /// Create from JSON
  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      totalReviews: json['totalReviews'] ?? json['total_reviews'] ?? 0,
      averageRating:
          (json['averageRating'] ?? json['average_rating'] ?? 0.0).toDouble(),
      ratingDistribution:
          Map<int, int>.from(json['ratingDistribution'] ?? json['rating_distribution'] ?? {}),
      verifiedPurchases:
          json['verifiedPurchases'] ?? json['verified_purchases'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
      'verifiedPurchases': verifiedPurchases,
    };
  }

  /// Create empty summary
  factory ReviewSummary.empty() {
    return ReviewSummary(
      totalReviews: 0,
      averageRating: 0.0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      verifiedPurchases: 0,
    );
  }
}
