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

  final FocusNode _inputFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    controller = AgoraMessageListController(widget.conversation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.id),
        actions: [
          InkWell(
            onTap: deleteAllMessages,
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
      body: SafeArea(
        child: AgoraMessagesView(
          onError: (error) {
            final snackBar = SnackBar(content: Text(error.description));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          conversation: widget.conversation,
          messageListViewController: controller,
          avatarBuilder: (context, userId) => AgoraImageLoader.defaultAvatar(),
          nicknameBuilder: (context, userId) => Text(userId),
          // needDismissInputWidgetAction: () {
          //   _inputFocusNode.unfocus();
          // },
          // inputBar: TextField(
          //   focusNode: _inputFocusNode,
          //   decoration: const InputDecoration(hintText: "inputText"),
          //   onSubmitted: (value) {
          //     debugPrint("run! $value");
          //     final msg = ChatMessage.createTxtSendMessage(
          //         targetId: widget.conversation.id, content: value);
          //     controller.sendMessage(msg);
          //   },
          // ),
        ),
      ),
    );
  }

  void deleteAllMessages() {
    AgoraDialog(
      titleLabel: "Clear All Messages",
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
            controller.deleteAllMessages();
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
