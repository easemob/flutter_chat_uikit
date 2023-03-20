import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class AgoraSwipeItem {
  const AgoraSwipeItem({
    required this.text,
    this.dismissed,
    this.itemWidth = 80,
    this.backgroundColor = Colors.white,
    this.confirmAction,
    this.style = const TextStyle(color: Colors.white),
  });

  final void Function(bool dismissed)? dismissed;
  final TextStyle style;
  final String text;
  final Color backgroundColor;
  final double itemWidth;
  final AgoraConfirmDismissCallback? confirmAction;
}
