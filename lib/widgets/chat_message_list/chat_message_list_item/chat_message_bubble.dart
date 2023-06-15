import 'package:flutter/material.dart';

import '../../../flutter_chat_uikit.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
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
    this.maxWidth,
  });

  final double? maxWidth;
  final ChatMessageListItemModel model;
  final ChatMessageTapAction? onTap;
  final ChatMessageTapAction? onBubbleLongPress;
  final ChatMessageTapAction? onBubbleDoubleTap;
  final ChatWidgetBuilder? avatarBuilder;
  final ChatWidgetBuilder? nicknameBuilder;

  final VoidCallback? onResendTap;
  final WidgetBuilder childBuilder;
  final WidgetBuilder? unreadFlagBuilder;
  final Color? bubbleColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    double max = maxWidth ?? MediaQuery.of(context).size.width * 0.7;
    final boxConstraints = BoxConstraints(maxWidth: max);
    EMMessage message = model.message;
    bool isLeft = message.direction == MessageDirection.RECEIVE;
    Widget content = Container(
      decoration: BoxDecoration(
        color: bubbleColor ??
            (isLeft
                ? ChatUIKit.of(context).theme.receiveBubbleColor
                : ChatUIKit.of(context).theme.sendBubbleColor),
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

      insideBubbleWidgets.add(Flexible(flex: 1, child: content));

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

    insideBubbleWidgets.add(Flexible(flex: 1, child: content));
    insideBubbleWidgets.add(SizedBox(width: isLeft ? 0 : 10.4));

    if (!isLeft) {
      insideBubbleWidgets
          .add(ChatMessageStatusWidget(message, onTap: onResendTap));
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
                  TimeTool.timeStrByMs(message.serverTime),
                  style: ChatUIKit.of(context).theme.messagesListItemTsStyle,
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
