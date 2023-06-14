import 'package:flutter/widgets.dart';

import '../themes/chat_uikit_theme.dart';

class ChatUIKitWidget extends StatefulWidget {
  ChatUIKitWidget({
    super.key,
    this.child,
    ChatUIKitTheme? theme,
  }) : theme = theme ?? ChatUIKitTheme();
  final Widget? child;
  final ChatUIKitTheme theme;

  static Widget init({TransitionBuilder? builder}) {
    if (builder != null) {}
    return ChatUIKitWidget();
  }

  @override
  State<ChatUIKitWidget> createState() => ChatUIKitWidgetState();

  static ChatUIKitWidgetState of(BuildContext context) {
    ChatUIKitWidgetState? state;
    state = context.findAncestorStateOfType<ChatUIKitWidgetState>();
    assert(
      state != null,
      'You must have a ChatUIKitWidget widget at the top of the widget',
    );
    return state!;
  }
}

class ChatUIKitWidgetState extends State<ChatUIKitWidget> {
  ChatUIKitTheme get theme => widget.theme;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? Container();
  }
}
