import 'dart:math';

import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

/// Custom display conversation list profile picture nickname, click event monitoring.
class ConversationPage1 extends StatefulWidget {
  const ConversationPage1({super.key});

  @override
  State<ConversationPage1> createState() => _ConversationPage1State();
}

class _ConversationPage1State extends State<ConversationPage1> {
  @override
  Widget build(BuildContext context) {
    return AgoraConversationsView(
      avatarBuilder: (context, conversation) {
        return Container(
          width: 50,
          height: 50,
          color: Color.fromRGBO(
            Random().nextInt(255),
            Random().nextInt(255),
            Random().nextInt(255),
            1,
          ),
        );
      },
      nicknameBuilder: (context, conversation) {
        return Text(
          conversation.id,
          style: TextStyle(
              color: Color.fromRGBO(
            Random().nextInt(255),
            Random().nextInt(255),
            Random().nextInt(255),
            1,
          )),
        );
      },
      onItemTap: (conversation) {
        final snackBar = SnackBar(
            content: Text('Tap on conversation: ${conversation.id}'),
            duration: const Duration(milliseconds: 500));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }
}
