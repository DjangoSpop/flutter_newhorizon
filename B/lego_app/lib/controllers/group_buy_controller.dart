import 'package:get/get.dart';
import 'package:lego_app/models/group_buy.dart';
import 'package:lego_app/models/group_buy_item.dart';
import 'package:lego_app/service/group_service.dart';

class GroupBuyController extends GetxController {
  final GroupBuyService _groupBuyService = Get.find<GroupBuyService>();

  var groupBuyItems = <GroupBuyItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroupBuyItems();
  }

  Future<void> fetchGroupBuyItems() async {
    try {
      isLoading(true);
      errorMessage('');
      final fetchedItems = await _groupBuyService.getGroupBuyItems();
      groupBuyItems.assignAll(fetchedItems);
    } catch (e) {
      errorMessage('Failed to fetch group buy items: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> createGroupBuy(GroupBuyItem groupBuy) async {
    try {
      isLoading(true);
      errorMessage('');
      final createdItem = await _groupBuyService.createGroupBuy(groupBuy);
      groupBuyItems.add(createdItem);
    } catch (e) {
      errorMessage('Failed to create group buy: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> joinGroupBuy(String groupBuyId, String userId) async {
    try {
      isLoading(true);
      errorMessage('');
      final updatedGroupBuy =
          await _groupBuyService.joinGroupBuy(groupBuyId, userId);
      final index = groupBuyItems.indexWhere((gb) => gb.id == groupBuyId);
      if (index != -1) {
        groupBuyItems[index] = updatedGroupBuy;
      }
    } catch (e) {
      errorMessage('Failed to join group buy: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> leaveGroupBuy(String groupBuyId, String userId) async {
    try {
      isLoading(true);
      errorMessage('');
      await _groupBuyService.leaveGroupBuy(groupBuyId, userId);
      await fetchGroupBuyItems(); // Refresh the list after leaving
    } catch (e) {
      errorMessage('Failed to leave group buy: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
