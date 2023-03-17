import 'package:flutter/material.dart';

import 'agora_swipe_change_notification.dart';
import 'agora_swipe_gesture_controller.dart';

class AgoraSwipeAutoCloseBehavior extends StatefulWidget {
  const AgoraSwipeAutoCloseBehavior({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  State<StatefulWidget> createState() => _AgoraSwipeAutoCloseBehaviorState();
}

class _AgoraSwipeAutoCloseBehaviorState
    extends State<AgoraSwipeAutoCloseBehavior> {
  AgoraSwipeGestureController? _lastController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content =
        NotificationListener<AgoraSwipeControllerClearNotification>(
      onNotification: (notification) {
        if (_lastController == notification.controller) {
          _lastController = null;
        }
        return true;
      },
      child: widget.child,
    );

    return NotificationListener<AgoraSwipeChangeNotification>(
      onNotification: (notification) {
        if (_lastController != null &&
            _lastController != notification.controller) {
          _lastController?.close();
        }
        _lastController = notification.controller;
        return true;
      },
      child: content,
    );
  }

  @override
  void didUpdateWidget(covariant AgoraSwipeAutoCloseBehavior oldWidget) {
    _lastController = null;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _lastController = null;
    super.dispose();
  }
}
