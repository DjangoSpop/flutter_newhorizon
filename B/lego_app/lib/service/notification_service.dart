import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationType { groupBuy, order, payment, reminder, system }

typedef NotificationHandler = Future<void> Function(Map<String, dynamic> data);

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _isInitialized = false.obs;
  final _pendingNotifications = <Future<void> Function()>[];
  final Map<String, NotificationHandler> _handlers = {};

  // Channel IDs
  static const String _mainChannelId = 'group_buy_channel';
  static const String _mainChannelName = 'Group Buy Notifications';
  static const String _mainChannelDesc =
      'Notifications for group buy events and updates';

  bool get isInitialized => _isInitialized.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeService();
  }

  Future<NotificationService> init() async {
    await _initializeService();
    return this;
  }

  Future<void> _initializeService() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Initialize platform settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      _isInitialized.value = true;

      // Process pending notifications
      await _processPendingNotifications();
    } catch (e) {
      print('Error initializing NotificationService: $e');
      _isInitialized.value = false;
    }
  }

  Future<void> _processPendingNotifications() async {
    while (_pendingNotifications.isNotEmpty) {
      final notification = _pendingNotifications.removeAt(0);
      await notification();
    }
  }

  NotificationDetails _createNotificationDetails({
    String? channelId,
    String? channelName,
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    bool enableVibration = true,
    bool enableLights = true,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _mainChannelId,
      channelName ?? _mainChannelName,
      channelDescription: channelDescription ?? _mainChannelDesc,
      importance: importance,
      priority: priority,
      enableVibration: enableVibration,
      enableLights: enableLights,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    String? channelId,
  }) async {
    final notificationFunc = () async {
      try {
        if (title.isEmpty || body.isEmpty) {
          throw ArgumentError('Title and body cannot be empty');
        }

        final details = _createNotificationDetails(
          channelId: channelId,
        );

        final id = DateTime.now().millisecondsSinceEpoch;
        final payload = json.encode({
          'type': type.toString(),
          ...?data,
        });

        await _notificationsPlugin.show(
          id,
          title,
          body,
          details,
          payload: payload,
        );
      } catch (e) {
        print('Error sending notification: $e');
      }
    };

    if (!_isInitialized.value) {
      _pendingNotifications.add(notificationFunc);
    } else {
      await notificationFunc();
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationType type,
    Map<String, dynamic>? data,
    String? channelId,
  }) async {
    try {
      if (title.isEmpty || body.isEmpty) {
        throw ArgumentError('Title and body cannot be empty');
      }

      final details = _createNotificationDetails(
        channelId: channelId,
      );

      final id = DateTime.now().millisecondsSinceEpoch;
      final payload = json.encode({
        'type': type.toString(),
        ...?data,
      });

      final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        throw ArgumentError('Scheduled time must be in the future');
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  void registerHandler(NotificationType type, NotificationHandler handler) {
    _handlers[type.toString()] = handler;
  }

  Future<void> _handleNotificationResponse(
      NotificationResponse response) async {
    if (response.payload == null) return;

    try {
      final data = json.decode(response.payload!);
      final handler = _handlers[data['type']];

      if (handler != null) {
        await handler(data);
      } else {
        print('No handler registered for type: ${data['type']}');
      }
    } catch (e) {
      print('Error handling notification response: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }
}
