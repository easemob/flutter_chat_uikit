import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/material.dart';

class AgoraMessageListFileItem extends StatelessWidget {
  const AgoraMessageListFileItem({
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
            // fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color.fromRGBO(102, 102, 102, 1)),
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

    return AgoraMessageBubble(
      bubbleColor: const Color.fromRGBO(242, 242, 242, 1),
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
