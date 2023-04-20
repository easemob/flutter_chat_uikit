import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'config.dart';
import 'home.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var options =
      ChatOptions(appKey: Config.appkey, debugModel: true, autoLogin: true);
  await ChatClient.getInstance.init(options);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(
        builder: (context, child) {
          return AgoraChatUIKit(
            child: child!,
          );
        },
      ),
      title: 'AgoraChat UIKit Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      theme: ThemeData(
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      home: const MyHomePage(title: 'AgoraChat UIKit Demo'),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: ((context) {
          if (settings.name == 'login') {
            return const LoginPage();
          } else if (settings.name == 'home') {
            return const HomePage();
          } else {
            return Container();
          }
        }));
      },
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: ChatClient.getInstance.isLoginBefore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(color: Colors.red);
          }
          return getWidget(snapshot.data!);
        },
      ),
    );
  }

  Widget getWidget(bool hasSignIn) {
    if (hasSignIn) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
