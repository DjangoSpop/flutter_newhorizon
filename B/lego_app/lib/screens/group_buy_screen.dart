import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lego_app/controllers/group_buy_controller.dart';
import 'package:lego_app/models/group_buy_item.dart';

import '../widgets/GroupBuyShareSheet.dart';

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
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(item.description,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                _buildStatusBadge(item),
              ],
            ),
            SizedBox(height: 16),
            _buildPriceSection(item),
            SizedBox(height: 16),
            _buildSizeDistributionSection(item),
            SizedBox(height: 16),
            _buildProgressSection(item, context),
            SizedBox(height: 16),
            _buildTimeAndActionSection(item, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(GroupBuyItem item) {
    Color color = item.isActive
        ? Colors.green
        : item.isExpired
            ? Colors.red
            : Colors.grey;
    String text = item.isActive
        ? 'Active'
        : item.isExpired
            ? 'Expired'
            : 'Completed';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPriceSection(GroupBuyItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original: ${item.formattedOriginalPrice}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
            Text(
              'Group Buy: ${item.formattedGroupBuyPrice}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.formattedSavingsPercentage,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeDistributionSection(GroupBuyItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size Distribution',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: item.availableSizes.map((size) {
            final remaining = item.getRemainingSizeQuantity(size);
            final isAvailable = item.isSizeAvailable(size);

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.blue.shade50 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAvailable ? Colors.blue : Colors.grey,
                ),
              ),
              child: Column(
                children: [
                  Text(size, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${remaining} left'),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressSection(GroupBuyItem item, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(item.progressText),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: item.progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              item.progress >= 1 ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAndActionSection(GroupBuyItem item, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Remaining:', style: TextStyle(color: Colors.grey)),
            Text(
              item.timeLeft,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.isExpired ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          icon: Icon(item.isFull ? Icons.block : Icons.group_add),
          label: Text(item.isFull ? 'Full' : 'Join Group'),
          onPressed: item.isFull || !item.isActive
              ? null
              : () => _showJoinGroupBuyDialog(context, item),
          style: ElevatedButton.styleFrom(
            backgroundColor: item.isFull ? Colors.grey : Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showJoinGroupBuyDialog(BuildContext context, GroupBuyItem item) {
    String? selectedSize;

    Get.dialog(
      AlertDialog(
        title: Text('Join Group Buy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Size:'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: item.availableSizes
                  .where((size) => item.isSizeAvailable(size))
                  .map((size) => ChoiceChip(
                        label: Text(size),
                        selected: selectedSize == size,
                        onSelected: (selected) {
                          selectedSize = selected ? size : null;
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Get.bottomSheet(
                GroupBuyShareSheet(groupBuy: item),
                isScrollControlled: true,
              );
            },
          ),
          ElevatedButton(
            child: Text('Join'),
            onPressed: () {
              if (selectedSize != null) {
                controller.joinGroupBuy(
                    item.id, 'current_user_id', selectedSize!);
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCreateGroupBuyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final originalPriceController = TextEditingController();
    final groupBuyPriceController = TextEditingController();
    final durationController = TextEditingController();
    Map<String, TextEditingController> sizeControllers = {};
    List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

    for (var size in sizes) {
      sizeControllers[size] = TextEditingController();
    }

    Get.dialog(
      AlertDialog(
        title: Text('Create Group Buy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
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
                controller: durationController,
                decoration: InputDecoration(
                  labelText: 'Duration (days)',
                  helperText: 'Between 7-25 days',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Text('Size Distribution (min total: 12 pieces):'),
              ...sizes.map((size) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: sizeControllers[size],
                      decoration:
                          InputDecoration(labelText: 'Size $size Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  )),
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
              // Validate total quantity
              int totalQuantity = 0;
              Map<String, int> sizeDistribution = {};

              for (var size in sizes) {
                final quantity = int.tryParse(sizeControllers[size]!.text) ?? 0;
                totalQuantity += quantity;
                sizeDistribution[size] = quantity;
              }

              if (totalQuantity < 12) {
                Get.snackbar(
                  'Error',
                  'Minimum total quantity must be 12 pieces',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final duration = int.tryParse(durationController.text) ?? 0;
              if (duration < 7 || duration > 25) {
                Get.snackbar(
                  'Error',
                  'Duration must be between 7 and 25 days',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final newItem = GroupBuyItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                description: descriptionController.text,
                originalPrice: double.parse(originalPriceController.text),
                groupBuyPrice: double.parse(groupBuyPriceController.text),
                minQuantity: 12,
                maxQuantity: totalQuantity,
                status: GroupBuyItem.STATUS_ACTIVE,
                startDate: DateTime.now(),
                endDate: DateTime.now().add(Duration(days: duration)),
                productId: 'product_id',
                sellerId: 'seller_id',
                sizeDistribution: SizeDistribution(
                  targetQuantities: sizeDistribution,
                ),
                participants: [],
                availableSizes: sizes,
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
