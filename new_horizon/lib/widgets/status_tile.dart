import 'package:flutter/material.dart';

class StatusTile extends StatelessWidget {
  final String name;
  final String time;

  StatusTile({
    required this.name,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey,
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(time),
    );
  }
}
