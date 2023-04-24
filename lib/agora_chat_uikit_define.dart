import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/widgets.dart';
import 'agora_chat_uikit_type.dart';
import 'models/agora_message_model.dart';
import 'widgets/AgoraBottomSheet/agora_bottom_sheet.dart';

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
    BuildContext context, AgoraMessageListItemModel model);

typedef AgoraMessageTapAction = bool Function(
    BuildContext context, ChatMessage message);

typedef AgoraConfirmDismissCallback = Future<bool> Function(
    BuildContext context);

typedef AgoraConversationItemWidgetBuilder = Widget? Function(
    BuildContext context, int index, ChatConversation conversation);

typedef AgoraConversationSortHandle = Future<List<ChatConversation>> Function(
    List<ChatConversation> beforeList);

typedef AgoraPermissionRequest = Future<bool> Function(
    AgoraChatUIKitPermission permission);

typedef AgoraReplaceMessage = ChatMessage? Function(ChatMessage message);

typedef AgoraReplaceMoreActions = List<AgoraBottomSheetItem> Function(
    List<AgoraBottomSheetItem> items);
