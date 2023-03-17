import 'dart:async';
import 'dart:io';

import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AgoraMessagesView extends StatefulWidget {
  const AgoraMessagesView({
    super.key,
    this.inputBar,
    required this.conversation,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.avatarBuilder,
    this.nicknameBuilder,
    this.titleAvatarBuilder,
    this.moreItems,
    this.messageListViewController,
    this.willSendMessage,
  });

  final Widget? inputBar;
  final ChatConversation conversation;
  final AgoraMessageTapAction? onTap;
  final AgoraMessageLongPressAction? onBubbleLongPress;
  final AgoraMessageTapAction? onBubbleDoubleTap;
  final AgoraWidgetBuilder? avatarBuilder;
  final AgoraWidgetBuilder? nicknameBuilder;
  final List<AgoraBottomSheetItem>? moreItems;
  final AgoraConversationWidgetBuilder? titleAvatarBuilder;
  final AgoraMessageListController? messageListViewController;
  final ChatMessage Function(ChatMessage message)? willSendMessage;

  @override
  State<AgoraMessagesView> createState() => _AgoraMessagesViewState();
}

class _AgoraMessagesViewState extends State<AgoraMessagesView> {
  late final AgoraMessageListController msgListViewController;
  final ImagePicker _picker = ImagePicker();
  final Record _audioRecorder = Record();
  final AudioPlayer _player = AudioPlayer();
  int _recordDuration = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    msgListViewController = widget.messageListViewController ??
        AgoraMessageListController(widget.conversation);
    msgListViewController.markAllMessagesAsRead();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _player.dispose();
    msgListViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: AgoraMessagesList(
            conversation: widget.conversation,
            messageListViewController: msgListViewController,
            avatarBuilder: widget.avatarBuilder,
            nicknameBuilder: widget.nicknameBuilder,
            onTap: (ctx, msg) {
              bool ret = widget.onTap?.call(ctx, msg) ?? false;
              if (!ret) {
                if (msg.body.type == MessageType.VOICE) {
                  _voiceBubblePressed(msg);
                }
              }
              return ret;
            },
            onBubbleDoubleTap: (ctx, msg) {
              bool ret = widget.onBubbleDoubleTap?.call(ctx, msg) ?? false;
              return ret;
            },
            onBubbleLongPress: (ctx, msg) async {
              bool ret = false;
              ret = await widget.onBubbleLongPress?.call(ctx, msg) ?? false;
              if (!ret) {
                ret = await longPressAction.call(msg) ?? false;
              }
              return ret;
            },
          ),
        ),
        widget.inputBar ??
            AgoraMessageInputWidget(
              msgListViewController: msgListViewController,
              recordTouchDown: _startRecord,
              recordTouchUpInside: _stopRecord,
              recordTouchUpOutside: _cancelRecord,
              moreAction: showMoreItems,
              onTextFieldChanged: (text) {},
              onSendBtnTap: (text) {
                var msg = ChatMessage.createTxtSendMessage(
                    targetId: widget.conversation.id, content: text);
                msg.chatType = ChatType.values[widget.conversation.type.index];
                msgListViewController
                    .sendMessage(widget.willSendMessage?.call(msg) ?? msg);
              },
            )
      ],
    );
  }

  Future<bool?> longPressAction(ChatMessage message) async {
    List<AgoraBottomSheetItem> list = [];
    if (message.body.type == MessageType.TXT) {
      list.add(
        AgoraBottomSheetItem(
          "Copy",
          onTap: () {
            ChatTextMessageBody body = message.body as ChatTextMessageBody;
            Clipboard.setData(ClipboardData(text: body.content));
            return Navigator.of(context).pop();
          },
        ),
      );
    }
    list.add(
      AgoraBottomSheetItem(
        "Delete",
        onTap: () {
          msgListViewController.removeMessage(message);
          return Navigator.of(context).pop(true);
        },
      ),
    );
    if (DateTime.now().millisecondsSinceEpoch - message.serverTime <
        180 * 1000) {
      list.add(
        AgoraBottomSheetItem(
          "Recall",
          labelStyle: const TextStyle(
              color: Color.fromRGBO(255, 20, 204, 1),
              fontWeight: FontWeight.w400,
              fontSize: 18),
          onTap: () {
            msgListViewController.recallMessage(context, message);
            return Navigator.of(context).pop(true);
          },
        ),
      );
    }
    return AgoraBottomSheet(
      items: list,
    ).show<bool>(context);
  }

  void showMoreItems() {
    AgoraBottomSheet(
      items: widget.moreItems ??
          [
            AgoraBottomSheetItem("Camera", onTap: () {
              Navigator.of(context).pop();
              _takePhoto();
            }),
            AgoraBottomSheetItem("Album", onTap: () {
              Navigator.of(context).pop();
              _openImagePicker();
            }),
            AgoraBottomSheetItem("Files", onTap: () {
              Navigator.of(context).pop();
              _openFilePicker();
            }),
          ],
    ).show(context);
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile? file = result.files.first;
      ChatMessage fileMsg = ChatMessage.createFileSendMessage(
        targetId: widget.conversation.id,
        filePath: file.path!,
        fileSize: file.size,
        displayName: file.name,
      );
      fileMsg.chatType = ChatType.values[widget.conversation.type.index];
      msgListViewController
          .sendMessage(widget.willSendMessage?.call(fileMsg) ?? fileMsg);
    }
  }

  void _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _sendImage(photo.path);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _openImagePicker() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _sendImage(image.path);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _sendImage(String path) async {
    if (path.isEmpty) {
      return;
    }

    bool hasSize = false;
    File file = File(path);
    Image.file(file)
        .image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, synchronousCall) {
      if (!hasSize) {
        hasSize = true;
        ChatMessage msg = ChatMessage.createImageSendMessage(
          targetId: widget.conversation.id,
          filePath: path,
          width: info.image.width.toDouble(),
          height: info.image.height.toDouble(),
          fileSize: file.sizeInBytes,
        );
        msgListViewController
            .sendMessage(widget.willSendMessage?.call(msg) ?? msg);
      }
    }));
  }

  void _sendVoice(String? path) {
    if (path == null) {
      return;
    }
    if (_recordDuration <= 1) {
      return;
    }

    if (Platform.isIOS) {
      if (path.startsWith("file:///")) {
        path = path.substring(8);
      }
    }
    String displayName = path.split("/").last;

    ChatMessage msg = ChatMessage.createVoiceSendMessage(
      targetId: widget.conversation.id,
      filePath: path,
      duration: _recordDuration,
      displayName: displayName,
    );
    msgListViewController.sendMessage(widget.willSendMessage?.call(msg) ?? msg);
  }

  Future<void> _voiceBubblePressed(ChatMessage message) async {
    await widget.conversation.markMessageAsRead(message.msgId);
    message.hasRead = true;
    if (msgListViewController.playingMessage?.msgId == message.msgId) {
      _stopVoice(message);
    } else {
      _playVoice(message);
    }
  }

  void _playVoice(ChatMessage message) async {
    msgListViewController.play(message);
    msgListViewController.refreshUI();
    ChatVoiceMessageBody body = message.body as ChatVoiceMessageBody;
    await _player.stop();
    _player.play(DeviceFileSource(body.localPath));
    _player.onPlayerComplete.first.whenComplete(() {
      _stopVoice(message);
    });
  }

  void _stopVoice(ChatMessage message) async {
    await _player.stop();
    msgListViewController.stopPlay(message);
    msgListViewController.refreshUI();
  }

  void _startRecord() async {
    debugPrint("开始录制");
    try {
      if (await _audioRecorder.hasPermission()) {
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        debugPrint('${AudioEncoder.aacLc.name} supported: $isSupported');

        await _audioRecorder.start();
        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _stopRecord() async {
    _endTimer();
    final path = await _audioRecorder.stop();
    debugPrint("结束录制 $path");
    _sendVoice(path);
  }

  void _cancelRecord() async {
    _endTimer();
    debugPrint("取消录制");
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _recordDuration++;
    });
  }

  void _endTimer() {
    _timer?.cancel();
  }
}
