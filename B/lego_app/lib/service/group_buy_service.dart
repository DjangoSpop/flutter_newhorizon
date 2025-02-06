import 'dart:developer';

import 'package:get/get.dart';
import 'package:lego_app/models/group_buy_item.dart';
import 'package:lego_app/service/api_service.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:lego_app/service/notification_service.dart';

import '../models/discount_tier.dart';

enum ShareProvider { whatsapp, facebook, twitter, telegram, email }

class GroupBuyService extends GetxService {
  // Dependencies
  late final ApiService _apiService;
  late final AuthService _authService;
  late final NotificationService _notificationService;

  // State
  final _groupBuyCache = <GroupBuyItem>[].obs;
  DateTime? _lastCacheUpdate;

  // Configuration
  static const Duration cacheExpiration = Duration(minutes: 15);

  init() async {
    await _initializeDependencies();
    await _initializeCache();
    return this;
  }

  // Initialization
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeDependencies();
    await _initializeCache();
  }

  Future<void> _initializeDependencies() async {
    try {
      _apiService = Get.find<ApiService>();
      _authService = Get.find<AuthService>();
      _notificationService = Get.find<NotificationService>();
    } catch (e) {
      log('Failed to initialize dependencies: $e');
      rethrow;
    }
  }

  Future<void> _initializeCache() async {
    try {
      final items = await getGroupBuyItems();
      _updateCache(items);
    } catch (e) {
      log('Failed to initialize cache: $e');
    }
  }

  // Core Operations
  Future<List<GroupBuyItem>> getGroupBuyItems(
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid()) {
      return _groupBuyCache;
    }
    try {
      final response = await _apiService.get('/group-buys');
      final items = (response as List)
          .map((item) => GroupBuyItem.fromJson(item))
          .toList();
      _updateCache(items);
      return items;
    } catch (e) {
      throw 'Failed to fetch group buy items: $e';
    }
  }

  Future<GroupBuyItem> createGroupBuy(GroupBuyItem groupBuy) async {
    try {
      final response = await _apiService.post('/group-buys', groupBuy.toJson());
      final createdGroup = GroupBuyItem.fromJson(response);
      _groupBuyCache.add(createdGroup);
      return createdGroup;
    } catch (e) {
      throw 'Failed to create group buy: $e';
    }
  }

  Future<GroupBuyItem> joinGroupBuy(
      String groupBuyId, String userId, String size) async {
    try {
      final response = await _apiService.post(
        '/group-buys/$groupBuyId/join',
        {'user_id': userId, 'size': size},
      );
      final updatedGroup = GroupBuyItem.fromJson(response);
      _updateCacheItem(updatedGroup);
      return updatedGroup;
    } catch (e) {
      throw 'Failed to join group buy: $e';
    }
  }

  // Fetch all group buys
  // Future<List<GroupBuyItem>> getGroupBuyItems() async {
  //   try {
  //     final response = await _apiService.get('/group-buys');
  //     final items = (response as List)
  //         .map((item) => GroupBuyItem.fromJson(item))
  //         .toList();
  //     _updateCache(items);
  //     return items;
  //   } catch (e) {
  //     throw 'Failed to fetch group buy items: $e';
  //   }
  // }
  Future<void> leaveGroupBuy(String groupBuyId, String userId) async {
    try {
      await _apiService.delete('/group-buys/$groupBuyId/leave/$userId');
    } catch (e) {
      throw 'Failed to leave group buy: $e';
    }
  }

  Future<void> updateParticipationTarget(
      String groupBuyId, int newTarget) async {
    try {
      await _apiService.patch('/group-buys/$groupBuyId/participation-target', {
        'new_target': newTarget,
      });
    } catch (e) {
      throw 'Failed to update participation target: $e';
    }
  }

  Future<String> generateShareLink(
      String groupBuyId, Map<String, dynamic> data) async {
    try {
      final response =
          await _apiService.post('/group-buys/$groupBuyId/generate-link', data);
      return response['share_link'];
    } catch (e) {
      throw 'Failed to generate share link: $e';
    }
  }

  Future<void> trackShareEvent(String groupBuyId, String platform) async {
    try {
      await _apiService.post('/analytics/shares', {
        'group_buy_id': groupBuyId,
        'platform': platform,
        'user_id': _authService.currentUser?.value?.id,
      });
    } catch (e) {
      throw 'Failed to track share event: $e';
    }
  }

  Future<void> updateGroupStatus(String groupBuyId, String status) async {
    try {
      await _apiService
          .patch('/group-buys/$groupBuyId/status', {'status': status});
    } catch (e) {
      throw 'Failed to update group status: $e';
    }
  }

  Future<void> createOrdersForGroup(String groupBuyId) async {
    try {
      await _apiService.post('/group-buys/$groupBuyId/create-orders', {});
    } catch (e) {
      throw 'Failed to create orders for group: $e';
    }
  }

  // Notification Handling
  // Future<void> sendNotification(
  //     String title, String body, Map<String, dynamic> data) async {
  //   try {
  //     await _notificationService.sendNotification({
  //       title: 'Group Buy Notification',
  //       body: 'A new group buy has been created!',
  //       data[data]: data,
  //     });
  //   } catch (e) {
  //     throw 'Failed to send notification: $e';
  //   }
  // }

  // Cache Management
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < cacheExpiration;
  }

  void _updateCache(List<GroupBuyItem> items) {
    _groupBuyCache.assignAll(items);
    _lastCacheUpdate = DateTime.now();
  }

  void _updateCacheItem(GroupBuyItem updatedItem) {
    final index =
        _groupBuyCache.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _groupBuyCache[index] = updatedItem;
    }
  }

  Future<List> fetchGroupBuys() async {
    try {
      final response = await _apiService.get('/group-buys');
      return response;
    } catch (e) {
      throw 'Failed to fetch group buys: $e';
    }
  }

  double calculateDynamicPrice(
      int participantCount, List<DiscountTier> tiers, double regularPrice) {
    for (final tier in tiers) {
      if (participantCount >= tier.participantCount) {
        return regularPrice * (1 - (tier.discountPercentage / 100));
      }
    }
    return regularPrice;
  }

  notifyParticipants(String id, String s) {}

  sendGroupBuyNotification(
      {required String title,
      required String body,
      required Map<String, String> data}) {}

  getActiveGroupBuyItems() {}

  getGroupById(String groupId) {}
}

// Future<List<GroupBuyItem>> getGroupBuyItems() async {
//   try {
//     final response = await _apiService.get('/group-buys');
//     final items = (response as List)
//         .map((item) => GroupBuyItem.fromJson(item))
//         .toList();
//     _updateCache(items);
//     return items;
//   } catch (e) {
//     throw 'Failed to fetch group buy items: $e';
//   }
// }}
