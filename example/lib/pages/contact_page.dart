import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<String> users = [];
  List<String> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select users"),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop(selectedUsers);
            },
            child: UnconstrainedBox(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Builder(builder: (ctx) {
                  String text = "Done";
                  if (selectedUsers.isNotEmpty) {
                    text += "(${selectedUsers.length})";
                  }
                  return Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  );
                }),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        displacement: 40,
        notificationPredicate: defaultScrollNotificationPredicate,
        child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              String userId = users[index];
              bool selected = (selectedUsers.contains(userId));

              return InkWell(
                onTap: () {
                  if (selected) {
                    selectedUsers.remove(userId);
                    setState(() {});
                  } else {
                    bool canAdd = false;
                    if (selectedUsers.isEmpty) {
                      canAdd = true;
                    }
                    if (canAdd) {
                      selectedUsers.add(userId);
                      setState(() {});
                    }
                  }
                },
                child: Card(
                  color: selected ? Colors.black : Colors.white, // 背景色
                  elevation: 3,
                  child: Container(
                    width: 100,
                    height: 60,
                    alignment: Alignment.center,
                    child: Text(
                      userId,
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<void> refresh() async {
    try {
      List<String> list = await ChatClient.getInstance.contactManager
          .getAllContactsFromServer();
      users.clear();
      selectedUsers.clear();
      users.addAll(list);
      if (mounted) {
        setState(() {});
      }
      // ignore: empty_catches
    } catch (e) {}
  }
}
