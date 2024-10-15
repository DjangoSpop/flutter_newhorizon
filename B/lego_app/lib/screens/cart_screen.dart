import 'package:flutter/material.dart';

import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text('Your shopping cart is empty.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to checkout screen
          Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen()));
        },
        child: Icon(Icons.shopping_cart_checkout),
      ),
    );
  }
}
