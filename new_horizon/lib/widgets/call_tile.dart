import 'package:flutter/material.dart';

class CallTile extends StatelessWidget {
  final String name;
  final String time;
  final IconData callType;

  CallTile({
    required this.name,
    required this.time,
    required this.callType,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red,
        child: Icon(callType, color: Colors.white),
      ),
      title: Text(name),
      subtitle: Text(time),
      trailing: Icon(Icons.call),
    );
  }
}
