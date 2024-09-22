import 'package:flutter/material.dart';
import '../widgets/chat_tile.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ChatTile(
          name: 'Contact $index',
          message: 'Last message here...',
          time: '12:30 PM',
        );
      },
    );
  }
}
