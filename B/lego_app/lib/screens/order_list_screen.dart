import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import '../widgets/order_status_chip.dart';
import 'order_detail_screen.dart';

/// Order list screen with filtering, searching, and sorting
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderController _orderController = Get.find<OrderController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _orderController.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Sort button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Filter chips
          _buildFilterChips(),

          // Orders list
          Expanded(
            child: Obx(() {
              if (_orderController.isLoading.value &&
                  _orderController.filteredOrders.isEmpty) {
                return const OrderLoadingSkeleton();
              }

              if (_orderController.hasError.value) {
                return _buildErrorWidget();
              }

              if (_orderController.filteredOrders.isEmpty) {
                return EmptyOrdersWidget(
                  message: _orderController.searchQuery.value.isNotEmpty
                      ? 'No orders found'
                      : 'No orders yet',
                  actionText: 'Start Shopping',
                  onActionPressed: () => Get.back(),
                );
              }

              return RefreshIndicator(
                onRefresh: _orderController.refreshOrders,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _orderController.filteredOrders.length +
                      (_orderController.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _orderController.filteredOrders.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final order = _orderController.filteredOrders[index];
                    return OrderSummaryCard(
                      order: order,
                      onTap: () => _navigateToOrderDetail(order),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search orders by number, name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            if (_orderController.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _orderController.setSearchQuery('');
                },
              );
            }
            return const SizedBox.shrink();
          }),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          _orderController.setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final selectedStatus = _orderController.selectedStatus.value;

      if (selectedStatus == null &&
          _orderController.searchQuery.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (selectedStatus != null) ...[
              Chip(
                label: Text(selectedStatus.displayName),
                onDeleted: () => _orderController.setStatusFilter(null),
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
              const SizedBox(width: 8),
            ],
            if (_orderController.searchQuery.value.isNotEmpty ||
                selectedStatus != null) ...[
              TextButton.icon(
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear All'),
                onPressed: _orderController.clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  _orderController.errorMessage.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _orderController.refreshOrders(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          final currentSort = _orderController.sortOption.value;

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...OrderSortOption.values.map((option) {
                  return RadioListTile<OrderSortOption>(
                    title: Text(option.displayName),
                    value: option,
                    groupValue: currentSort,
                    onChanged: (value) {
                      if (value != null) {
                        _orderController.setSortOption(value);
                        Navigator.pop(context);
                      }
                    },
                    activeColor: Colors.black,
                  );
                }).toList(),
              ],
            ),
          );
        });
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          final currentStatus = _orderController.selectedStatus.value;

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter By Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentStatus != null)
                      TextButton(
                        onPressed: () {
                          _orderController.setStatusFilter(null);
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: OrderStatus.values.map((status) {
                    final isSelected = currentStatus == status;

                    return FilterChip(
                      label: Text(status.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        _orderController.setStatusFilter(selected ? status : null);
                        Navigator.pop(context);
                      },
                      selectedColor: Colors.black.withOpacity(0.1),
                      checkmarkColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _navigateToOrderDetail(Order order) {
    _orderController.selectOrder(order);
    Get.to(() => const OrderDetailScreen());
  }
}
