import 'dart:math';

class AgoraRandomKey {
  static String get randomKey => Random().nextInt(999999999).toString();
}
