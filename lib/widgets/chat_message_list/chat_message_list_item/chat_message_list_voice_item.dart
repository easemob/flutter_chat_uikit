import 'package:flutter/material.dart';

import '../../../flutter_chat_uikit.dart';

class ChatMessageListVoiceItem extends ChatMessageListItem {
  const ChatMessageListVoiceItem({
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
    this.isPlay = false,
  });

  final bool isPlay;

  @override
  Widget build(BuildContext context) {
    EMMessage message = model.message;
    bool isLeft = message.direction == MessageDirection.RECEIVE;
    EMVoiceMessageBody body = message.body as EMVoiceMessageBody;
    double max = getMaxWidth(context);
    double width = body.duration / 60 * max;
    Widget content = Row(
      textDirection: isLeft ? TextDirection.ltr : TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: isPlay
              ? ChatPlayVoiceAnimWidget(
                  items: [
                    getImage(context, 'voice_0.png', isLeft),
                    getImage(context, 'voice_1.png', isLeft),
                    getImage(context, 'voice_2.png', isLeft),
                  ],
                )
              : getImage(context, 'voice_2.png', isLeft),
        ),
        Text(
          TimeTool.durationStr(body.duration),
          style: !isLeft
              ? ChatUIKit.of(context).theme.sendTextStyle
              : ChatUIKit.of(context).theme.receiveTextStyle,
        ),
      ],
    );

    content = Container(
      constraints: BoxConstraints(
        maxHeight: max,
        minWidth: width,
      ),
      child: content,
    );

    return getBubbleWidget(content);
  }

  Widget getImage(BuildContext context, String imageName, bool isLeft) {
    return Transform.scale(
      scaleX: isLeft ? 1 : -1,
      child: ChatImageLoader.loadImage(
        imageName,
        color: isLeft
            ? ChatUIKit.of(context).theme.sendVoiceItemIconColor
            : ChatUIKit.of(context).theme.receiveVoiceItemIconColor,
      ),
    );
  }
}
