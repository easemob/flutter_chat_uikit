# Get Started with Agora Chat UIKit for Flutter

## Overview

agora_chat_uikit is a UI component library based on agora_chat_sdk. It provides general UI components and modules containing business logic, including Chat, ConversationList, ContactList and other modules. These components allow users to customize and customize sub-components at a smaller level using common UI components. Developers can use the library to quickly build custom IM applications based on actual business requirements.

'agora_chat_uikit' currently has 2 modular widget:

`AgoraConversationsView` AgoraConversationsView is a conversation information page that displays existing conversation. And support for custom avatar and nickname operations.

`AgoraMessagesView` AgoraMessagesView is used to display message information, currently supports text, image, voice, and file messages. The profile avatar and nickname can be set through callbacks.

agora offers an open source agora_chat_uikit project on GitHub. You can clone and run the project or refer to the logic in it to create projects integrating agora_chat_uikit.

Source code URL of agora_chat_uikit for flutter:

* https://github.com/easemob/flutter_chat_uikit


## Dependencies

Some third party UI libraries are used in Agora_chat_uikit, as follows:

```dart
dependencies:
  agora_chat_sdk: 1.1.0
  image_picker: 0.8.6+4
  file_picker: 4.6.1
  record: 4.4.4
  audioplayers: 3.0.1
  common_utils: 2.1.0
```

## Permissions

### Android

```dart
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```
### iOS

Open info.plist and add:

```
Privacy - Microphone Usage Description, and add a note in the Value column.
Privacy - Camera Usage Description, and add a note in the Value column.
Privacy - Photo Library Usage Description.
```

## Prevent code obfuscation

In the example/android/app/proguard-rules.pro file, add the following lines to prevent code obfuscation:
```
-keep class com.hyphenate.** {*;}
-dontwarn  com.hyphenate.**
```

## Getting started

Integrate uikit, which can be downloaded locally or integrated through git.

### Local integration

```dart
dependencies:
    agora_chat_uikit:
        path: `<#uikit path#>`
```

### Github integration

```dart
dependencies:
    agora_chat_uikit:
        git:
            url: https://github.com/easemob/flutter_chat_uikit.git
            ref: dev
```

## Usage

You need to make sure the agora chat sdk is initialized before calling AgoraChatUIKik and AgoraChatUIKit widget at the top of you widget tree. You can add it in the `MaterialApp` builder.

```dart
import 'package:agora_chat_uikit/agora_chat_uikit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child){
        return AgoraChatUIKit(child: child!);
      },
      home: const MyHomePage(title: 'Flutter Demo'),
    );
  }
}
```

When you have logged in and entered the main page, you need to call the `AgoraChatUIKit.of(context).uiSetup` method to tell agora_chat_uikit that you have logged in.

```dart
AgoraChatUIKit.of(context).uiSetup;
```

### AgoraConversationsView

The 'AgoraConversationsView' allows you to quickly display and manage the current conversations.

```dart
class _ConversationsPageState extends State<ConversationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversations")),
      body: AgoraConversationsView(
        onItemTap: (conversation) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (ctx) => ChatPage(conversation),
                ),
              )
              .then((value) => AgoraChatUIKit.of(context)
                  .conversationsController
                  .loadAllConversations());
        },
      ),
    );
  }
}
```

For more information, see `AgoraConversationsView`

```dart
  const AgoraConversationsView({
    super.key,
    this.onItemTap,
    this.controller,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.down,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.avatarBuilder,
    this.nicknameBuilder,
  });
