import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversations")),
      body: AgoraConversationsView(
        onItemTap: (conversation) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) {
                return ChatPage(conversation);
              },
            ),
          ).then((value) => AgoraChatUIKit.of(context)
              .conversationsController
              .loadAllConversations());
        },
        nicknameBuilder: (context, conversation) {
          return Text("custom ${conversation.id}");
        },
      ),
    );
  }
}
