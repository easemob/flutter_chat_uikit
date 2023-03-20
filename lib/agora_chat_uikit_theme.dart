import 'package:flutter/material.dart';

extension AgoraUIKitThemeData on ThemeData {
  Color get appBarShadowColor => Colors.transparent;
  Color get appBarBackgroundColor => const Color.fromRGBO(251, 251, 251, 1);
  Color get appBarBackIconColor => Colors.black;
  TextStyle get appBarTitleTextStyle =>
      const TextStyle(fontWeight: FontWeight.w400, color: Colors.black);
  Color get agoraBadgeColor => const Color.fromRGBO(255, 20, 204, 1);
  Color get agoraBadgeBorderColor => Colors.white;
  TextStyle get agoraBadgeTextTheme =>
      const TextStyle(fontWeight: FontWeight.w500, color: Colors.white);
  double get agoraBadgeBorderWidth => 2.0;
  TextStyle get agoraMessagesListItemTs =>
      const TextStyle(color: Colors.grey, fontSize: 14);
  TextStyle get agoraBottomSheetItemLabelDefaultStyle => const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black);
  TextStyle get agoraDialogItemLabelDefaultStyle => const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black);
  TextStyle get agoraDialogContentDefaultStyle => const TextStyle(
        fontSize: 14,
        color: Color.fromRGBO(108, 113, 146, 1),
        height: 2,
      );
}
