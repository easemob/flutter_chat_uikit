import 'dart:io';

import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:flutter/material.dart';

import 'agora_message_list_item.dart';

class AgoraMessageListImageItem extends AgoraMessageListItem {
  const AgoraMessageListImageItem({
    super.key,
    required super.model,
    super.onTap,
    super.onBubbleLongPress,
    super.onBubbleDoubleTap,
    super.onResendTap,
    super.avatarBuilder,
    super.nicknameBuilder,
    super.bubbleColor,
    super.bubblePadding,
    super.unreadFlagBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ChatMessage message = model.message;
    ChatImageMessageBody body = message.body as ChatImageMessageBody;

    double max = getMaxWidth(context);
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

    // if (width / height >= 10) {
    //   final w = max;
    //   width = w;
    //   height = w * 0.1;
    // } else if (width * 4 >= height * 3) {
    //   final w = max;
    //   height = w * (height / width);
    //   width = w;
    // } else if (width * 10 > height) {
    //   final h = max * 4 / 3;
    //   width = width / height * h;
    //   height = h;
    // } else {
    //   final h = max * 4 / 3;
    //   width = 0.1 * h;
    //   height = h;
    // }

    Widget content;

    if (message.direction == MessageDirection.SEND) {
      content = Image(
          gaplessPlayback: true,
          image: ResizeImage(
            FileImage(File(body.localPath)),
            width: width.toInt(),
            height: height.toInt(),
          ),
          fit: BoxFit.fill);
    } else if (body.thumbnailStatus == DownloadStatus.SUCCESS &&
        body.thumbnailLocalPath != null) {
      content = Image(
          gaplessPlayback: true,
          image: ResizeImage(
            FileImage(File(body.thumbnailLocalPath!)),
            width: width.toInt(),
            height: height.toInt(),
          ),
          fit: BoxFit.fill);
    } else if (body.fileStatus == DownloadStatus.SUCCESS) {
      content = Image(
          gaplessPlayback: true,
          image: ResizeImage(
            FileImage(File(body.localPath)),
            width: width.toInt(),
            height: height.toInt(),
          ),
          fit: BoxFit.fill);
    } else {
      ChatClient.getInstance.chatManager.downloadThumbnail(message);
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
