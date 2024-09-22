import 'package:flutter/material.dart';
import '../widgets/status_tile.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return StatusTile(
          name: 'Contact $index',
          time: 'Today, 12:30 PM',
        );
      },
    );
  }
}
