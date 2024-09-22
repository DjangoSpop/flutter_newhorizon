import 'package:flutter/material.dart';

class Contacts extends StatelessWidget {
  const Contacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Container(
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                Card(
                  child: Text('Ahmed'),
                ),
                CircleAvatar(
                  backgroundColor: Color.fromRGBO(155, 155, 50, 10),
                  backgroundImage: AssetImage(
                      'C:\Users\ahmed el bahi\flutter_newhorizon\new_horizon\assets\images\whatsapp.svg'),
                ),
                Card(
                  child: Text('01007255532'),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
