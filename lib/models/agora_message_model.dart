import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class AgoraMessageListItemModel {
  const AgoraMessageListItemModel(this.message, [this.needTime = false]);
  final ChatMessage message;
  final bool needTime;

  String get msgId => message.msgId;

  AgoraMessageListItemModel copyWithMsg(ChatMessage message) {
    return AgoraMessageListItemModel(message, needTime);
  }

  AgoraMessageListItemModel copyWithNeedTime(bool needTime) {
    return AgoraMessageListItemModel(message, needTime);
  }
}
