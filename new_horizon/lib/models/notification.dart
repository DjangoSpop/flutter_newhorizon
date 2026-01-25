/// Notification model for handling push notifications
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.imageUrl,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.general,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      data: json['data'],
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'data': data,
      'image_url': imageUrl,
      'action_url': actionUrl,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

enum NotificationType {
  general,
  orderStatus,
  orderConfirmed,
  orderShipped,
  orderDelivered,
  orderCancelled,
  promotion,
  flashSale,
  priceAlert,
  restockAlert,
  newArrival,
  review,
  wishlist,
  payment,
  loyaltyPoints,
}

class NotificationSettings {
  final bool orderUpdates;
  final bool promotions;
  final bool priceAlerts;
  final bool restockAlerts;
  final bool newArrivals;
  final bool reviewReminders;
  final bool wishlistUpdates;
  final bool loyaltyPointsUpdates;
  final bool emailNotifications;
  final bool smsNotifications;

  NotificationSettings({
    this.orderUpdates = true,
    this.promotions = true,
    this.priceAlerts = true,
    this.restockAlerts = true,
    this.newArrivals = true,
    this.reviewReminders = true,
    this.wishlistUpdates = true,
    this.loyaltyPointsUpdates = true,
    this.emailNotifications = false,
    this.smsNotifications = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      orderUpdates: json['order_updates'] ?? true,
      promotions: json['promotions'] ?? true,
      priceAlerts: json['price_alerts'] ?? true,
      restockAlerts: json['restock_alerts'] ?? true,
      newArrivals: json['new_arrivals'] ?? true,
      reviewReminders: json['review_reminders'] ?? true,
      wishlistUpdates: json['wishlist_updates'] ?? true,
      loyaltyPointsUpdates: json['loyalty_points_updates'] ?? true,
      emailNotifications: json['email_notifications'] ?? false,
      smsNotifications: json['sms_notifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_updates': orderUpdates,
      'promotions': promotions,
      'price_alerts': priceAlerts,
      'restock_alerts': restockAlerts,
      'new_arrivals': newArrivals,
      'review_reminders': reviewReminders,
      'wishlist_updates': wishlistUpdates,
      'loyalty_points_updates': loyaltyPointsUpdates,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
    };
  }

  NotificationSettings copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? priceAlerts,
    bool? restockAlerts,
    bool? newArrivals,
    bool? reviewReminders,
    bool? wishlistUpdates,
    bool? loyaltyPointsUpdates,
    bool? emailNotifications,
    bool? smsNotifications,
  }) {
    return NotificationSettings(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      restockAlerts: restockAlerts ?? this.restockAlerts,
      newArrivals: newArrivals ?? this.newArrivals,
      reviewReminders: reviewReminders ?? this.reviewReminders,
      wishlistUpdates: wishlistUpdates ?? this.wishlistUpdates,
      loyaltyPointsUpdates: loyaltyPointsUpdates ?? this.loyaltyPointsUpdates,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
    );
  }
}
