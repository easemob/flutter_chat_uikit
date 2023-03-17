import 'package:flutter/material.dart';

import 'agora_swipe_gesture_controller.dart';

class AgoraSwipeScrollingCloseBehavior extends StatefulWidget {
  const AgoraSwipeScrollingCloseBehavior({
    super.key,
    required this.child,
    required this.controller,
  });

  final AgoraSwipeGestureController? controller;

  final Widget child;

  @override
  AgoraSwipeScrollingCloseBehaviorState createState() =>
      AgoraSwipeScrollingCloseBehaviorState();
}

class AgoraSwipeScrollingCloseBehaviorState
    extends State<AgoraSwipeScrollingCloseBehavior> {
  ScrollPosition? scrollPosition;
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    removeScrollingListener();
    addScrollingListener();
  }

  void addScrollingListener() {
    scrollPosition = Scrollable.of(context).position;
    if (scrollPosition != null) {
      scrollPosition!.isScrollingNotifier.addListener(handleScrollingChanged);
    }
  }

  void removeScrollingListener() {
    scrollPosition?.isScrollingNotifier.removeListener(handleScrollingChanged);
  }

  @override
  void dispose() {
    removeScrollingListener();
    super.dispose();
  }

  void handleScrollingChanged() {
    widget.controller?.willClear(context);
    widget.controller?.close();
  }
}
