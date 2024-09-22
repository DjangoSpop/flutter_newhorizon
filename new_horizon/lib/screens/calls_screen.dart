import 'package:flutter/material.dart';
import '../widgets/call_tile.dart';

class CallsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return CallTile(
          name: 'Contact $index',
          time: 'Yesterday, 12:30 PM',
          callType: index % 2 == 0 ? Icons.call_received : Icons.call_made,
        );
      },
    );
  }
}
