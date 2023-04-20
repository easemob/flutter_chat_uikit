import 'package:agora_chat_uikit/agora_chat_uikit.dart';

class AgoraChatUIKitError {
  static int noPermission = -10;
  static int recordTimeTooShort = -11;

  static ChatError toChatError(int code, String desc) {
    return ChatError.fromJson({"code": code, "description": desc});
  }
}
