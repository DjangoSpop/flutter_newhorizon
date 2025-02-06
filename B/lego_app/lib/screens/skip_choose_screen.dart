import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SkipSignIN extends StatelessWidget {
  const SkipSignIN({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Choose Your Role'.tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Expanded(
              //   child: SvgPicture.asset(
              //     'assets/images/logos.svg',
              //     width: 200,
              //     height: 200,
              //   ),
              // ),
              const SizedBox(height: 24),
              Text(
                'Welcome to RetailerPro ERP'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Select your role to continue'.tr,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildRoleButton('Buyer'.tr, Icons.shopping_cart, '/buyer'),
              const SizedBox(height: 16),
              _buildRoleButton('Seller'.tr, Icons.store, '/addProduct'),
              const SizedBox(height: 16),
              _buildRoleButton(
                  'Manufacturer'.tr, Icons.factory, '/manageOrders'),
              const SizedBox(height: 16),
              _buildRoleButton(
                  'Admin'.tr, Icons.admin_panel_settings, '/admin'),
              const SizedBox(height: 16),
              _buildRoleButton(
                  'Finance'.tr, Icons.calculate_rounded, '/finance'),
              const SizedBox(height: 16),
              _buildRoleButton(
                  'warehouses'.tr, Icons.warehouse_sharp, '/warhouses'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, IconData icon, String route) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(
        role,
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => Get.toNamed(route),
    );
  }
}
