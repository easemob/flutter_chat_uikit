import 'dart:io';
import 'package:flutter/widgets.dart';
import '../agora_chat_uikit.dart';

extension ChatMessageExt on ChatMessage {
  String summary(BuildContext context) {
    String ret = "";
    switch (body.type) {
      case MessageType.TXT:
        {
          String str = (body as ChatTextMessageBody).content;
          ret = str;
        }
        break;
      case MessageType.IMAGE:
        ret = "[${AppLocalizations.of(context)!.image}]";
        break;
      case MessageType.VIDEO:
        ret = "[${AppLocalizations.of(context)!.video}]";
        break;
      case MessageType.LOCATION:
        ret = "[${AppLocalizations.of(context)!.location}]";
        break;
      case MessageType.VOICE:
        ret = "[${AppLocalizations.of(context)!.audio}]";
        break;
      case MessageType.FILE:
        ret = "[${AppLocalizations.of(context)!.file}]";
        break;
      case MessageType.CUSTOM:
        ret = "[${AppLocalizations.of(context)!.custom}]";
        break;
      case MessageType.CMD:
        ret = "";
        break;
    }
    return ret;
  }

  String get createTs {
    return AgoraTimeTool.timeStrByMs(serverTime);
  }
}

extension AgoraFileExtension on File {
  int get sizeInBytes => lengthSync();
}
