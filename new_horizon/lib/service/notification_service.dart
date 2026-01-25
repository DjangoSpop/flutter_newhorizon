import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

/// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final String baseUrl = 'http://your-backend-url.com/api';
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  @override
  void onInit() {
    super.onInit();
    _initializeFCM();
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User declined notification permission');
        return;
      }

      // Get FCM token
      _fcmToken = await _fcm.getToken();
      print('FCM Token: $_fcmToken');

      // Send token to backend
      if (_fcmToken != null) {
        await _sendTokenToBackend(_fcmToken!);
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _sendTokenToBackend(newToken);
      });

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.notification?.title}');
        _handleMessage(message);
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification tapped: ${message.notification?.title}');
        _handleNotificationTap(message);
      });

      // Handle notification tap when app was terminated
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        print('No auth token found, skipping token upload');
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/register-device/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM token registered successfully');
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token to backend: $e');
    }
  }

  /// Handle incoming notification message
  void _handleMessage(RemoteMessage message) {
    // Create AppNotification from RemoteMessage
    final notification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: _getNotificationTypeFromData(message.data),
      timestamp: DateTime.now(),
      isRead: false,
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
    );

    // Save to local storage
    _saveNotificationLocally(notification);

    // Show local notification (if needed)
    // You can use flutter_local_notifications package for custom UI
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final type = _getNotificationTypeFromData(message.data);
    final data = message.data;

    // Navigate based on notification type
    switch (type) {
      case NotificationType.orderStatus:
      case NotificationType.orderConfirmed:
      case NotificationType.orderShipped:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
        final orderId = data['order_id'];
        if (orderId != null) {
          Get.toNamed('/order-details', arguments: {'orderId': orderId});
        }
        break;

      case NotificationType.promotion:
      case NotificationType.flashSale:
        final promotionId = data['promotion_id'];
        if (promotionId != null) {
          Get.toNamed('/promotion-details', arguments: {'promotionId': promotionId});
        }
        break;

      case NotificationType.priceAlert:
      case NotificationType.restockAlert:
        final productId = data['product_id'];
        if (productId != null) {
          Get.toNamed('/product-details', arguments: {'productId': productId});
        }
        break;

      case NotificationType.newArrival:
        Get.toNamed('/new-arrivals');
        break;

      case NotificationType.review:
        final orderId = data['order_id'];
        if (orderId != null) {
          Get.toNamed('/write-review', arguments: {'orderId': orderId});
        }
        break;

      case NotificationType.wishlist:
        Get.toNamed('/wishlist');
        break;

      case NotificationType.loyaltyPoints:
        Get.toNamed('/loyalty-wallet');
        break;

      default:
        Get.toNamed('/notifications');
    }
  }

  /// Get notification type from data payload
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    if (typeString == null) return NotificationType.general;

    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => NotificationType.general,
    );
  }

  /// Save notification to local storage
  Future<void> _saveNotificationLocally(AppNotification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications') ?? '[]';
      final List<dynamic> notifications = jsonDecode(notificationsJson);

      notifications.insert(0, notification.toJson());

      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }

      await prefs.setString('notifications', jsonEncode(notifications));
    } catch (e) {
      print('Error saving notification locally: $e');
    }
  }

  /// Fetch notifications from backend
  Future<List<AppNotification>> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return _getLocalNotifications();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notificationsJson = data['results'] ?? data;

        return notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();
      } else {
        return _getLocalNotifications();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return _getLocalNotifications();
    }
  }

  /// Get notifications from local storage
  Future<List<AppNotification>> _getLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications') ?? '[]';
      final List<dynamic> notifications = jsonDecode(notificationsJson);

      return notifications
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting local notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken != null) {
        await http.patch(
          Uri.parse('$baseUrl/notifications/$notificationId/mark-read/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        );
      }

      // Update local storage
      final notificationsJson = prefs.getString('notifications') ?? '[]';
      final List<dynamic> notifications = jsonDecode(notificationsJson);

      final updatedNotifications = notifications.map((json) {
        if (json['id'] == notificationId) {
          json['is_read'] = true;
        }
        return json;
      }).toList();

      await prefs.setString('notifications', jsonEncode(updatedNotifications));
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken != null) {
        await http.post(
          Uri.parse('$baseUrl/notifications/mark-all-read/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        );
      }

      // Update local storage
      final notificationsJson = prefs.getString('notifications') ?? '[]';
      final List<dynamic> notifications = jsonDecode(notificationsJson);

      final updatedNotifications = notifications.map((json) {
        json['is_read'] = true;
        return json;
      }).toList();

      await prefs.setString('notifications', jsonEncode(updatedNotifications));
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken != null) {
        await http.delete(
          Uri.parse('$baseUrl/notifications/$notificationId/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        );
      }

      // Update local storage
      final notificationsJson = prefs.getString('notifications') ?? '[]';
      final List<dynamic> notifications = jsonDecode(notificationsJson);

      notifications.removeWhere((json) => json['id'] == notificationId);

      await prefs.setString('notifications', jsonEncode(notifications));
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return _getLocalNotificationSettings();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/settings/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationSettings.fromJson(data);
      } else {
        return _getLocalNotificationSettings();
      }
    } catch (e) {
      print('Error fetching notification settings: $e');
      return _getLocalNotificationSettings();
    }
  }

  /// Get notification settings from local storage
  Future<NotificationSettings> _getLocalNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');

      if (settingsJson != null) {
        return NotificationSettings.fromJson(jsonDecode(settingsJson));
      }

      return NotificationSettings();
    } catch (e) {
      print('Error getting local notification settings: $e');
      return NotificationSettings();
    }
  }

  /// Update notification settings
  Future<NotificationSettings> updateNotificationSettings(
      NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken != null) {
        final response = await http.put(
          Uri.parse('$baseUrl/notifications/settings/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode(settings.toJson()),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final updatedSettings = NotificationSettings.fromJson(data);

          // Save to local storage
          await prefs.setString(
            'notification_settings',
            jsonEncode(updatedSettings.toJson()),
          );

          return updatedSettings;
        }
      }

      // Save to local storage
      await prefs.setString(
        'notification_settings',
        jsonEncode(settings.toJson()),
      );

      return settings;
    } catch (e) {
      print('Error updating notification settings: $e');
      return settings;
    }
  }

  /// Subscribe to topic (for category-based notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await _getLocalNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
