import 'package:flutter/material.dart';

import '../../../flutter_chat_uikit.dart';

class ChatMessageListTextItem extends ChatMessageListItem {
  final TextStyle? contentStyle;

  const ChatMessageListTextItem({
    super.key,
    required super.model,
    this.contentStyle,
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
    EMMessage message = model.message;
    bool isLeft = message.direction == MessageDirection.RECEIVE;
    EMTextMessageBody body = message.body as EMTextMessageBody;

    Widget content = Text(body.content,
        style: contentStyle ??
            (isLeft
                ? ChatUIKitWidget.of(context).theme.receiveTextStyle
                : ChatUIKitWidget.of(context).theme.sendTextStyle));

    return getBubbleWidget(content);
  }
}
