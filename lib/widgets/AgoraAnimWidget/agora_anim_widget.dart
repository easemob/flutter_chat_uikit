import 'package:flutter/material.dart';

class AgoraAnimWidget extends StatefulWidget {
  const AgoraAnimWidget({
    super.key,
    required this.items,
    this.duration = const Duration(milliseconds: 1000),
  });
  final List<Widget> items;
  final Duration duration;

  @override
  State<AgoraAnimWidget> createState() => _AgoraAnimWidgetState();
}

class _AgoraAnimWidgetState extends State<AgoraAnimWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<int> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    animation =
        IntTween(begin: 0, end: widget.items.length - 1).animate(controller)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    return widget.items[animation.value];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
