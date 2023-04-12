import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/widgets.dart';

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
