import 'package:flutter/widgets.dart';

import '../../agora_chat_uikit_define.dart';
import '../../models/agora_message_model.dart';
import 'agora_message_bubble.dart';

class AgoraMessageListItem extends StatelessWidget {
  const AgoraMessageListItem({
    super.key,
    required this.model,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.onResendTap,
    this.avatarBuilder,
    this.nicknameBuilder,
    this.bubbleColor,
    this.bubblePadding,
    this.unreadFlagBuilder,
  });

  final AgoraMessageListItemModel model;
  final AgoraMessageTapAction? onTap;
  final AgoraMessageTapAction? onBubbleLongPress;
  final AgoraMessageTapAction? onBubbleDoubleTap;
  final VoidCallback? onResendTap;
  final AgoraWidgetBuilder? avatarBuilder;
  final AgoraWidgetBuilder? nicknameBuilder;
  final Color? bubbleColor;
  final EdgeInsets? bubblePadding;
  final WidgetBuilder? unreadFlagBuilder;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget getBubbleWidget(Widget content) {
    return AgoraMessageBubble(
      model: model,
      padding: bubblePadding,
      bubbleColor: bubbleColor,
      childBuilder: (context) {
        return content;
      },
      unreadFlagBuilder: unreadFlagBuilder,
      onBubbleDoubleTap: onBubbleDoubleTap,
      onBubbleLongPress: onBubbleLongPress,
      onTap: onTap,
      avatarBuilder: avatarBuilder,
      nicknameBuilder: nicknameBuilder,
      onResendTap: onResendTap,
    );
  }
}
