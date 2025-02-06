import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/models/group_buy_item.dart';
import 'package:lego_app/service/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/group_buy_service.dart';

enum GroupBuyStatus { active, completed, expired, pending }

enum SharePlatform { whatsapp, facebook, other }

class GroupBuyController extends GetxController {
  final GroupBuyService _groupBuyService = Get.find<GroupBuyService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observable State Variables
  final groupBuyItems = <GroupBuyItem>[].obs;
  final activeGroupBuys = <GroupBuyItem>[].obs;
  final expandedGroups = <String, GroupBuyItem>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final sizeDistribution = <String, int>{}.obs;
  final timeRemaining = Duration().obs;
  final currentShareLink = ''.obs;
  final totalParticipationTarget = 12.obs;
  final selectedSizes = <String, int>{}.obs;

  // State for filtering and sorting
  final selectedCategory = Rx<String?>(null);
  final sortBy = Rx<String>('newest');
  final filterByStatus = Rx<GroupBuyStatus?>(null);

  // Timers
  Timer? _refreshTimer;
  Timer? _countdownTimer;

  // Constants
  static const int PARTICIPATION_INCREMENT = 12;
  static const int MAX_PARTICIPATIONS = 48;
  static const int MINIMUM_PIECES = 12;
  static const int MIN_DURATION_DAYS = 7;
  static const int MAX_DURATION_DAYS = 25;
  static const double EXPANSION_THRESHOLD = 0.8;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _disposeTimers();
    super.onClose();
  }

  void _initializeController() {
    fetchGroupBuyItems();
    _startPeriodicRefresh();
    _setupSizeDistributionListeners();
  }

  void _disposeTimers() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
  }

  void _setupSizeDistributionListeners() {
    ever(sizeDistribution, (_) {
      _validateSizeDistribution();
    });
  }

  void _validateSizeDistribution() {
    final total = sizeDistribution.values.fold(0, (sum, qty) => sum + qty);
    if (total < MINIMUM_PIECES) {
      errorMessage('Minimum ${MINIMUM_PIECES} pieces required');
    }
  }

  Future<void> fetchGroupBuys() async {
    try {
      isLoading(true);
      final items = await _groupBuyService.fetchGroupBuys();
      groupBuyItems.assignAll(items as Iterable<GroupBuyItem>);
    } catch (e) {
      errorMessage('Failed to fetch group buys: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Future<void> createGroupBuy(GroupBuyItem groupBuy) async {
  //   try {
  //     isLoading(true);
  //     errorMessage('');
  //     final createdGroupBuy = await _groupBuyService.createGroupBuy(groupBuy);
  //     groupBuyItems.add(createdGroupBuy);
  //   } catch (e) {
  //     errorMessage('Failed to create group buy: ${e.toString()}');
  //     rethrow;
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<void> shareViaWhatsApp(GroupBuyItem groupBuy) async {
    try {
      final shareLink = await _generateShareLink(groupBuy);
      final message = _generateShareMessage(groupBuy);

      final whatsappUrl = Uri.parse(
          'whatsapp://send?text=${Uri.encodeComponent('$message\n$shareLink')}');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        Get.snackbar(
          'Error',
          'WhatsApp is not installed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage('Failed to share via WhatsApp: ${e.toString()}');
    }
  }

//createGroupBuy function is used to create a new group buy item
  Future<GroupBuyItem> createGroupBuy(GroupBuyItem groupBuy) async {
    try {
      isLoading(true);
      errorMessage('');

      final createdGroupBuy = await _groupBuyService.createGroupBuy(groupBuy);
      groupBuyItems.add(createdGroupBuy);

      return createdGroupBuy;
    } catch (e) {
      errorMessage('Failed to create group buy: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> shareViaFacebook(GroupBuyItem groupBuy) async {
    try {
      final shareLink = await _generateShareLink(groupBuy);
      final message = _generateShareMessage(groupBuy);

      final facebookUrl = Uri.parse(
          'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareLink)}&quote=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(facebookUrl)) {
        await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch Facebook',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage('Failed to share via Facebook: ${e.toString()}');
    }
  }

  Future<void> shareGroupBuy(GroupBuyItem groupBuy,
      {required SharePlatform platform}) async {
    try {
      final shareLink = await _generateShareLink(groupBuy);
      final message = _generateShareMessage(groupBuy);

      switch (platform) {
        case SharePlatform.whatsapp:
          await shareViaWhatsApp(groupBuy);
          break;
        case SharePlatform.facebook:
          await shareViaFacebook(groupBuy);
          break;
        case SharePlatform.other:
          await Share.share(
            '$message\n$shareLink',
            subject: 'Join our Group Buy!',
          );
          break;
      }

      // Track sharing analytics
      await _trackShareEvent(groupBuy.id, platform);
    } catch (e) {
      errorMessage('Failed to share: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to share group buy',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _generateShareMessage(GroupBuyItem groupBuy) {
    final savings = ((groupBuy.originalPrice - groupBuy.groupBuyPrice) /
            groupBuy.originalPrice *
            100)
        .toStringAsFixed(0);

    return '''
Join our Group Buy and save ${savings}%! 🛍️

${groupBuy.name}
Original Price: ${groupBuy.formattedOriginalPrice}
Group Buy Price: ${groupBuy.formattedGroupBuyPrice}
Remaining Places: ${_getRemainingPlaces(groupBuy)}
Time Left: ${groupBuy.timeLeft}

Available Sizes: ${groupBuy.availableSizes.join(', ')}
    '''
        .trim();
  }

  Future<String> _generateShareLink(GroupBuyItem groupBuy) async {
    // Implement your dynamic link generation here
    // Example using Firebase Dynamic Links
    final dynamicLink = await _groupBuyService.generateShareLink(
      groupBuy.id,
      {
        'title': groupBuy.name,
        'description': groupBuy.description,
        'imageUrl': groupBuy.imageUrl,
      },
    );

    currentShareLink.value = dynamicLink;
    return dynamicLink;
  }

  Future<void> _trackShareEvent(
      String groupBuyId, SharePlatform platform) async {
    // Implement share analytics
    await _groupBuyService.trackShareEvent(groupBuyId, platform.toString());
  }

  // Enhanced participation management
  Future<void> increaseParticipationTarget(String groupBuyId) async {
    try {
      final groupBuy = groupBuyItems.firstWhere((gb) => gb.id == groupBuyId);

      if (!_canIncreaseParticipation(groupBuy)) {
        throw 'Cannot increase participation target at this time';
      }

      final newTarget =
          totalParticipationTarget.value + PARTICIPATION_INCREMENT;

      if (newTarget > MAX_PARTICIPATIONS) {
        throw 'Maximum participation limit reached';
      }

      isLoading(true);
      errorMessage('');

      // Update the group buy with new target
      await _groupBuyService.updateParticipationTarget(
        groupBuyId,
        newTarget,
      );

      totalParticipationTarget.value = newTarget;

      // Notify potential participants
      await _notifyParticipationIncrease(groupBuy);

      Get.snackbar(
        'Success',
        'Participation target increased to $newTarget pieces',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage('Failed to increase participation target: ${e.toString()}');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  bool _canIncreaseParticipation(GroupBuyItem groupBuy) {
    if (!groupBuy.isActive) return false;
    if (groupBuy.progress < 0.8) return false; // Must be at least 80% full
    if (totalParticipationTarget.value >= MAX_PARTICIPATIONS) return false;

    // Check if there's enough time left
    final remainingDays = groupBuy.endDate.difference(DateTime.now()).inDays;
    return remainingDays >= MIN_DURATION_DAYS;
  }

  int _getRemainingPlaces(GroupBuyItem groupBuy) {
    final totalTarget = totalParticipationTarget.value;
    final currentParticipants = groupBuy.participants.length;
    return totalTarget - currentParticipants;
  }

//_showLocalNotification function is used to show a local notification
  Future<void> _showLocalNotification(
      String title, String message, String payload) async {
    // Implement your local notification logic here
    // Example using flutter_local_notifications package
    // final androidDetails = AndroidNotificationDetails(
    //   'channelId',
    //   'channelName',
    //   'channelDescription',
    //   importance: Importance.max,
    //   priority: Priority.high,
    // );
    // final notificationDetails = NotificationDetails(android: androidDetails);
    // await flutterLocalNotificationsPlugin.show(
    //   0,
    //   title,
    //   message,
    //   notificationDetails,
    //   payload: payload,
    // );
  }
  Future<void> _notifyParticipationIncrease(GroupBuyItem groupBuy) async {
    final message = '''
Great news! Due to high demand, we've increased the group buy capacity for ${groupBuy.name}!
New target: ${totalParticipationTarget.value} pieces
Current price: ${groupBuy.formattedGroupBuyPrice}
    '''
        .trim();

    await _showLocalNotification(
      'Group Buy Extended!',
      message,
      groupBuy.id,
    );

    // Notify through Firebase Cloud Messaging
    await _groupBuyService.sendGroupBuyNotification(
      title: 'Group Buy Extended!',
      body: message,
      data: {
        'type': 'participation_increase',
        'groupBuyId': groupBuy.id,
      },
    );
  }

  void _startCountdown(DateTime endDate) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      final remaining = endDate.difference(DateTime.now());
      if (remaining.isNegative) {
        _countdownTimer?.cancel();
        refreshActiveGroupBuys();
      } else {
        timeRemaining.value = remaining;
      }
    });
  }

  // Enhanced fetch method with filtering and sorting
  Future<void> fetchGroupBuyItems() async {
    try {
      isLoading(true);
      errorMessage('');

      var items = await _groupBuyService.getGroupBuyItems();

      // Apply filters
      if (selectedCategory.value != null) {
        items = items
            .where((item) => item.description == selectedCategory.value)
            .toList();
      }

      if (filterByStatus.value != null) {
        items = items
            .where((item) => _getItemStatus(item) == filterByStatus.value)
            .toList();
      }

      // Apply sorting
      items.sort((a, b) {
        switch (sortBy.value) {
          case 'price':
            return a.groupBuyPrice.compareTo(b.groupBuyPrice);
          case 'timeLeft':
            return a.endDate.compareTo(b.endDate);
          case 'progress':
            return b.progress.compareTo(a.progress);
          default: // 'newest'
            return b.startDate.compareTo(a.startDate);
        }
      });

      groupBuyItems.assignAll(items);
      _updateActiveGroupBuys();
      _startCountdownForActiveGroups();
    } catch (e) {
      errorMessage('Failed to fetch group buy items: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void _updateActiveGroupBuys() {
    activeGroupBuys.assignAll(
        groupBuyItems.where((item) => item.isActive && !item.isFull));
  }

  void _startCountdownForActiveGroups() {
    if (activeGroupBuys.isEmpty) return;

    final nearestEndDate = activeGroupBuys
        .map((item) => item.endDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    _startCountdown(nearestEndDate);
  }

  void _startPeriodicRefresh() {
    // Cancel existing timer if any
    _refreshTimer?.cancel();

    // Start new periodic timer
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) async {
        try {
          // Refresh active group buys
          await _refreshActiveGroupBuys();

          // Check and update expansion eligibility
          _checkExpansionEligibility();

          // Update countdowns
          _updateAllCountdowns();

          // Check for completed or expired groups
          _checkGroupStatuses();
        } catch (e) {
          errorMessage('Error refreshing data: ${e.toString()}');
        }
      },
    );
  }

  Future<void> _refreshActiveGroupBuys() async {
    try {
      // Only fetch active group buys to minimize API calls
      final activeItems = await _groupBuyService.getActiveGroupBuyItems();

      // Update existing items while preserving others
      for (var item in activeItems) {
        final index = groupBuyItems.indexWhere((gb) => gb.id == item.id);
        if (index != -1) {
          groupBuyItems[index] = item;
        } else {
          groupBuyItems.add(item);
        }
      }

      // Update active groups list
      activeGroupBuys.assignAll(
        groupBuyItems
            .where((item) => item.isActive && !item.isFull && !item.isExpired),
      );
    } catch (e) {
      errorMessage('Failed to refresh active group buys: ${e.toString()}');
    }
  }

  void _checkExpansionEligibility() {
    for (var groupBuy in activeGroupBuys) {
      if (_canExpandGroup(groupBuy)) {
        // Notify if group becomes eligible for expansion
        if (!expandedGroups.containsKey(groupBuy.id)) {
          Get.snackbar(
            'Expansion Available',
            '${groupBuy.name} is eligible for expansion!',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () => increaseParticipationTarget(groupBuy.id),
              child: Text('Expand Now', style: TextStyle(color: Colors.white)),
            ),
          );
        }
      }
    }
  }

  bool _canExpandGroup(GroupBuyItem groupBuy) {
    return groupBuy.isActive &&
        !groupBuy.isExpanded &&
        groupBuy.progress >= EXPANSION_THRESHOLD &&
        !expandedGroups.containsKey(groupBuy.id) &&
        groupBuy.endDate.difference(DateTime.now()).inDays >=
            MIN_DURATION_DAYS &&
        totalParticipationTarget.value < MAX_PARTICIPATIONS;
  }

  void _updateAllCountdowns() {
    for (var groupBuy in activeGroupBuys) {
      final remaining = groupBuy.endDate.difference(DateTime.now());

      // Check if less than 24 hours remaining
      if (remaining.inHours <= 24 && remaining.inHours > 0) {
        _notifyTimeRemaining(groupBuy, remaining);
      }

      // Update time remaining for UI
      if (groupBuy ==
          activeGroupBuys.firstWhere(
            (item) => item.id == groupBuy.id,
            orElse: () => activeGroupBuys.first,
          )) {
        timeRemaining.value = remaining;
      }
    }
  }

  void _notifyTimeRemaining(GroupBuyItem groupBuy, Duration remaining) {
    // Only notify at specific intervals
    if (remaining.inHours == 24 ||
        remaining.inHours == 12 ||
        remaining.inHours == 6 ||
        remaining.inHours == 1) {
      Get.snackbar(
        'Time Running Out!',
        'Only ${remaining.inHours} hours left to join ${groupBuy.name}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () =>
              Get.toNamed('/group-buy-details', arguments: groupBuy.id),
          child: Text('View Details', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  void _checkGroupStatuses() {
    final now = DateTime.now();

    for (var groupBuy in groupBuyItems) {
      // Check for newly completed groups
      if (groupBuy.isActive &&
          groupBuy.isFull &&
          !groupBuy.isExpired &&
          !groupBuy.isCompleted) {
        _handleGroupCompletion(groupBuy);
      }

      // Check for newly expired groups
      if (groupBuy.isActive &&
          !groupBuy.isExpired &&
          now.isAfter(groupBuy.endDate)) {
        _handleGroupExpiration(groupBuy);
      }
    }
  }

  Future<void> joinGroupBuy(
    String groupBuyId,
    String userId,
    String selectedSize,
  ) async {
    try {
      isLoading(true);
      errorMessage('');

      // Validate size availability
      if (!_isSizeAvailable(groupBuyId, selectedSize)) {
        throw 'Selected size is no longer available';
      }

      final updatedGroupBuy = await _groupBuyService.joinGroupBuy(
        groupBuyId,
        userId,
        selectedSize,
      );

      final index = groupBuyItems.indexWhere((gb) => gb.id == groupBuyId);
      if (index != -1) {
        groupBuyItems[index] = updatedGroupBuy;
        _updateSizeDistribution(groupBuyId, selectedSize);
      }
    } catch (e) {
      errorMessage('Failed to join group buy: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> leaveGroupBuy(
      String groupBuyId, String userId, String size) async {
    try {
      isLoading(true);
      errorMessage('');

      await _groupBuyService.leaveGroupBuy(groupBuyId, userId);

      // Update size distribution
      if (sizeDistribution.containsKey(size)) {
        sizeDistribution[size] = sizeDistribution[size]! - 1;
        sizeDistribution.refresh();
      }

      await fetchGroupBuyItems();
    } catch (e) {
      errorMessage('Failed to leave group buy: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  void refreshActiveGroupBuys() {
    fetchGroupBuyItems();
  }

  bool _isSizeAvailable(String groupBuyId, String size) {
    final groupBuy = groupBuyItems.firstWhere((gb) => gb.id == groupBuyId);
    final currentCount = sizeDistribution[size] ?? 0;
    return currentCount <
        (groupBuy.maxQuantity ~/ groupBuy.availableSizes.length);
  }

  void _updateSizeDistribution(String groupBuyId, String size) {
    if (sizeDistribution.containsKey(size)) {
      sizeDistribution[size] = sizeDistribution[size]! + 1;
      sizeDistribution.refresh();
    } else {
      sizeDistribution[size] = 1;
    }
  }

  // Getters for UI
  String get timeRemainingFormatted {
    final duration = timeRemaining.value;
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  double getProgress(String groupBuyId) {
    final totalJoined =
        sizeDistribution.values.fold(0, (sum, count) => sum + count);
    return totalJoined / MINIMUM_PIECES;
  }

  Map<String, int> getRemainingQuantities(String groupBuyId) {
    final groupBuy = groupBuyItems.firstWhere((gb) => gb.id == groupBuyId);
    final result = <String, int>{};

    for (final size in groupBuy.availableSizes) {
      final maxPerSize = groupBuy.maxQuantity ~/ groupBuy.availableSizes.length;
      final current = sizeDistribution[size] ?? 0;
      result[size] = maxPerSize - current;
    }

    return result;
  }

  bool isGroupBuyActive(String groupBuyId) {
    final groupBuy = groupBuyItems.firstWhere((gb) => gb.id == groupBuyId);
    final now = DateTime.now();
    return groupBuy.status == 'ACTIVE' &&
        now.isAfter(groupBuy.startDate) &&
        now.isBefore(groupBuy.endDate);
  }

  Future<void> _handleGroupCompletion(GroupBuyItem groupBuy) async {
    try {
      // Update group status
      await _groupBuyService.updateGroupStatus(
        groupBuy.id,
        GroupBuyStatus.completed as String,
      );

      // Notify participants
      await _groupBuyService.notifyParticipants(
        groupBuy.id,
        'Group buy completed! Orders will be processed soon.',
      );

      // Create orders for participants
      await _groupBuyService.createOrdersForGroup(groupBuy.id);

      // Update local state
      final index = groupBuyItems.indexWhere((item) => item.id == groupBuy.id);
      if (index != -1) {
        groupBuyItems[index] = groupBuy.copyWith(
          status: GroupBuyStatus.completed.toString(),
        );
      }
    } catch (e) {
      errorMessage('Error handling group completion: ${e.toString()}');
    }
  }

  Future<void> updateDynamicPrice(String groupId) async {
    try {
      isLoading(true);
      final group = await _groupBuyService.getGroupById(groupId);
      final price = await _groupBuyService.calculateDynamicPrice(
        group.participants.length,
        group.discountTiers,
        group.regularPrice,
      );
      groupBuyItems.firstWhere((item) => item.id == groupId).groupPrice = price;
    } catch (e) {
      errorMessage('Failed to update price: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _handleGroupExpiration(GroupBuyItem groupBuy) async {
    try {
      // Update group status
      await _groupBuyService.updateGroupStatus(
        groupBuy.id,
        GroupBuyStatus.expired as String,
      );

      // Notify participants if minimum not reached
      if (groupBuy.progress < 1.0) {
        await _groupBuyService.notifyParticipants(
          groupBuy.id,
          'Unfortunately, the group buy did not reach the minimum required participants.',
        );
      }

      // Update local state
      final index = groupBuyItems.indexWhere((item) => item.id == groupBuy.id);
      if (index != -1) {
        groupBuyItems[index] = groupBuy.copyWith(
          status: GroupBuyStatus.expired.toString(),
        );
      }
    } catch (e) {
      errorMessage('Error handling group expiration: ${e.toString()}');
    }
  }

// // Helper method to dispose timers properly
//   void _disposeTimers() {
//     _refreshTimer?.cancel();
//     _countdownTimer?.cancel();
//     _refreshTimer = null;
//     _countdownTimer = null;
//   }

  // Enhanced sharing functionality
  Future<void> shareGroupBuys(
      GroupBuyItem groupBuy, SharePlatform platform) async {
    try {
      isLoading(true);
      final shareLink = await _generateShareLink(groupBuy);
      final message = _generateShareMessage(groupBuy);

      await _executeShare(platform, message, shareLink);
      await _trackShareEvent(groupBuy.id, platform);

      Get.snackbar(
        'Success',
        'Group buy shared successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage('Failed to share: ${e.toString()}');
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> _executeShare(
      SharePlatform platform, String message, String link) async {
    switch (platform) {
      case SharePlatform.whatsapp:
        await _shareViaWhatsApp(message, link);
        break;
      case SharePlatform.facebook:
        await _shareViaFacebook(message, link);
        break;
      case SharePlatform.other:
        await Share.share('$message\n$link', subject: 'Join our Group Buy!');
        break;
    }
  }

  Future<void> _shareViaWhatsApp(String message, String link) async {
    final whatsappUrl = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent('$message\n$link')}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      throw 'WhatsApp is not installed';
    }
  }

  Future<void> _shareViaFacebook(String message, String link) async {
    final facebookUrl = Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}&quote=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(facebookUrl)) {
      await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Facebook';
    }
  }

  // Enhanced participation management
  Future<void> increaseParticipationTargets(String groupBuyId) async {
    try {
      final groupBuy = groupBuyItems.firstWhere((gb) => gb.id == groupBuyId);
      _validateParticipationIncrease(groupBuy);

      isLoading(true);
      final newTarget =
          totalParticipationTarget.value + PARTICIPATION_INCREMENT;

      await _groupBuyService.updateParticipationTarget(groupBuyId, newTarget);
      await _createExpandedGroup(groupBuy);

      totalParticipationTarget.value = newTarget;
      _notifyParticipationIncrease(groupBuy);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void _validateParticipationIncrease(GroupBuyItem groupBuy) {
    if (!_canIncreaseParticipation(groupBuy)) {
      throw 'Cannot increase participation at this time';
    }

    final newTotal = totalParticipationTarget.value + PARTICIPATION_INCREMENT;
    if (newTotal > MAX_PARTICIPATIONS) {
      throw 'Maximum participation limit reached';
    }
  }

  Future<void> _createExpandedGroup(GroupBuyItem originalGroup) async {
    final newGroup = originalGroup.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parentGroupId: originalGroup.id,
      isExpanded: true,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: MIN_DURATION_DAYS)),
      participants: [],
    );

    final createdGroup = await _groupBuyService.createGroupBuy(newGroup);
    expandedGroups[originalGroup.id] = createdGroup;
    groupBuyItems.add(createdGroup);
  }

  Future<void> _notifyParticipationsIncrease(GroupBuyItem groupBuy) async {
    final message = '''
    Group buy capacity increased!
    ${groupBuy.name}
    New target: ${totalParticipationTarget.value} pieces
    Current price: ${groupBuy.formattedGroupBuyPrice}
    Join now to secure your order!
    '''
        .trim();

    await _groupBuyService.notifyParticipants(groupBuy.id, message);
  }

  // Helper methods
  GroupBuyStatus _getItemStatus(GroupBuyItem item) {
    if (item.isExpired) return GroupBuyStatus.expired;
    if (item.isFull) return GroupBuyStatus.completed;
    if (item.isActive) return GroupBuyStatus.active;
    return GroupBuyStatus.pending;
  }

  // String get timeRemainingFormatted {
  //   final duration = timeRemaining.value;
  //   if (duration.inDays > 0) {
  //     return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
  //   } else if (duration.inHours > 0) {
  //     return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  //   }
  //   return '${duration.inMinutes}m';
  // }
}
