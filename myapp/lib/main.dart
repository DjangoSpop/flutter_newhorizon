import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.call), text: "Calls"),
                Tab(icon: Icon(Icons.message), text: "Messages"),
                Tab(icon: Icon(Icons.contacts), text: "UserStory")
              ],
            ),
            title: const Text('WhatsAPP'),
          ),
          body: const TabBarView(
            children: [
              CallsTab(),
              MessagesTab(),
              ContactsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) => Container(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 25,
              ),
              const SizedBox(height: 16),
              const Text(
                "John Doe",
                style: TextStyle(fontSize: 20.0),
              ),
              const Text("bibo")
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        itemCount: 10,
      ),
    );
  }
}

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => Card(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Ahmed Riad',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '01007255532',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text('11:25'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: 35,
    );
  }
}

class Message {
  final String sender;
  final String messageText;
  final String? timestamp;

  Message({required this.sender, required this.messageText, this.timestamp});
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: 25,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text('Mahmoud'), // Display first letter of sender
            ),
            title: Text('ahmed'),
            subtitle: Text('hello good morning '),
            trailing: Text('11:35'),
          );
        },
      ),
    );
  }
}
