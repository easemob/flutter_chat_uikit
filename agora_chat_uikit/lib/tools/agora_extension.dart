import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import 'agora_tools.dart';

extension ChatMessageExt on ChatMessage {
  String get summary {
    String ret = "";
    switch (body.type) {
      case MessageType.TXT:
        {
          String str = (body as ChatTextMessageBody).content;
          ret = str;
        }
        break;
      case MessageType.IMAGE:
        ret = "[图片]";
        break;
      case MessageType.VIDEO:
        ret = "[视频]";
        break;
      case MessageType.LOCATION:
        ret = "[位置]";
        break;
      case MessageType.VOICE:
        ret = "[音频]";
        break;
      case MessageType.FILE:
        ret = "[文件]";
        break;
      case MessageType.CMD:
        ret = "";
        break;
      case MessageType.CUSTOM:
        ret = "[自定义]";
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
