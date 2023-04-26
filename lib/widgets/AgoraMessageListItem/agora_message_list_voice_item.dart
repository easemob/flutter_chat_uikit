import 'dart:math';

import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';

import 'agora_message_list_item.dart';

class AgoraMessageListVoiceItem extends AgoraMessageListItem {
  const AgoraMessageListVoiceItem({
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
    ChatMessage message = model.message;
    bool isLeft = message.direction == MessageDirection.RECEIVE;
    ChatVoiceMessageBody body = message.body as ChatVoiceMessageBody;
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
              ? AgoraAnimWidget(
                  items: [
                    Transform.scale(
                        scaleX: isLeft ? 1 : -1,
                        child: AgoraImageLoader.loadImage(
                          "voice_0.png",
                          color: isLeft
                              ? Theme.of(context)
                                  .sendVoiceMessageItemSpeakerIconColor
                              : Theme.of(context)
                                  .receiveVoiceMessageItemSpeakerIconColor,
                        )),
                    Transform.scale(
                        scaleX: isLeft ? 1 : -1,
                        child: AgoraImageLoader.loadImage(
                          "voice_1.png",
                          color: isLeft
                              ? Theme.of(context)
                                  .sendVoiceMessageItemSpeakerIconColor
                              : Theme.of(context)
                                  .receiveVoiceMessageItemSpeakerIconColor,
                        )),
                    Transform.scale(
                        scaleX: isLeft ? 1 : -1,
                        child: AgoraImageLoader.loadImage(
                          "voice_2.png",
                          color: isLeft
                              ? Theme.of(context)
                                  .sendVoiceMessageItemSpeakerIconColor
                              : Theme.of(context)
                                  .receiveVoiceMessageItemSpeakerIconColor,
                        )),
                  ],
                )
              : Transform.scale(
                  scaleX: isLeft ? 1 : -1,
                  child: AgoraImageLoader.loadImage(
                    "voice_2.png",
                    color: isLeft
                        ? Theme.of(context).sendVoiceMessageItemSpeakerIconColor
                        : Theme.of(context)
                            .receiveVoiceMessageItemSpeakerIconColor,
                  ),
                ),
        ),
        Text(
          AgoraTimeTool.durationStr(body.duration),
          style: !isLeft
              ? Theme.of(context).sendVoiceMessageItemDurationTextStyle
              : Theme.of(context).receiveVoiceMessageItemDurationTextStyle,
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
}
