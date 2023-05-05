import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/widgets.dart';

class AgoraChatUIKit extends StatefulWidget {
  AgoraChatUIKit({
    required this.child,
    AgoraChatUIKitTheme? theme,
    super.key,
  }) {
    agoraTheme = theme ?? AgoraChatUIKitTheme();
  }
  final Widget child;

  /// agora chat uikit theme for setting component styles. If not set, the default style will be used.
  late final AgoraChatUIKitTheme agoraTheme;

  @override
  State<AgoraChatUIKit> createState() => AgoraChatUIKitState();

  static AgoraChatUIKitState of(BuildContext context) {
    AgoraChatUIKitState? state;
    state = context.findAncestorStateOfType<AgoraChatUIKitState>();
    assert(
      state != null,
      'You must have a AgoraChatUIKit widget at the top of you widget tree',
    );

    return state!;
  }
}

class AgoraChatUIKitState extends State<AgoraChatUIKit> {
  late final AgoraConversationsController _controller;

  @override
  void initState() {
    super.initState();
    assert(
      ChatClient.getInstance.options != null,
      'You must has init AgoraChat SDK.',
    );

    _controller = AgoraConversationsController();
  }

  AgoraConversationsController get conversationsController {
    return _controller;
  }

  AgoraChatUIKitTheme get agoraTheme => widget.agoraTheme;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
