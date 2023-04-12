import 'package:flutter/material.dart';

extension AgoraUIKitThemeData on ThemeData {
  Color get badgeColor => const Color.fromRGBO(255, 20, 204, 1);

  Color get badgeBorderColor => Colors.white;

  Color get sendVoiceMessageItemSpeakerIconColor =>
      const Color.fromRGBO(169, 169, 169, 1);

  Color get receiveVoiceMessageItemSpeakerIconColor => Colors.white;

  TextStyle get sendVoiceMessageItemDurationTextStyle => const TextStyle(
        color: Colors.white,
      );

  TextStyle get receiveVoiceMessageItemDurationTextStyle => const TextStyle(
        color: Colors.black,
      );

  TextStyle get badgeTextTheme => const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  double get badgeBorderWidth => 2.0;

  TextStyle get conversationListItemTitleStyle => const TextStyle(
        fontSize: 17,
      );

  TextStyle get conversationListItemSubTitleStyle => const TextStyle(
        fontSize: 14,
        overflow: TextOverflow.ellipsis,
      );

  TextStyle get conversationListItemTsStyle => const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      );

  TextStyle get messagesListItemTs => const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      );

  TextStyle get bottomSheetItemLabelDefaultStyle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      );

  TextStyle get bottomSheetItemLabelRecallStyle => const TextStyle(
      color: Color.fromRGBO(255, 20, 204, 1),
      fontWeight: FontWeight.w400,
      fontSize: 18);

  TextStyle get dialogItemLabelDefaultStyle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      );
}
