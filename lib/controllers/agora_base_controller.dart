import 'package:agora_chat_uikit/tools/agora_random_key.dart';

class AgoraBaseController {
  AgoraBaseController({String? key}) : key = key ?? AgoraRandomKey.randomKey;
  late final String key;
}
