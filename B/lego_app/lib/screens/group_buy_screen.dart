import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lego_app/controllers/group_buy_controller.dart';
import 'package:lego_app/models/group_buy_item.dart';

class GroupBuyScreen extends StatelessWidget {
  final GroupBuyController controller = Get.put(GroupBuyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Buys'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.fetchGroupBuyItems(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        } else if (controller.groupBuyItems.isEmpty) {
          return Center(child: Text('No group buys available'));
        } else {
          return RefreshIndicator(
            onRefresh: () => controller.fetchGroupBuyItems(),
            child: ListView.builder(
              itemCount: controller.groupBuyItems.length,
              itemBuilder: (context, index) {
                final item = controller.groupBuyItems[index];
                return _buildGroupBuyCard(item, context);
              },
            ),
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showCreateGroupBuyDialog(context),
      ),
    );
  }

  Widget _buildGroupBuyCard(GroupBuyItem item, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(item.description,
                style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Original: ${item.formattedOriginalPrice}',
                        style:
                            TextStyle(decoration: TextDecoration.lineThrough)),
                    Text('Group Buy: ${item.formattedGroupBuyPrice}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Chip(
                  label: Text(item.formattedSavingsPercentage),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(value: item.progress),
            SizedBox(height: 4),
            Text('${item.progressText} participants',
                style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.timeLeft,
                    style: Theme.of(context).textTheme.bodySmall),
                ElevatedButton(
                  child: Text(item.isFull ? 'Full' : 'Join'),
                  onPressed: item.isFull
                      ? null
                      : () => controller.joinGroupBuy(item.id, 'user_id'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isFull ? Colors.grey : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupBuyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final originalPriceController = TextEditingController();
    final groupBuyPriceController = TextEditingController();
    final minQuantityController = TextEditingController();
    final maxQuantityController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Create Group Buy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: originalPriceController,
                decoration: InputDecoration(labelText: 'Original Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: groupBuyPriceController,
                decoration: InputDecoration(labelText: 'Group Buy Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: minQuantityController,
                decoration: InputDecoration(labelText: 'Minimum Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxQuantityController,
                decoration: InputDecoration(labelText: 'Maximum Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: Text('Create'),
            onPressed: () {
              final newItem = GroupBuyItem(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(), // Temporary ID
                name: nameController.text,
                description: descriptionController.text,
                originalPrice: double.parse(originalPriceController.text),
                groupBuyPrice: double.parse(groupBuyPriceController.text),
                minQuantity: int.parse(minQuantityController.text),
                maxQuantity: int.parse(maxQuantityController.text),
                currentQuantity: 0,
                status: 'ACTIVE',
                startDate: DateTime.now(),
                endDate:
                    DateTime.now().add(Duration(days: 7)), // Default to 7 days
                productId:
                    'product_id', // You might want to add a product selection
                sellerId: 'seller_id', // This should be the current user's ID
                participantIds: [],
              );
              controller.createGroupBuy(newItem);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
