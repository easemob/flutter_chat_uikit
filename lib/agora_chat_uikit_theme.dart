import 'package:flutter/material.dart';

class AgoraUIKitTheme {
  AgoraUIKitTheme({
    this.badgeColor = const Color.fromRGBO(255, 20, 204, 1),
    this.badgeBorderColor = Colors.white,
    this.sendVoiceItemIconColor = const Color.fromRGBO(169, 169, 169, 1),
    this.receiveVoiceItemIconColor = Colors.white,
    this.sendBubbleColor = const Color.fromRGBO(0, 65, 255, 1),
    this.receiveBubbleColor = const Color.fromRGBO(242, 242, 242, 1),
    this.badgeTextStyle =
        const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
    this.sendVoiceItemDurationStyle = const TextStyle(color: Colors.white),
    this.receiveVoiceItemDurationStyle = const TextStyle(color: Colors.black),
    this.conversationListItemTitleStyle = const TextStyle(fontSize: 17),
    this.conversationListItemSubTitleStyle =
        const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),
    this.conversationListItemTsStyle =
        const TextStyle(color: Colors.grey, fontSize: 14),
    this.messagesListItemTsStyle =
        const TextStyle(color: Colors.grey, fontSize: 14),
    this.bottomSheetItemLabelNormalStyle = const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
    this.bottomSheetItemLabelRecallStyle = const TextStyle(
        color: Color.fromRGBO(255, 20, 204, 1),
        fontWeight: FontWeight.w400,
        fontSize: 18),
    this.dialogItemLabelNormalStyle = const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
  });
  final Color badgeColor;
  final Color badgeBorderColor;
  final Color sendVoiceItemIconColor;
  final Color receiveVoiceItemIconColor;
  final Color sendBubbleColor;
  final Color receiveBubbleColor;
  final TextStyle badgeTextStyle;
  final TextStyle sendVoiceItemDurationStyle;
  final TextStyle receiveVoiceItemDurationStyle;
  final TextStyle conversationListItemTitleStyle;
  final TextStyle conversationListItemSubTitleStyle;
  final TextStyle conversationListItemTsStyle;
  final TextStyle messagesListItemTsStyle;
  final TextStyle bottomSheetItemLabelNormalStyle;
  final TextStyle bottomSheetItemLabelRecallStyle;
  final TextStyle dialogItemLabelNormalStyle;
}