```

### AgoraMessagesView

The `AgoraMessagesView` is used to manage and send and receive messages. It supports picture, text, voice, and file messages. It also supports operations such as deleting and recall messages.

```dart
class _ChatPageState extends State<ChatPage> {
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

For more information, see `AgoraMessagesView`

```dart
  const AgoraMessagesView({
    super.key,
    this.inputBar,
    required this.conversation,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.avatarBuilder,
    this.nicknameBuilder,
    this.titleAvatarBuilder,
    this.moreItems,
    this.messageListViewController,
    this.willSendMessage,
  });
```


#### Customize colors

You can set the color when adding `AgoraChatUIKit`. See `AgoraUIKitTheme`.

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
      builder: (context, child) => AgoraChatUIKit(
        theme: AgoraUIKitTheme(
          sendBubbleColor: Colors.red,
          receiveBubbleColor: Colors.blue,
        ),
        child: child!,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

#### Add avatar

```dart
class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id)),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          avatarBuilder: (context, userId) {
            // Returns the avatar Widget that you want to display.
            return Container(
              width: 30,
              height: 30,
              color: Colors.red,
            );
          },
        ),
      ),
    );
  }
}
```

#### Add nickname

```dart
class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id)),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          // Returns the nickname Widget that you want to display.
          nicknameBuilder: (context, userId) {
            return Text(userId);
          },
        ),
      ),
    );
  }
}

```

#### Add bubble click event

```dart
class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id)),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          onTap: (context, message) {
            bubbleClicked(message);
            return true;
          },
        ),
      ),
    );
  }

  void bubbleClicked(ChatMessage message) {
    debugPrint('bubble clicked');
  }
}
```

### Custom message item widget

```dart
class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id)),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          itemBuilder: (context, model) {
            if (model.message.body.type == MessageType.TXT) {
              return CustomTextItemWidget(
                model: model,
                onTap: (context, message) {
                  bubbleClicked(message);
                  return true;
                },
              );
            }
          },
        ),
      ),
    );
  }

  void bubbleClicked(ChatMessage message) {
    debugPrint('bubble clicked');
  }
}

class CustomTextItemWidget extends AgoraMessageListItem {
  const CustomTextItemWidget({super.key, required super.model, super.onTap});

  @override
  Widget build(BuildContext context) {
    ChatTextMessageBody body = model.message.body as ChatTextMessageBody;

    Widget content = Text(
      body.content,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 50,
        fontWeight: FontWeight.w400,
      ),
    );
    return getBubbleWidget(content);
  }
}

```

### Customize the input widget

```dart
class _MessagesPageState extends State<MessagesPage> {
  late AgoraMessageListController _msgController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _msgController = AgoraMessageListController(widget.conversation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.id)),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          messageListViewController: _msgController,
          inputBar: inputWidget(),
        ),
      ),
    );
  }

  Widget inputWidget() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _textController,
          )),
          ElevatedButton(
              onPressed: () {
                final msg = ChatMessage.createTxtSendMessage(
                    targetId: widget.conversation.id,
                    content: _textController.text);
                _textController.text = '';
                _msgController.sendMessage(msg);
              },
              child: const Text('Send'))
        ],
      ),
    );
  }
}

```

### Delete all Messages in the current conversation

```dart
class _MessagesPageState extends State<MessagesPage> {
  late AgoraMessageListController _msgController;

  @override
  void initState() {
    super.initState();
    _msgController = AgoraMessageListController(widget.conversation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.id),
        actions: [
          TextButton(
              onPressed: () {
                _msgController.deleteAllMessages();
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          messageListViewController: _msgController,
        ),
      ),
    );
  }
}
```

### Customize the long - press pop-up menu

```dart
class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.id),
      ),
      body: SafeArea(
        child: AgoraMessagesView(
          conversation: widget.conversation,
          inputBarMoreActionsOnTap: (items) {
            AgoraBottomSheetItem item =
                AgoraBottomSheetItem('more', onTap: customMoreAction);

            return items + [item];
          },
        ),
      ),
    );
  }

  void customMoreAction() {
    debugPrint('custom action');
    Navigator.of(context).pop();
  }
}
```

## example

See the example for the effect.

### quick start

If demo is required, configure the following information in the `example/lib/main.dart` file:

// Replaces <#Your app key#>, <#Your created user#>, and <#User Token#> and with your own App Key, user ID, and user token generated in Agora Console.

```dart
class AgoraChatConfig {
  static String appkey = <#Your app key#>;
  static String userId = <#Your created user#>;
  static String agoraToken = <#User Token#>;
}
```

## License

The sample projects are under the MIT license.