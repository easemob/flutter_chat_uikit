import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';

import 'pages/contact_page.dart';
import 'pages/messages_page.dart';
import 'pages/conversations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    AgoraChatUIKit.of(context).uiSetup;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("AgoraChatUIKit"),
        leading: null,
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: _pushToConversationsPage,
            child: const SizedBox(
              height: 60,
              child: Center(
                child: Text("ConversationsPage"),
              ),
            ),
          ),
          InkWell(
            onTap: _pushToChatPage,
            child: const SizedBox(
              height: 60,
              child: Center(
                child: Text("ChatPage"),
              ),
            ),
          ),
          InkWell(
            onTap: _pushToSelectContactPage,
            child: const SizedBox(
              height: 60,
              child: Center(
                child: Text("Select contact"),
              ),
            ),
          ),
          InkWell(
            onTap: _logout,
            child: const SizedBox(
              height: 60,
              child: Center(
                child: Text("logout"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pushToConversationsPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const ConversationsPage();
    }));
  }

  void _pushToChatPage() {
    AgoraDialog(
      titleLabel: "Input user id",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      content: SizedBox(
        height: 40,
        width: 280,
        child: TextField(
          controller: _controller,
          cursorColor: Colors.blue,
          onChanged: (text) {},
          decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(250, 250, 250, 1),
              contentPadding: EdgeInsets.fromLTRB(14, 0, 14, 0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              hintText: "user id",
              hintStyle: TextStyle(color: Colors.grey)),
          obscureText: false,
        ),
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
            Navigator.of(context).pop(_controller.text);
          },
          backgroundColor: const Color.fromRGBO(17, 78, 255, 1),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ).show(context)?.then((value) {
      if (value != null) {
        String input = value as String;
        if (input.isNotEmpty) {
          return ChatClient.getInstance.chatManager.getConversation(value);
        }
      }
    }).then((value) {
      if (value == null) return;
      ChatConversation conv = value as ChatConversation;
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return MessagesPage(conv);
      }));
    });
  }

  void _pushToSelectContactPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const ContactPage();
    })).then((value) {
      if (value != null && value is List<String>) {
        return ChatClient.getInstance.chatManager.getConversation(value.first);
      }
    }).then((value) {
      ChatConversation conv = value as ChatConversation;
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return MessagesPage(conv);
      }));
    });
  }

  void _logout() async {
    ChatClient.getInstance.logout().then((value) {
      Navigator.of(context).pushReplacementNamed("login");
    });
  }
}
