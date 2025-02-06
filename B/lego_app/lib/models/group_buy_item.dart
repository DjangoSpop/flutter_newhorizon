import 'package:intl/intl.dart';

class SizeDistribution {
  final Map<String, int> targetQuantities;
  final Map<String, int> currentQuantities;

  SizeDistribution({
    required this.targetQuantities,
    Map<String, int>? currentQuantities,
  }) : currentQuantities = currentQuantities ??
            Map.fromIterables(
                targetQuantities.keys, List.filled(targetQuantities.length, 0));

  int get totalTarget =>
      targetQuantities.values.fold(0, (sum, qty) => sum + qty);
  int get totalCurrent =>
      currentQuantities.values.fold(0, (sum, qty) => sum + qty);

  bool canAddSize(String size) =>
      currentQuantities[size]! < (targetQuantities[size] ?? 0);

  Map<String, int> get remainingQuantities {
    return Map.fromEntries(
      targetQuantities.entries.map(
        (e) => MapEntry(
          e.key,
          e.value - (currentQuantities[e.key] ?? 0),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'target_quantities': targetQuantities,
        'current_quantities': currentQuantities,
      };

  factory SizeDistribution.fromJson(Map<String, dynamic> json) {
    return SizeDistribution(
      targetQuantities: Map<String, int>.from(json['target_quantities']),
      currentQuantities: Map<String, int>.from(json['current_quantities']),
    );
  }
}

class Participant {
  final String userId;
  final String size;
  final DateTime joinedAt;
  final String paymentStatus;

  Participant({
    required this.userId,
    required this.size,
    required this.joinedAt,
    required this.paymentStatus,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'size': size,
        'joined_at': joinedAt.toIso8601String(),
        'payment_status': paymentStatus,
      };

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'],
      size: json['size'],
      joinedAt: DateTime.parse(json['joined_at']),
      paymentStatus: json['payment_status'],
    );
  }
}

class GroupBuyItem {
  final String id;
  final String name;
  final String description;
  final double originalPrice;
  final double groupBuyPrice;
  final String? parentGroupId;
  final bool isExpanded;
  final int minQuantity;
  final int maxQuantity;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String productId;
  final String sellerId;
  final SizeDistribution sizeDistribution;
  final List<Participant> participants;
  final String? imageUrl;
  final List<String> availableSizes;
  final String? colorOption;

  static const String STATUS_ACTIVE = 'ACTIVE';
  static const String STATUS_COMPLETED = 'COMPLETED';
  static const String STATUS_EXPIRED = 'EXPIRED';
  static const String PAYMENT_PENDING = 'PENDING';
  static const String PAYMENT_CONFIRMED = 'CONFIRMED';

  GroupBuyItem({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.groupBuyPrice,
    this.parentGroupId,
    this.isExpanded = false,
    required this.minQuantity,
    required this.maxQuantity,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.productId,
    required this.sellerId,
    required this.sizeDistribution,
    required this.participants,
    this.imageUrl,
    required this.availableSizes,
    this.colorOption,
  });

  factory GroupBuyItem.fromJson(Map<String, dynamic> json) {
    return GroupBuyItem(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      originalPrice: json['original_price'].toDouble(),
      groupBuyPrice: json['group_buy_price'].toDouble(),
      minQuantity: json['min_quantity'],
      maxQuantity: json['max_quantity'],
      status: json['status'],
      parentGroupId: json['parent_group_id'],
      isExpanded: json['is_expanded'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      productId: json['product_id'],
      sellerId: json['seller_id'],
      sizeDistribution: SizeDistribution.fromJson(json['size_distribution']),
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
      imageUrl: json['image_url'],
      availableSizes: List<String>.from(json['available_sizes']),
      colorOption: json['color_option'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'original_price': originalPrice,
      'group_buy_price': groupBuyPrice,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'status': status,
      'parent_group_id': parentGroupId,
      'is_expanded': isExpanded,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'product_id': productId,
      'seller_id': sellerId,
      'size_distribution': sizeDistribution.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'image_url': imageUrl,
      'available_sizes': availableSizes,
      'color_option': colorOption,
    };
  }

  // Formatted values
  String get formattedOriginalPrice =>
      NumberFormat.currency(symbol: '\$').format(originalPrice);
  String get formattedGroupBuyPrice =>
      NumberFormat.currency(symbol: '\$').format(groupBuyPrice);
  String get formattedStartDate => DateFormat('MMM d, yyyy').format(startDate);
  String get formattedEndDate => DateFormat('MMM d, yyyy').format(endDate);

  // Status checks
  bool get isActive => status == STATUS_ACTIVE;
  bool get isFull => sizeDistribution.totalCurrent >= maxQuantity;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isCompleted => status == STATUS_COMPLETED;
  bool get canBeExpanded =>
      isActive &&
      !isExpanded &&
      progress >= 0.8 &&
      endDate.difference(DateTime.now()).inDays >= 7;

  // Progress tracking
  double get progress => sizeDistribution.totalCurrent / minQuantity;
  String get progressText =>
      '${sizeDistribution.totalCurrent} / $minQuantity pieces';

  // Time management
  String get timeLeft {
    final difference = endDate.difference(DateTime.now());
    if (difference.isNegative) return 'Ended';
    if (difference.inDays > 0) return '${difference.inDays}d left';
    if (difference.inHours > 0) return '${difference.inHours}h left';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m left';
    return 'Ending soon';
  }

  // Price calculations
  double get savingsPercentage =>
      ((originalPrice - groupBuyPrice) / originalPrice) * 100;
  String get formattedSavingsPercentage =>
      '${savingsPercentage.toStringAsFixed(0)}% OFF';
//TODO: Implement setter for groupPrice
  set groupPrice(double groupPrice) {}

  // Participant management
  bool canJoin(String userId, String size) =>
      isActive &&
      !isFull &&
      !participants.any((p) => p.userId == userId) &&
      sizeDistribution.canAddSize(size);

  int getRemainingSizeQuantity(String size) =>
      sizeDistribution.remainingQuantities[size] ?? 0;

  List<Participant> getParticipantsForSize(String size) =>
      participants.where((p) => p.size == size).toList();

  bool isSizeAvailable(String size) => sizeDistribution.canAddSize(size);

  GroupBuyItem copyWith({
    String? id,
    String? name,
    String? description,
    double? originalPrice,
    double? groupBuyPrice,
    String? parentGroupId,
    bool? isExpanded,
    int? minQuantity,
    int? maxQuantity,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
    String? sellerId,
    SizeDistribution? sizeDistribution,
    List<Participant>? participants,
    String? imageUrl,
    List<String>? availableSizes,
    String? colorOption,
  }) {
    return GroupBuyItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      groupBuyPrice: groupBuyPrice ?? this.groupBuyPrice,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      parentGroupId: parentGroupId ?? this.parentGroupId,
      isExpanded: isExpanded ?? this.isExpanded,
      endDate: endDate ?? this.endDate,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      sizeDistribution: sizeDistribution ?? this.sizeDistribution,
      participants: participants ?? this.participants,
      imageUrl: imageUrl ?? this.imageUrl,
      availableSizes: availableSizes ?? this.availableSizes,
      colorOption: colorOption ?? this.colorOption,
    );
  }
}
