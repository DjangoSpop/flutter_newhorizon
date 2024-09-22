import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20, // Replace with actual chat list length
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text('U${index + 1}'),
          ),
          title: Text('User ${index + 1}'),
          subtitle: Text('Last message...'),
          trailing: Text('12:00 PM'),
          onTap: () {
            // TODO: Navigate to chat detail page
          },
        );
      },
    );
  }
}
