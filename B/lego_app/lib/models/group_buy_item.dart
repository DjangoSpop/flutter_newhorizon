import 'package:intl/intl.dart';

class GroupBuyItem {
  final String id;
  final String name;
  final String description;
  final double originalPrice;
  final double groupBuyPrice;
  final int minQuantity;
  final int maxQuantity;
  final int currentQuantity;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String productId;
  final String sellerId;
  final List<String> participantIds;

  GroupBuyItem({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.groupBuyPrice,
    required this.minQuantity,
    required this.maxQuantity,
    required this.currentQuantity,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.productId,
    required this.sellerId,
    required this.participantIds,
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
      currentQuantity: json['current_quantity'],
      status: json['status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      productId: json['product_id'],
      sellerId: json['seller_id'],
      participantIds: List<String>.from(json['participant_ids']),
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
      'current_quantity': currentQuantity,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'product_id': productId,
      'seller_id': sellerId,
      'participant_ids': participantIds,
    };
  }

  String get formattedOriginalPrice =>
      NumberFormat.currency(symbol: '\$').format(originalPrice);
  String get formattedGroupBuyPrice =>
      NumberFormat.currency(symbol: '\$').format(groupBuyPrice);
  String get formattedStartDate => DateFormat('MMM d, yyyy').format(startDate);
  String get formattedEndDate => DateFormat('MMM d, yyyy').format(endDate);

  bool get isActive => status == 'ACTIVE';
  bool get isFull => currentQuantity >= maxQuantity;
  bool get isExpired => DateTime.now().isAfter(endDate);

  double get progress => currentQuantity / minQuantity;
  String get progressText => '$currentQuantity / $minQuantity';

  String get timeLeft {
    final difference = endDate.difference(DateTime.now());
    if (difference.isNegative) return 'Ended';
    if (difference.inDays > 0) return '${difference.inDays}d left';
    if (difference.inHours > 0) return '${difference.inHours}h left';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m left';
    return 'Ending soon';
  }

  double get savingsPercentage =>
      ((originalPrice - groupBuyPrice) / originalPrice) * 100;
  String get formattedSavingsPercentage =>
      '${savingsPercentage.toStringAsFixed(0)}%';

  bool canJoin(String userId) =>
      isActive && !isFull && !participantIds.contains(userId);

  int get remainingQuantity => maxQuantity - currentQuantity;

  GroupBuyItem copyWith({
    String? id,
    String? name,
    String? description,
    double? originalPrice,
    double? groupBuyPrice,
    int? minQuantity,
    int? maxQuantity,
    int? currentQuantity,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
    String? sellerId,
    List<String>? participantIds,
  }) {
    return GroupBuyItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      groupBuyPrice: groupBuyPrice ?? this.groupBuyPrice,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      participantIds: participantIds ?? this.participantIds,
    );
  }
}
