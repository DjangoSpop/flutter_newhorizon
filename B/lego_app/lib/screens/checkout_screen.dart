import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Mock data
  final List<Map<String, dynamic>> cartItems = [
    {'name': 'LEGO City Police Station', 'price': 99.99, 'quantity': 1},
    {'name': 'LEGO Star Wars Millennium Falcon', 'price': 159.99, 'quantity': 1},
    {'name': 'LEGO Technic Bugatti Chiron', 'price': 349.99, 'quantity': 1},
  ];

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get tax => subtotal * 0.08; // Assume 8% tax
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...cartItems.map((item) => _buildCartItem(item)).toList(),
              SizedBox(height: 24),
              _buildTotalSection(),
              SizedBox(height: 24),
              _buildPaymentSection(),
              SizedBox(height: 24),
              _buildCheckoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Quantity: ${item['quantity']}'),
              ],
            ),
          ),
          Text('\$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      children: [
        _buildTotalRow('Subtotal', subtotal),
        _buildTotalRow('Tax', tax),
        Divider(),
        _buildTotalRow('Total', total, isTotal: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('**** **** **** 1234'),
            subtitle: Text('Expires 12/2025'),
            trailing: TextButton(
              child: Text('Change'),
              onPressed: () {
                // TODO: Implement change payment method
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return ElevatedButton(
      child: Text('Complete Purchase'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 16),
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: () {
        // TODO: Implement checkout process
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase completed! Thank you for your order.')),
        );
      },
    );
  }
}