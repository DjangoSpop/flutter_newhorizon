// notification_types.dart

import 'package:flutter/foundation.dart';

/// Callback type for notification handlers
typedef NotificationHandler = Future<void> Function(NotificationData data);

/// Defines the types of notifications in the system
enum NotificationType { groupBuy, order, payment, reminder, system }

/// Data model for notifications
class NotificationData {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  NotificationData({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.system,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'title': title,
        'body': body,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() => 'NotificationData(id: $id, type: $type, title: $title)';
}

/// Mixin for classes that need to handle notifications
mixin NotificationHandlerMixin {
  final Map<NotificationType, NotificationHandler> _handlers = {};

  void registerNotificationHandler(
    NotificationType type,
    NotificationHandler handler,
  ) {
    _handlers[type] = handler;
  }

  Future<void> handleNotification(NotificationData data) async {
    final handler = _handlers[data.type];
    if (handler != null) {
      try {
        await handler(data);
      } catch (e) {
        debugPrint('Error handling notification: $e');
      }
    }
  }
}
