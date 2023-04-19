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
        ret = "[${AppLocalizations.of(context)?.agoraImage ?? "Image"}]";
        break;
      case MessageType.VIDEO:
        ret = "[${AppLocalizations.of(context)?.agoraVideo ?? "Video"}]";
        break;
      case MessageType.LOCATION:
        ret = "[${AppLocalizations.of(context)?.agoraLocation ?? "Location"}]";
        break;
      case MessageType.VOICE:
        ret = "[${AppLocalizations.of(context)?.agoraAudio ?? "Audio"}]";
        break;
      case MessageType.FILE:
        ret = "[${AppLocalizations.of(context)?.agoraFile ?? "File"}]";
        break;
      case MessageType.CUSTOM:
        ret = "[${AppLocalizations.of(context)?.agoraCustom ?? "Custom"}]";
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
