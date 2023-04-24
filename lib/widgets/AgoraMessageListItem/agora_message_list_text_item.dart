import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';

import 'agora_message_list_item.dart';

class AgoraMessageListTextItem extends AgoraMessageListItem {
  const AgoraMessageListTextItem({
    super.key,
    required super.model,
    super.onTap,
    super.onBubbleLongPress,
    super.onBubbleDoubleTap,
    super.onResendTap,
    super.avatarBuilder,
    super.nicknameBuilder,
    super.bubbleColor,
    super.bubblePadding,
    super.unreadFlagBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ChatMessage message = model.message;
    bool isLeft = message.direction == MessageDirection.RECEIVE;
    ChatTextMessageBody body = message.body as ChatTextMessageBody;

    Widget content = Text(
      body.content,
      style: TextStyle(
        color: isLeft ? Colors.black : Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    );

    return getBubbleWidget(content);
  }
}
