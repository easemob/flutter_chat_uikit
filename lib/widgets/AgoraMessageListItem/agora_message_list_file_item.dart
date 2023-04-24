import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageListItem/agora_message_list_item.dart';

import 'package:flutter/material.dart';

class AgoraMessageListFileItem extends AgoraMessageListItem {
  const AgoraMessageListFileItem({
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
    ChatFileMessageBody body = message.body as ChatFileMessageBody;

    List<Widget> list = [];
    list.add(Text(
      body.displayName ?? "File",
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          overflow: TextOverflow.ellipsis),
    ));
    int fileSize = body.fileSize ?? 0;
    if (fileSize > 0) {
      list.add(Text(
        AgoraSizeTool.fileSize(fileSize),
        style: const TextStyle(
            fontSize: 12, color: Color.fromRGBO(102, 102, 102, 1)),
      ));
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );

    content = Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      textDirection: isLeft ? TextDirection.ltr : TextDirection.rtl,
      children: [
        Expanded(child: content),
        const SizedBox(width: 13),
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Icon(
            Icons.insert_drive_file,
            size: 36,
            color: Color.fromRGBO(151, 156, 187, 1),
          ),
        )
      ],
    );

    content = SizedBox(height: 46, width: 225, child: content);

    return getBubbleWidget(content);
  }
}
