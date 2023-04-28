import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:agora_chat_uikit/agora_chat_uikit_theme.dart';
import 'package:flutter/material.dart';

class AgoraBadgeWidget extends StatelessWidget {
  const AgoraBadgeWidget(
    this.unreadCount, {
    super.key,
    this.maxCount = 99,
  });
  final int unreadCount;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: () {
        if (unreadCount == 0) {
          return const Offstage();
        } else if (unreadCount < 0) {
          return Container(
            decoration: BoxDecoration(
                color: AgoraChatUIKit.of(context).agoraTheme.badgeColor,
                borderRadius: const BorderRadius.all(Radius.circular(30))),
            width: 10,
            height: 10,
          );
        } else {
          String unreadStr = unreadCount.toString();
          if (unreadCount > maxCount) {
            unreadStr = '$maxCount+';
          }
          return Container(
            decoration: BoxDecoration(
                color: AgoraChatUIKit.of(context).agoraTheme.badgeColor,
                border: Border.all(
                  color: AgoraChatUIKit.of(context).agoraTheme.badgeBorderColor,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(30))),
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Text(
              style: AgoraChatUIKit.of(context).agoraTheme.badgeTextStyle,
              unreadStr,
            ),
          );
        }
      }(),
    );
  }
}
