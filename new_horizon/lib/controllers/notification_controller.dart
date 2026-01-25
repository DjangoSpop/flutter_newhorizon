import 'package:get/get.dart';
import '../models/notification.dart';
import '../service/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();

  // Observable state
  var notifications = <AppNotification>[].obs;
  var unreadNotifications = <AppNotification>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreNotifications = true.obs;
  var currentPage = 1.obs;
  var unreadCount = 0.obs;
  var notificationSettings = Rx<NotificationSettings?>(null);

  // Filters
  var selectedFilter = NotificationFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadNotificationSettings();
    _updateUnreadCount();
  }

  /// Load notifications with pagination
  Future<void> loadNotifications({bool resetPage = false}) async {
    if (resetPage) {
      currentPage.value = 1;
      hasMoreNotifications.value = true;
    }

    if (isLoading.value || isLoadingMore.value) return;

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final fetchedNotifications = await _notificationService.fetchNotifications(
        page: currentPage.value,
        limit: 20,
      );

      if (currentPage.value == 1) {
        notifications.value = fetchedNotifications;
      } else {
        notifications.addAll(fetchedNotifications);
      }

      if (fetchedNotifications.length < 20) {
        hasMoreNotifications.value = false;
      }

      currentPage.value++;
      _updateUnreadCount();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load notifications',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more notifications
  Future<void> loadMoreNotifications() async {
    if (hasMoreNotifications.value && !isLoadingMore.value) {
      await loadNotifications();
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications(resetPage: true);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        notifications.refresh();
      }

      _updateUnreadCount();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;
      await _notificationService.markAllAsRead();

      // Update local state
      notifications.value = notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      unreadCount.value = 0;
      unreadNotifications.clear();

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Remove from local state
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();

      Get.snackbar(
        'Success',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Update unread count
  void _updateUnreadCount() {
    unreadNotifications.value = notifications.where((n) => !n.isRead).toList();
    unreadCount.value = unreadNotifications.length;
  }

  /// Get filtered notifications
  List<AppNotification> get filteredNotifications {
    switch (selectedFilter.value) {
      case NotificationFilter.unread:
        return unreadNotifications;
      case NotificationFilter.orders:
        return notifications.where((n) =>
          n.type == NotificationType.orderStatus ||
          n.type == NotificationType.orderConfirmed ||
          n.type == NotificationType.orderShipped ||
          n.type == NotificationType.orderDelivered ||
          n.type == NotificationType.orderCancelled
        ).toList();
      case NotificationFilter.promotions:
        return notifications.where((n) =>
          n.type == NotificationType.promotion ||
          n.type == NotificationType.flashSale
        ).toList();
      case NotificationFilter.alerts:
        return notifications.where((n) =>
          n.type == NotificationType.priceAlert ||
          n.type == NotificationType.restockAlert
        ).toList();
      case NotificationFilter.all:
      default:
        return notifications;
    }
  }

  /// Change filter
  void changeFilter(NotificationFilter filter) {
    selectedFilter.value = filter;
  }

  /// Load notification settings
  Future<void> loadNotificationSettings() async {
    try {
      final settings = await _notificationService.getNotificationSettings();
      notificationSettings.value = settings;
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      isLoading.value = true;
      final updatedSettings = await _notificationService.updateNotificationSettings(settings);
      notificationSettings.value = updatedSettings;

      Get.snackbar(
        'Success',
        'Notification settings updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update settings',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle specific notification setting
  Future<void> toggleSetting(String settingKey, bool value) async {
    if (notificationSettings.value == null) return;

    NotificationSettings updatedSettings;

    switch (settingKey) {
      case 'orderUpdates':
        updatedSettings = notificationSettings.value!.copyWith(orderUpdates: value);
        break;
      case 'promotions':
        updatedSettings = notificationSettings.value!.copyWith(promotions: value);
        break;
      case 'priceAlerts':
        updatedSettings = notificationSettings.value!.copyWith(priceAlerts: value);
        break;
      case 'restockAlerts':
        updatedSettings = notificationSettings.value!.copyWith(restockAlerts: value);
        break;
      case 'newArrivals':
        updatedSettings = notificationSettings.value!.copyWith(newArrivals: value);
        break;
      case 'reviewReminders':
        updatedSettings = notificationSettings.value!.copyWith(reviewReminders: value);
        break;
      case 'wishlistUpdates':
        updatedSettings = notificationSettings.value!.copyWith(wishlistUpdates: value);
        break;
      case 'loyaltyPointsUpdates':
        updatedSettings = notificationSettings.value!.copyWith(loyaltyPointsUpdates: value);
        break;
      case 'emailNotifications':
        updatedSettings = notificationSettings.value!.copyWith(emailNotifications: value);
        break;
      case 'smsNotifications':
        updatedSettings = notificationSettings.value!.copyWith(smsNotifications: value);
        break;
      default:
        return;
    }

    await updateSettings(updatedSettings);
  }

  /// Subscribe to category topic
  Future<void> subscribeToCategory(String category) async {
    try {
      await _notificationService.subscribeToTopic('category_$category');
      Get.snackbar(
        'Success',
        'You will receive updates for $category',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to subscribe to category updates',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Unsubscribe from category topic
  Future<void> unsubscribeFromCategory(String category) async {
    try {
      await _notificationService.unsubscribeFromTopic('category_$category');
      Get.snackbar(
        'Success',
        'You will no longer receive updates for $category',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to unsubscribe from category updates',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Handle notification tap
  void handleNotificationTap(AppNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on type
    switch (notification.type) {
      case NotificationType.orderStatus:
      case NotificationType.orderConfirmed:
      case NotificationType.orderShipped:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
        final orderId = notification.data?['order_id'];
        if (orderId != null) {
          Get.toNamed('/order-details', arguments: {'orderId': orderId});
        }
        break;

      case NotificationType.promotion:
      case NotificationType.flashSale:
        final promotionId = notification.data?['promotion_id'];
        if (promotionId != null) {
          Get.toNamed('/promotion-details', arguments: {'promotionId': promotionId});
        }
        break;

      case NotificationType.priceAlert:
      case NotificationType.restockAlert:
        final productId = notification.data?['product_id'];
        if (productId != null) {
          Get.toNamed('/product-details', arguments: {'productId': productId});
        }
        break;

      case NotificationType.newArrival:
        Get.toNamed('/new-arrivals');
        break;

      case NotificationType.review:
        final orderId = notification.data?['order_id'];
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
        // Do nothing
        break;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      isLoading.value = true;

      // Delete all notifications
      for (var notification in notifications) {
        await _notificationService.deleteNotification(notification.id);
      }

      notifications.clear();
      unreadNotifications.clear();
      unreadCount.value = 0;

      Get.snackbar(
        'Success',
        'All notifications cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear notifications',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

enum NotificationFilter {
  all,
  unread,
  orders,
  promotions,
  alerts,
}
