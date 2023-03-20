import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class AgoraBottomSheet {
  AgoraBottomSheet({
    this.backgroundColor = Colors.white,
    required this.items,
    this.height = 250,
    this.titleLabel,
  });
  final Color backgroundColor;

  final List<AgoraBottomSheetItem> items;
  final double height;
  final String? titleLabel;

  Future<T?>? show<T>(BuildContext context) {
    if (items.isEmpty) return null;
    List<Widget> list = [];
    if (titleLabel != null) {
      list.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
        child: Center(
          child: Text(
            titleLabel!,
            style: const TextStyle(
                color: Color.fromRGBO(102, 102, 102, 1), fontSize: 14),
          ),
        ),
      ));
    } else {
      list.add(const SizedBox(height: 10));
    }

    for (var item in items) {
      list.add(
        InkWell(
          onTap: item.onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            height: 48,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                item.label,
                style: item.labelStyle ??
                    Theme.of(context).agoraBottomSheetItemLabelDefaultStyle,
              ),
            ),
          ),
        ),
      );
    }
    list.add(const SizedBox(height: 10));
    return showModalBottomSheet(
      backgroundColor: backgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      )),
      builder: (context) {
        return SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: list,
        ));
      },
    );
  }
}

class AgoraBottomSheetItem {
  AgoraBottomSheetItem(
    this.label, {
    required this.onTap,
    this.backgroundColor = const Color.fromRGBO(250, 250, 250, 1),
    this.labelStyle,
  });
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final TextStyle? labelStyle;
}
