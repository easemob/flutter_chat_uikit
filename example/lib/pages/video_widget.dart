import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageListItem/agora_message_list_item.dart';
import 'package:flutter/material.dart';

class VideoWidget extends AgoraMessageListItem {
  const VideoWidget({
    super.key,
    required super.model,
    super.avatarBuilder,
  });

  @override
  EdgeInsets? get bubblePadding => EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    ChatVideoMessageBody body = model.message.body as ChatVideoMessageBody;
    double max = 200.0;
    double width = body.width ?? max;
    double height = body.height ?? max;

    double ratio = width / height;
    if (ratio <= 0.5 || ratio >= 2) {
      max = max / 3 * 4;
    }
    if (width > height) {
      height = max / width * height;
      width = max;
    } else {
      width = max / height * width;
      height = max;
    }

    Widget content = SizedBox(
      width: width,
      height: height,
      child: Image.network(body.thumbnailRemotePath!),
    );

    content = Stack(
      children: [
        content,
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: Colors.black,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );

    content = SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: content,
      ),
    );

    return getBubbleWidget(content);
  }
}
