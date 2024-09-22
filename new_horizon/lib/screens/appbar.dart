import 'package:flutter/material.dart';
import 'package:new_horizon/widgets/call_tile.dart';
import 'package:new_horizon/widgets/chat_tile.dart';
import 'calls.dart';
import 'Contacts.dart';
import 'settings.dart';
import 'help.dart';

class NewHome extends StatelessWidget {
  const NewHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              // Add action here
            },
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add action here
            },
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Add action here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(),
          ChatTile(
            name: 'Bahi',
            message: 'We can do this',
            time: '25 min ago',
          ),
          Divider(),
          ChatTile(
            name: 'Bahi',
            message: 'We can do this',
            time: '25 min ago',
          ),
          ChatTile(
            name: 'Bahi',
            message: 'We can do this',
            time: '25 min ago',
          ),
          ChatTile(
            name: 'Bahi',
            message: 'We can do this',
            time: '25 min ago',
          ),
          CallTile(name: 'ahmed', time: '35', callType: Icons.call),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 10),
                Text(
                  'Camera',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.call),
              title: Text('Calls'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Calls()),
                );
                // Add action here
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Contacts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Contacts()),
                );
                // Add action here
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
                // Add action here
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Help()),
                );
                // Add action here
              },
            ),
          ],
        ),
      ),
    );
  }
}
