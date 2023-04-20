import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'messages_page.dart';

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
      appBar: AppBar(
        title: const Text("Conversations"),
        actions: [
          InkWell(
            onTap: deleteAllConversations,
            child: UnconstrainedBox(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Builder(builder: (ctx) {
                  return const Text('Clear All',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
                }),
              ),
            ),
          )
        ],
      ),
      body: AgoraConversationsView(
        onItemTap: (conversation) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (ctx) => ChatPage(conversation),
                ),
              )
              .then((value) => AgoraChatUIKit.of(context)
                  .conversationsController
                  .loadAllConversations());
        },
      ),
    );
  }

  void deleteAllConversations() {
    AgoraDialog(
      titleLabel: "Clear All Conversations",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      items: [
        AgoraDialogItem(
          label: "Cancel",
          onTap: () => Navigator.of(context).pop(),
          labelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        AgoraDialogItem(
          label: "Confirm",
          onTap: () {
            AgoraChatUIKit.of(context)
                .conversationsController
                .deleteAllConversations();
            Navigator.of(context).pop();
          },
          backgroundColor: const Color.fromRGBO(17, 78, 255, 1),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ).show(context);
  }
}
