import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class AdminMainScreen extends StatelessWidget {
  final int totalProducts = 50; // Mock data for total products
  final int pendingOrders = 5; // Mock data for pending orders
  final int lowStockItems = 3; // Mock data for low stock items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Admin!',
                style: TextStyle(color: Colors.white, fontSize: 24)),
            SizedBox(height: 20),
            _buildDashboardCard(
              title: 'Total Products',
              value: totalProducts.toString(),
              icon: Icons.inventory,
            ),
            _buildDashboardCard(
              title: 'Pending Orders',
              value: pendingOrders.toString(),
              icon: Icons.shopping_cart,
            ),
            _buildDashboardCard(
              title: 'Low Stock Items',
              value: lowStockItems.toString(),
              icon: Icons.warning,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.toNamed ( '/addProduct');
              },
              child: Text('add Products'),
              style: ElevatedButton.styleFrom(
                  iconColor: Colors.white, backgroundColor: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.toNamed ( '/addProduct');
              },
              child: Text('Manage Orders'),
              style: ElevatedButton.styleFrom(
                  iconColor: Colors.white, backgroundColor: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/products');
              },
              child: Text('View Products'),
              style: ElevatedButton.styleFrom(
                  iconColor: Colors.black12, backgroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      {required String title, required String value, required IconData icon}) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: TextStyle(color: Colors.black)),
        trailing: Text(value,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
