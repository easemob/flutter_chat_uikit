import 'dart:io';
import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

class AgoraMessageListImageItem extends StatelessWidget {
  const AgoraMessageListImageItem({
    super.key,
    required this.model,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.onResendTap,
    this.avatarBuilder,
    this.nicknameBuilder,
  });

  final AgoraMessageListItemModel model;
  final AgoraMessageTapAction? onTap;
  final AgoraMessageTapAction? onBubbleLongPress;
  final AgoraMessageTapAction? onBubbleDoubleTap;
  final VoidCallback? onResendTap;
  final AgoraWidgetBuilder? avatarBuilder;
  final AgoraWidgetBuilder? nicknameBuilder;

  @override
  Widget build(BuildContext context) {
    ChatMessage message = model.message;
    ChatImageMessageBody body = message.body as ChatImageMessageBody;
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

    Widget content;
    if (message.direction == MessageDirection.SEND) {
      content = Image(
          gaplessPlayback: true,
          image: ResizeImage(
            FileImage(
              File(body.localPath),
            ),
            width: width.toInt(),
            height: height.toInt(),
          ),
          fit: BoxFit.fill);
    } else if (body.thumbnailStatus == DownloadStatus.SUCCESS &&
        body.thumbnailLocalPath != null) {
      content = Image(
          gaplessPlayback: true,
          image: ResizeImage(
            FileImage(
              File(body.thumbnailLocalPath!),
            ),
            width: width.toInt(),
            height: height.toInt(),
          ),
          fit: BoxFit.fill);
    } else if (body.fileStatus == DownloadStatus.SUCCESS) {
      content = Image(
          gaplessPlayback: true,
          image: ResizeImage(
            FileImage(
              File(body.localPath),
            ),
            width: width.toInt(),
            height: height.toInt(),
          ),
          fit: BoxFit.fill);
    } else {
      content = Container(
        color: const Color.fromRGBO(242, 242, 242, 1),
        child: FadeInImage(
            placeholderFit: BoxFit.contain,
            placeholder: AgoraImageLoader.assetImage("download_img.png"),
            image: NetworkImage(body.thumbnailRemotePath!),
            imageErrorBuilder: (context, error, stackTrace) {
              return AgoraImageLoader.loadImage("download_img_failed.png",
                  fit: BoxFit.contain);
            },
            fit: BoxFit.fill),
      );
    }

    return AgoraMessageBubble(
      bubbleColor: Colors.transparent,
      onBubbleDoubleTap: onBubbleDoubleTap,
      onBubbleLongPress: onBubbleLongPress,
      onTap: onTap,
      avatarBuilder: avatarBuilder,
      nicknameBuilder: nicknameBuilder,
      onResendTap: onResendTap,
      padding: EdgeInsets.zero,
      model: model,
      childBuilder: (context) {
        return SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: content,
          ),
        );
      },
    );
  }
}
