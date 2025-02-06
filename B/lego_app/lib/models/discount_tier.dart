// DiscountTier model class
class DiscountTier {
  final int participantCount; // Minimum participants required for this tier
  final double discountPercentage; // Discount percentage applied at this tier

  DiscountTier({
    required this.participantCount,
    required this.discountPercentage,
  });

  // Convert JSON data to DiscountTier object
  factory DiscountTier.fromJson(Map<String, dynamic> json) {
    return DiscountTier(
      participantCount: json['participantCount'] as int,
      discountPercentage: json['discountPercentage'] as double,
    );
  }

  // Convert DiscountTier object to JSON
  Map<String, dynamic> toJson() {
    return {
      'participantCount': participantCount,
      'discountPercentage': discountPercentage,
    };
  }
}
