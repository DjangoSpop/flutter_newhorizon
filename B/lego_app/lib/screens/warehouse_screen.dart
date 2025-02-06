import 'package:flutter/material.dart';

class WarhousesScreen extends StatefulWidget {
  const WarhousesScreen({super.key});

  @override
  State<WarhousesScreen> createState() => _WarhousesScreenState();
}

class _WarhousesScreenState extends State<WarhousesScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          TextButton(onPressed: null, child: Card()),
        ],
      ),
    );
  }
}
