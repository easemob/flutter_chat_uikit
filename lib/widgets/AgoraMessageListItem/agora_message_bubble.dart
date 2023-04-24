import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'agora_message_status_widget.dart';

class AgoraMessageBubble extends StatelessWidget {
  const AgoraMessageBubble({
    super.key,
    required this.model,
    required this.childBuilder,
    this.unreadFlagBuilder,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.avatarBuilder,
    this.nicknameBuilder,
    this.onResendTap,
    this.bubbleColor,
    this.padding,
  });

  final AgoraMessageListItemModel model;
  final AgoraMessageTapAction? onTap;
  final AgoraMessageTapAction? onBubbleLongPress;
  final AgoraMessageTapAction? onBubbleDoubleTap;
  final AgoraWidgetBuilder? avatarBuilder;
  final AgoraWidgetBuilder? nicknameBuilder;

  final VoidCallback? onResendTap;
  final WidgetBuilder childBuilder;
  final WidgetBuilder? unreadFlagBuilder;
  final Color? bubbleColor;
  final EdgeInsets? padding;

  final boxConstraints = const BoxConstraints(maxWidth: 260);

  @override
  Widget build(BuildContext context) {
    ChatMessage message = model.message;
    bool isLeft = message.direction == MessageDirection.RECEIVE;
    Widget content = Container(
      decoration: BoxDecoration(
        color: bubbleColor ??
            (isLeft
                ? const Color.fromRGBO(242, 242, 242, 1)
                : const Color.fromRGBO(0, 65, 255, 1)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft:
              !isLeft ? const Radius.circular(10) : const Radius.circular(3),
          bottomRight:
              isLeft ? const Radius.circular(10) : const Radius.circular(3),
        ),
      ),
      constraints: boxConstraints,
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: childBuilder(context),
      ),
    );

    List<Widget> insideBubbleWidgets = [];

    if (nicknameBuilder != null) {
      insideBubbleWidgets.add(
        Container(
          constraints: boxConstraints,
          child: nicknameBuilder!.call(context, message.from!),
        ),
      );

      insideBubbleWidgets.add(Flexible(child: content));

      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: insideBubbleWidgets.toList(),
      );
      insideBubbleWidgets.clear();
    }

    if (avatarBuilder != null) {
      insideBubbleWidgets.add(avatarBuilder!.call(context, message.from!));
      insideBubbleWidgets.add(const SizedBox(width: 10));
    }

    insideBubbleWidgets.add(content);
    insideBubbleWidgets.add(SizedBox(width: isLeft ? 0 : 10.4));

    if (!isLeft) {
      insideBubbleWidgets
          .add(AgoraMessageStatusWidget(message, onTap: onResendTap));
    }
    content = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: isLeft ? TextDirection.ltr : TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: insideBubbleWidgets.toList(),
    );

    insideBubbleWidgets.clear();

    if (unreadFlagBuilder != null && isLeft) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          content,
          const SizedBox(
            width: 10,
          ),
          unreadFlagBuilder!.call(context)
        ],
      );
    }

    content = Padding(
      padding: EdgeInsets.fromLTRB(15, 15, isLeft ? 7.5 : 15, 15),
      child: content,
    );

    content = InkWell(
      onDoubleTap: () => onBubbleDoubleTap?.call(context, message),
      onTap: () => onTap?.call(context, message),
      onLongPress: () => onBubbleLongPress?.call(context, message),
      child: content,
    );

    if (model.needTime) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 20,
                child: Text(
                  AgoraTimeTool.timeStrByMs(message.serverTime),
                  style: Theme.of(context).messagesListItemTs,
                ),
              ),
            ),
          ),
          content
        ],
      );
    }
    return content;
  }
}
