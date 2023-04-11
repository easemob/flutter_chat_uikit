import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.conversation, {super.key});

  final ChatConversation conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late AgoraMessageListController controller;

  @override
  void initState() {
    super.initState();
    controller = AgoraMessageListController(widget.conversation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id)),
      body: SafeArea(
        child: AgoraMessagesView(
          messageListViewController: controller,
          avatarBuilder: (context, userId) {
            return AgoraImageLoader.defaultAvatar();
          },
          nicknameBuilder: (context, userId) {
            return Text(userId);
          },
          conversation: widget.conversation,
          onTap: (context, message) {
            return false;
          },
          onBubbleLongPress: (context, message) {
            return false;
          },
          onBubbleDoubleTap: (context, message) {
            return false;
          },
        ),
      ),
    );
  }
}
