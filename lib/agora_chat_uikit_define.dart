import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/widgets.dart';
import 'agora_chat_uikit_type.dart';

typedef AgoraWidgetBuilder = Widget Function(
    BuildContext context, String userId);

typedef AgoraConversationWidgetBuilder = Widget? Function(
  BuildContext context,
  ChatConversation conversation,
);

typedef AgoraConversationTextBuilder = String? Function(
  ChatConversation conversation,
);

typedef AgoraMessageListItemBuilder = Widget? Function(
    BuildContext context, ChatMessage message);

typedef AgoraMessageTapAction = bool Function(
    BuildContext context, ChatMessage message);

typedef AgoraConfirmDismissCallback = Future<bool> Function(
    BuildContext context);

typedef AgoraConversationItemWidgetBuilder = Widget? Function(
    BuildContext context, int index, ChatConversation conversation);

typedef AgoraConversationSortHandle = Future<List<ChatConversation>> Function(
    List<ChatConversation> beforeList);

typedef PermissionRequest = Future<bool> Function(
    AgoraChatUIKitPermission permission);

typedef AgoraRecallHandler = ChatMessage? Function(
    ChatMessage didRecallMessage);
