import 'package:flutter/material.dart';
import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'pages/second_page.dart';

const String appKey = "easemob-demo#flutter";
const String userId = "du001";
const String password = "1";
const String agoraToken = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var option = ChatOptions(appKey: appKey, autoLogin: false);
  await ChatClient.getInstance.init(option);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(
        builder: (context, child) {
          return AgoraChatUIKit(child: child!);
        },
      ),
      home: const MyHomePage(title: 'AgoraChatUIKit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: appKey.isNotEmpty &&
                      userId.isNotEmpty &&
                      (agoraToken.isNotEmpty || password.isNotEmpty)
                  ? _loginAgoraChat
                  : null,
              child: const Text("sign in"),
            ),
            ElevatedButton(
              onPressed: appKey.isNotEmpty &&
                      userId.isNotEmpty &&
                      (agoraToken.isNotEmpty || password.isNotEmpty)
                  ? _logoutAgoraChat
                  : null,
              child: const Text("sign out"),
            ),
          ],
        ),
      ),
    );
  }

  void _loginAgoraChat() async {
    EasyLoading.show(status: 'sign in');
    try {
      if (password.isEmpty) {
        await ChatClient.getInstance.loginWithAgoraToken(userId, agoraToken);
      } else {
        await ChatClient.getInstance.login(userId, password);
      }
      _pushToChatPage();
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _logoutAgoraChat() async {
    EasyLoading.show(status: 'sign out');
    try {
      await ChatClient.getInstance.logout();
    } on ChatError catch (e) {
      EasyLoading.showError(e.description);
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _pushToChatPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return const SecondPage();
    }));
  }
}
