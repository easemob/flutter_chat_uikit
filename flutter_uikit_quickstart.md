# Get started with Agora Chat UIKit

Instant messaging connects people wherever they are and allows them to communicate with others in real time. With built-in user interfaces (UI) for the conversation list the [Agora Chat UI Samples]() enables you to quickly embed real-time messaging into your app without requiring extra effort on the UI.

This page shows a sample code to add peer-to-peer messaging into your app by using the Agora Chat UI Samples.

## Understand the tech
The following figure shows the workflow of how clients send and receive peer-to-peer messages:

![agora_chat](https://docs.agora.io/en/assets/images/get-started-sdk-understand-009486abec0cc276183ab535456cf889.png)

1. Clients retrieve a token from your app server.
2. Client A and Client B log in to Agora Chat.
3. Client A sends a message to Client B. The message is sent to the Agora Chat server and the server delivers the message to Client B. When Client B receives the message, the SDK triggers an event. Client B listens for the event and gets the message.

## Prerequisites

If your target platform is iOS, your development environment must meet the following requirements:
- Flutter 2.10 or later
- Dart 2.16 or later
- macOS
- Xcode 12.4 or later with Xcode Command Line Tools
- CocoaPods
- An iOS simulator or a real iOS device running iOS 10.0 or later

If your target platform is Android, your development environment must meet the following requirements:
- Flutter 2.10 or later
- Dart 2.16 or later
- macOS or Windows
- Android Studio 4.0 or later with JDK 1.8 or later
- An Android simulator or a real Android device running Android SDK API level 21 or later

<div class="alert note">You need to run <code>flutter doctor</code> to check whether both the development environment and the deployment environment are correct.</div>



## Token generation

This section describes how to register a user at Agora Console and generate a temporary token.

### Register a user

To generate a user ID, do the following:

1. On the **Project Management** page, click **Config** for the project you want to use.

![](https://web-cdn.agora.io/docs-files/1664531061644)

2. On the **Edit Project** page, click **Config** next to **Chat** below **Features**.

![](https://web-cdn.agora.io/docs-files/1664531091562)

3. In the left-navigation pane, select **Operation Management** > **User** and click **Create User**.

![](https://web-cdn.agora.io/docs-files/1664531141100)

4. In the **Create User** dialog box, fill in the **User ID**, **Nickname**, and **Password**, and click **Save** to create a user.

![](https://web-cdn.agora.io/docs-files/1664531162872)

### Generate a user token

To ensure communication security, Agora recommends using tokens to authenticate users logging in to an Agora Chat system.

For testing purposes, Agora Console supports generating Agora chat tokens. To generate an Agora chat token, do the following:

1. On the **Project Management** page, click **Config** for the project you want to use.

![](https://web-cdn.agora.io/docs-files/1664531061644)

2. On the **Edit Project** page, click **Config** next to **Chat** below **Features**.

![](https://web-cdn.agora.io/docs-files/1664531091562)

3. In the **Data Center** section of the **Application Information** page, enter the user ID in the **Chat User Temp Token** box and click **Generate** to generate a token with user privileges.

![](https://web-cdn.agora.io/docs-files/1664531214169)

## Project setup

### 1. Create a Flutter project

Open a terminal, enter a directory in which you want to create a Flutter project, and run the following command to create a project folder named `uikit_quick_start`:

```
flutter create uikit_quick_start --platforms=android,ios
```


### 2. Set up the project

#### Android setup

1. In the `uikit_quick_start/android/app/build.gradle` file, add the following lines at the end to set the minimum Android SDK version to 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

2. In the `uikit_quick_start/android/app/proguard-rules.pro` file, add the following lines to prevent code obfuscation:

```java
-keep class com.hyphenate.** {*;}
-dontwarn  com.hyphenate.**
```

3. Add permissions for network and device access.

In `uikit_quick_start/android/app/src/main/AndroidManifest.xml`, add the following permissions after </application>:

```xml
...
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
...
```

#### iOS setup

1. Open the `uikit_quick_start/ios/Runner.xcodeproj` file in **Xcode**, and select **TARGETS** > **Runner** in the left sidebar. In the **Deployment Info** section under the **General** tab, set the minimum iOS version to **iOS 10.0**.

2. Add permissions for device access.
Open the `Info.plist` and add:
* `Privacy - Microphone Usage Description`，and add some description into the Value column.
* `Privacy - Camera Usage Description`, and add some description into the Value column.
* `Privacy - Photo Library Usage Description`, and add some description into the Value column.


### 3. Integrate the Agora Chat SDK

Open a terminal, enter the `uikit_quick_start` directory, and run the following command to add the `agora_chat_uikit` dependency:

```
flutter pub add agora_chat_uikit
flutter pub get
```
## Implement peer-to-peer messaging


Create a new page `uikit_quick_start/lib/MessagesPage.dart`:

```dart
import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage(this.conversation, {super.key});

  final ChatConversation conversation;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id)),
      body: SafeArea(
        child: AgoraMessagesView(conversation: widget.conversation),
      ),
    );
  }
}

```


At the top lines of the `uikit_quick_start/lib/main.dart` file, add the following to import packages:

```dart
import 'package:flutter/material.dart';
import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:uikit_quick_start/messages_page.dart';

// Replaces <#Your app key#>, <#Your created user#>, and <#User Token#> and with your own App Key, user ID, and user token generated in Agora Console.
class AgoraChatConfig {
  static const String appKey = "<#Your app key#>";
  static const String userId = "<#Your created user#>";
  static const String agoraToken = "<#User Token#>";
}
```

Replace the lines of the `main` method with the following:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = ChatOptions(appKey: AgoraChatConfig.appKey);
  await ChatClient.getInstance.init(options);
  runApp(const MyApp());
}
```

Replace the lines of the `MyApp` class with the following:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) => AgoraChatUIKit(child: child!),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

Replace the lines of the `_MyHomePageState` class with the following:

```dart
class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  ChatConversation? conversation;
  String _chatId = "";
  final List<String> _logText = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10),
            const Text("login userId: ${AgoraChatConfig.userId}"),
            const Text("agoraToken: ${AgoraChatConfig.agoraToken}"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () {
                      _signIn();
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                    child: const Text("SIGN IN"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _signOut();
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                    child: const Text("SIGN OUT"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Enter recipient's userId",
                    ),
                    onChanged: (chatId) => _chatId = chatId,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    pushToChatPage(_chatId);
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlue),
                  ),
                  child: const Text("START CHAT"),
                )
              ],
            ),
            Flexible(
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (_, index) {
                  return Text(_logText[index]);
                },
                itemCount: _logText.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pushToChatPage(String userId) async {
    if (userId.isEmpty) {
      _addLogToConsole('UserId is null');
      return;
    }
    if (ChatClient.getInstance.currentUserId == null) {
      _addLogToConsole('user not login');
      return;
    }
    ChatConversation? conv =
        await ChatClient.getInstance.chatManager.getConversation(userId);
    Future(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return MessagesPage(conv!);
      }));
    });
  }

  void _signIn() async {
    _addLogToConsole('begin sign in...');
    try {
      await ChatClient.getInstance.loginWithAgoraToken(
        AgoraChatConfig.userId,
        AgoraChatConfig.agoraToken,
      );
      _addLogToConsole('sign in success');
    } on ChatError catch (e) {
      _addLogToConsole('sign in fail: ${e.description}');
    }
  }

  void _signOut() async {
    _addLogToConsole('begin sign out...');
    try {
      await ChatClient.getInstance.logout();
      _addLogToConsole('sign out success');
    } on ChatError catch (e) {
      _addLogToConsole('sign out fail: ${e.description}');
    }
  }

  void _addLogToConsole(String log) {
    _logText.add("$_timeString: $log");
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
```


## Test your app

To validate the peer-to-peer messaging you have just integrated into your app using Agora Chat, perform the following operations to test the project:


### 1. Log in
a. Replace the placeholders of appKey, userId, and agoraToken in the AgoraChatConfig class with the App Key, user ID, and Agora token of the sender.

b. Select the device to run the project, run flutter run in the uikit_quick_start directory, and click the SIGN IN button.

### 2. Push to MessagesPage
Fill in the user ID of the receiver in the Enter recipient's user Id box, and click START CHAT to push the messages page.

### 3. Send a message
On the MessagesPage page, click the input box, enter the information to be sent, and click the Send button.