import 'package:flutter/material.dart';

class AgoraTextField extends TextField {
  const AgoraTextField({super.key});

  @override
  State<AgoraTextField> createState() => _AgoraTextFieldState();
}

class _AgoraTextFieldState extends State<AgoraTextField> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
