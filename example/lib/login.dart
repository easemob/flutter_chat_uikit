import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ui_kit_demo/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _pwdOrAgoraTokenController =
      TextEditingController();

  String get userId => _userIdController.text;
  String get tokenOrPwd => _pwdOrAgoraTokenController.text;

  @override
  Widget build(BuildContext context) {
    _userIdController.text = Config.userId;
    _pwdOrAgoraTokenController.text = Config.pwdOrAgoraToken;
    Widget content = Column(
      children: [
        Expanded(
          child: TextField(
            controller: _userIdController,
            decoration: const InputDecoration(hintText: "userId"),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _pwdOrAgoraTokenController,
            decoration:
                const InputDecoration(hintText: "password / agoraToken"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: loginWithPassword,
                child: const Text("login password")),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
                onPressed: loginWithAgoraToken,
                child: const Text("login agoraToken"))
          ],
        ),
      ],
    );

    content = SizedBox(
        height: 150,
        width: MediaQuery.of(context).size.width - 50,
        child: content);

    content = Center(child: content);

    return Scaffold(
      appBar: AppBar(title: const Text("AgoraChatUIKit Demo")),
      body: content,
    );
  }

  Future<void> loginWithAgoraToken() async {
    if (userId.isEmpty || tokenOrPwd.isEmpty) {
      EasyLoading.showError('userId or agora token is null');
      return;
    }
    EasyLoading.show(status: "Sign in...");
    try {
      await ChatClient.getInstance.loginWithAgoraToken(userId, tokenOrPwd);
      pushToHome();
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> loginWithPassword() async {
    if (userId.isEmpty || tokenOrPwd.isEmpty) {
      EasyLoading.showError('userId or password is null');
      return;
    }
    EasyLoading.show(status: "Sign in...");
    try {
      await ChatClient.getInstance.login(userId, tokenOrPwd);
      pushToHome();
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    } finally {
      EasyLoading.dismiss();
    }
  }

  void pushToHome() {
    Navigator.of(context).pushReplacementNamed("home");
  }
}
