import 'package:flutter/material.dart';
import 'package:ui_kit_demo/conversation/conversation_page2.dart';

import '../conversation/conversation_page1.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversation Custom")),
      body: ListView(
        children: [
          getItem("ConversationPage1", const ConversationPage1()),
          getItem("ConversationPage2", const ConversationPage2()),
        ],
      ),
    );
  }

  Widget getItem(String name, Widget widget) {
    return InkWell(
      child: ListTile(
        title: Text(name),
        onTap: () => pushRoute(name, widget),
      ),
    );
  }

  void pushRoute(String name, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: widget,
      );
    }));
  }
}
