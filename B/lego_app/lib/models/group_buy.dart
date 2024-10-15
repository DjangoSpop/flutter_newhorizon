// import 'package:intl/intl.dart';

// class GroupBuy {
//   final String id;
//   final String name;
//   final String description;
//   final double price;
//   final double discountedPrice;
//   final int minParticipants;
//   final int maxParticipants;
//   final int currentParticipants;
//   final DateTime startDate;
//   final DateTime endDate;
//   final String status;
//   final String productId;
//   final String productName;
//   final String sellerId;
//   final String sellerName;
//   final List<String> participantIds;

//   GroupBuy({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.discountedPrice,
//     required this.minParticipants,
//     required this.maxParticipants,
//     required this.currentParticipants,
//     required this.startDate,
//     required this.endDate,
//     required this.status,
//     required this.productId,
//     required this.productName,
//     required this.sellerId,
//     required this.sellerName,
//     required this.participantIds,
//   });

//   factory GroupBuy.fromJson(Map<String, dynamic> json) {
//     return GroupBuy(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       price: json['price'].toDouble(),
//       discountedPrice: json['discounted_price'].toDouble(),
//       minParticipants: json['min_participants'],
//       maxParticipants: json['max_participants'],
//       currentParticipants: json['current_participants'],
//       startDate: DateTime.parse(json['start_date']),
//       endDate: DateTime.parse(json['end_date']),
//       status: json['status'],
//       productId: json['product_id'],
//       productName: json['product_name'],
//       sellerId: json['seller_id'],
//       sellerName: json['seller_name'],
//       participantIds: List<String>.from(json['participant_ids']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'price': price,
//       'discounted_price': discountedPrice,
//       'min_participants': minParticipants,
//       'max_participants': maxParticipants,
//       'current_participants': currentParticipants,
//       'start_date': startDate.toIso8601String(),
//       'end_date': endDate.toIso8601String(),
//       'status': status,
//       'product_id': productId,
//       'product_name': productName,
//       'seller_id': sellerId,
//       'seller_name': sellerName,
//       'participant_ids': participantIds,
//     };
//   }

//   String get formattedPrice =>
//       NumberFormat.currency(symbol: '\$').format(price);
//   String get formattedDiscountedPrice =>
//       NumberFormat.currency(symbol: '\$').format(discountedPrice);
//   String get formattedStartDate => DateFormat('MMM d, yyyy').format(startDate);
//   String get formattedEndDate => DateFormat('MMM d, yyyy').format(endDate);

//   bool get isActive => status == 'ACTIVE';
//   bool get isFull => currentParticipants >= maxParticipants;
//   bool get isExpired => DateTime.now().isAfter(endDate);

//   double get progress => currentParticipants / minParticipants;
//   String get progressText => '$currentParticipants / $minParticipants';

//   String get timeLeft {
//     final difference = endDate.difference(DateTime.now());
//     if (difference.isNegative) return 'Ended';
//     if (difference.inDays > 0) return '${difference.inDays}d left';
//     if (difference.inHours > 0) return '${difference.inHours}h left';
//     if (difference.inMinutes > 0) return '${difference.inMinutes}m left';
//     return 'Ending soon';
//   }

//   double get savingsPercentage => ((price - discountedPrice) / price) * 100;
//   String get formattedSavingsPercentage =>
//       '${savingsPercentage.toStringAsFixed(0)}%';

//   bool canJoin(String userId) =>
//       isActive && !isFull && !participantIds.contains(userId);

//   GroupBuy copyWith({
//     String? id,
//     String? name,
//     String? description,
//     double? price,
//     double? discountedPrice,
//     int? minParticipants,
//     int? maxParticipants,
//     int? currentParticipants,
//     DateTime? startDate,
//     DateTime? endDate,
//     String? status,
//     String? productId,
//     String? productName,
//     String? sellerId,
//     String? sellerName,
//     List<String>? participantIds,
//   }) {
//     return GroupBuy(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       description: description ?? this.description,
//       price: price ?? this.price,
//       discountedPrice: discountedPrice ?? this.discountedPrice,
//       minParticipants: minParticipants ?? this.minParticipants,
//       maxParticipants: maxParticipants ?? this.maxParticipants,
//       currentParticipants: currentParticipants ?? this.currentParticipants,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       status: status ?? this.status,
//       productId: productId ?? this.productId,
//       productName: productName ?? this.productName,
//       sellerId: sellerId ?? this.sellerId,
//       sellerName: sellerName ?? this.sellerName,
//       participantIds: participantIds ?? this.participantIds,
//     );
//   }
// }
