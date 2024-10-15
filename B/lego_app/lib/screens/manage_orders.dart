import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatelessWidget {
  final List<Order> orders = [
    Order(id: '1', title: 'Order 1', status: 'Under Work'),
    Order(id: '2', title: 'Order 2', status: 'Fulfilled'),
    Order(id: '3', title: 'Order 3', status: 'Under Work'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: ListView.separated(
        itemCount: orders.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(
              order.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text('Status: ${order.status}',
                style: _getStatusTextStyle(order.status, context)),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
          );
        },
      ),
    );
  }

  TextStyle? _getStatusTextStyle(String status, BuildContext context) {
    // Returns different text styles based on order status
    switch (status) {
      case 'Fulfilled':
        return Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.green);
      case 'Under Work':
        return Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            );
      default:
        return Theme.of(context).textTheme.bodyMedium;
    }
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Order ID', order.id, context),
            const SizedBox(height: 8),
            _buildDetailRow('Title', order.title, context),
            const SizedBox(height: 8),
            _buildDetailRow('Status', order.status, context),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle order fulfillment logic here
              },
              child: const Text('Mark as Fulfilled'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Handle update order status logic
              },
              child: const Text('Update Order Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class Order {
  final String id;
  final String title;
  final String status;

  Order({required this.id, required this.title, required this.status});
}
