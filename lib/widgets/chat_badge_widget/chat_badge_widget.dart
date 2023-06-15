import 'package:flutter/material.dart';
import 'package:flutter_chat_uikit/flutter_chat_uikit.dart';

class ChatBadgeWidget extends StatelessWidget {
  const ChatBadgeWidget(
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
                color: ChatUIKit.of(context).theme.badgeColor,
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
                color: ChatUIKit.of(context).theme.badgeColor,
                border: Border.all(
                  color: ChatUIKit.of(context).theme.badgeBorderColor,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(30))),
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Text(
              style: ChatUIKit.of(context).theme.badgeTextStyle,
              unreadStr,
            ),
          );
        }
      }(),
    );
  }
}
