import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class AgoraDialog {
  const AgoraDialog({
    required this.titleLabel,
    this.titleStyle,
    required this.items,
    this.content,
  });
  final String titleLabel;
  final Widget? content;
  final TextStyle? titleStyle;
  final List<AgoraDialogItem> items;

  Future<T?>? show<T>(BuildContext context) {
    List<Widget> list = [];

    for (var item in items) {
      list.add(
        InkWell(
          onTap: item.onTap,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                item.label,
                style: item.labelStyle ??
                    Theme.of(context).dialogItemLabelDefaultStyle,
              ),
            ),
          ),
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
          titlePadding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
          actionsOverflowAlignment: OverflowBarAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: Center(
            child: Text(
              titleLabel,
              style: titleStyle,
            ),
          ),
          content: content,
          actions: list,
        );
      },
    );
  }
}

class AgoraDialogItem {
  AgoraDialogItem({
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color.fromRGBO(250, 250, 250, 1),
    this.labelStyle,
  });
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final TextStyle? labelStyle;
}
