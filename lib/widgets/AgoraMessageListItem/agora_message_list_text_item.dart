import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';

class AgoraMessageListTextItem extends StatelessWidget {
  const AgoraMessageListTextItem({
    super.key,
    required this.model,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.onResendTap,
    this.avatarBuilder,
    this.nicknameBuilder,
  });

  final AgoraMessageListItemModel model;
  final AgoraMessageTapAction? onTap;
  final AgoraMessageTapAction? onBubbleLongPress;
  final AgoraMessageTapAction? onBubbleDoubleTap;
  final VoidCallback? onResendTap;
  final AgoraWidgetBuilder? avatarBuilder;
  final AgoraWidgetBuilder? nicknameBuilder;

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
    return AgoraMessageBubble(
      model: model,
      childBuilder: (context) {
        return content;
      },
      onBubbleDoubleTap: onBubbleDoubleTap,
      onBubbleLongPress: onBubbleLongPress,
      onTap: onTap,
      avatarBuilder: avatarBuilder,
      nicknameBuilder: nicknameBuilder,
      onResendTap: onResendTap,
    );
  }
}
