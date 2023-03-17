import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/widgets.dart';

class AgoraChatUIKit extends StatefulWidget {
  const AgoraChatUIKit({
    required this.child,
    super.key,
  });

  final Widget child;

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
  late final AgoraConversationListController _controller;

  @override
  void initState() {
    super.initState();
    assert(
      ChatClient.getInstance.options != null,
      'You must has init AgoraChat SDK.',
    );
    _controller = AgoraConversationListController();
  }

  AgoraConversationListController get conversationsController {
    return _controller;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void uiSetup() {
    ChatClient.getInstance.startCallback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
