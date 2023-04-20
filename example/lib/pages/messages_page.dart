import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage(this.conversation, {super.key});

  final ChatConversation conversation;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late AgoraMessageListController controller;

  final TextEditingController _textEditingController = TextEditingController();

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
          // inputBarTextEditingController: _textEditingController,
          // inputBarText: _inputText,
          onError: (error) {
            final snackBar = SnackBar(content: Text(error.description));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          conversation: widget.conversation,
          messageListViewController: controller,
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

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}