import 'dart:async';
import 'dart:io';

import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../agora_chat_uikit_error.dart';

/// Message details page
class AgoraMessagesView extends StatefulWidget {
  /// Message details page.
  ///
  /// [inputBarTextEditingController] Text input widget text editing controller.
  ///
  /// [background] Background widget.
  ///
  /// [inputBar] Text input component, if not passed by default will use [AgoraMessageInputWidget].
  ///
  /// [conversation] The conversation corresponding to the message details.
  ///
  /// [onTap] Message Bubble click event callback.
  ///
  /// [onBubbleLongPress] Message bubbles long press the event callback.
  ///
  /// [onBubbleDoubleTap] Message Bubble Double-click the event callback.
  ///
  /// [avatarBuilder] Avatar component builder.
  ///
  /// [nicknameBuilder] Nickname component builder.
  ///
  /// [itemBuilder] Message bubble, if not set, will take the default bubble.
  ///
  /// [moreItems] The more the input component clicks on the list displayed, the default items will be used if not passed in, including copy, delete, and recall.
  ///
  /// [messageListViewController] Message list controller: You are advised not to pass messages. Use the default value. For details, see [AgoraMessageListController].
  ///
  /// [willSendMessage] A pre-text message event that needs to return a ChatMessage object. that can be used for pre-text message processing.
  ///
  /// [onError] Error callbacks, such as no current permissions, etc.
  ///
  /// [enableScrollBar] Enable scroll bar. default is true.
  ///
  /// [needDismissInputWidget] Dismiss the input widget callback. If you use a customized inputBar,
  /// dismiss the inputBar when you receive the callback,
  /// for example, by calling [FocusNode.unfocus], see [AgoraMessageInputWidget].
  ///
  /// [inputBarMoreActionsOnTap] More button click after callback, need to return to the AgoraBottomSheetItems list.
  ///
  const AgoraMessagesView({
    required this.conversation,
    this.inputBarTextEditingController,
    this.background,
    this.inputBar,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.avatarBuilder,
    this.nicknameBuilder,
    this.itemBuilder,
    this.moreItems,
    this.messageListViewController,
    this.willSendMessage,
    this.onError,
    this.enableScrollBar = true,
    this.needDismissInputWidget,
    this.inputBarMoreActionsOnTap,
    super.key,
  });

  final Widget? background;

  /// Text input widget text editing controller.
  final TextEditingController? inputBarTextEditingController;

  /// Text input widget, if not passed by default will use [AgoraMessageInputWidget].
  final Widget? inputBar;

  /// The session corresponding to the message details.
  final ChatConversation conversation;

  /// Message Bubble click event callback.
  final AgoraMessageTapAction? onTap;

  /// Message bubbles long press the event callback.
  final AgoraMessageTapAction? onBubbleLongPress;

  /// Message Bubble Double-click the event callback.
  final AgoraMessageTapAction? onBubbleDoubleTap;

  /// Avatar component builder
  final AgoraWidgetBuilder? avatarBuilder;

  /// Nickname component builder
  final AgoraWidgetBuilder? nicknameBuilder;

  /// The more the input component clicks on the list displayed,
  /// the default items will be used if not passed in, including copy, delete, and recall.
  final List<AgoraBottomSheetItem>? moreItems;

  /// Message bubble, if not set, will take the default bubble.
  final AgoraMessageListItemBuilder? itemBuilder;

  /// Message list controller: You are advised not to pass messages. Use the default value.
  /// For details, see [AgoraMessageListController].
  final AgoraMessageListController? messageListViewController;

  /// A pre-text message event that needs to return a ChatMessage object.
  /// that can be used for pre-text message processing.
  final AgoraReplaceMessage? willSendMessage;

  /// Error callbacks, such as no current permissions, etc.
  final void Function(ChatError error)? onError;

  /// Enable scroll bar.
  final bool enableScrollBar;

  /// Dismiss the input widget callback. If you use a customized inputBar,
  /// dismiss the inputBar when you receive the callback,
  /// for example, by calling [FocusNode.unfocus], see [AgoraMessageInputWidget].
  final VoidCallback? needDismissInputWidget;

  /// More button click after callback, need to return to the AgoraBottomSheetItems list.
  final AgoraReplaceMoreActions? inputBarMoreActionsOnTap;

  @override
  State<AgoraMessagesView> createState() => _AgoraMessagesViewState();
}

class _AgoraMessagesViewState extends State<AgoraMessagesView> {
  late final AgoraMessageListController msgListViewController;
  final ImagePicker _picker = ImagePicker();
  final Record _audioRecorder = Record();
  final AudioPlayer _player = AudioPlayer();
  final FocusNode _focusNode = FocusNode();
  int _recordDuration = 0;
  bool _recordBtnTouchDown = false;
  bool _dragOutside = false;
  Timer? _timer;
  late TextEditingController _textController;
  ChatMessage? _playingMessage;
  @override
  void initState() {
    super.initState();
    _textController =
        widget.inputBarTextEditingController ?? TextEditingController();
    msgListViewController = widget.messageListViewController ??
        AgoraMessageListController(widget.conversation);
    msgListViewController.markAllMessagesAsRead();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    if (widget.inputBarTextEditingController == null) {
      _textController.dispose();
    }

    _player.dispose();
    _focusNode.dispose();
    msgListViewController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AgoraMessagesView oldWidget) {
    _stopRecord(false);
    _stopVoice();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: AgoraMessagesList(
            background: widget.background,
            needDismissInputWidgetAction: widget.needDismissInputWidget ??
                () {
                  _focusNode.unfocus();
                },
            enableScrollBar: widget.enableScrollBar,
            onError: widget.onError,
            conversation: widget.conversation,
            messageListViewController: msgListViewController,
            avatarBuilder: widget.avatarBuilder,
            nicknameBuilder: widget.nicknameBuilder,
            itemBuilder: widget.itemBuilder,
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
              _focusNode.unfocus();
              bool ret = widget.onBubbleDoubleTap?.call(ctx, msg) ?? false;
              return ret;
            },
            onBubbleLongPress: (ctx, msg) {
              _focusNode.unfocus();
              bool ret = widget.onBubbleLongPress?.call(ctx, msg) ?? false;
              if (!ret) {
                longPressAction(msg);
              }
              return ret;
            },
          ),
        ),
        widget.inputBar ??
            AgoraMessageInputWidget(
              textEditingController: _textController,
              focusNode: _focusNode,
              inputWidgetOnTap: () {
                if (!_focusNode.hasFocus) {
                  _focusNode.requestFocus();
                }
                msgListViewController.refreshUI(moveToEnd: true);
              },
              emojiWidgetOnTap: () {
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                }
                msgListViewController.refreshUI(moveToEnd: true);
              },
              recordTouchDown: _startRecord,
              recordTouchUpInside: _stopRecord,
              recordTouchUpOutside: _cancelRecord,
              recordDragInside: _recordDragInside,
              recordDragOutside: _recordDragOutside,
              moreAction: showMoreItems,
              onTextFieldChanged: (text) {},
              onSendBtnTap: (text) {
                var msg = ChatMessage.createTxtSendMessage(
                    targetId: widget.conversation.id, content: text);
                msg.chatType = ChatType.values[widget.conversation.type.index];
                ChatMessage? willSend;
                if (widget.willSendMessage != null) {
                  willSend = widget.willSendMessage!.call(msg);
                  if (willSend == null) {
                    return;
                  }
                } else {
                  willSend = msg;
                }

                msgListViewController.sendMessage(willSend);
              },
            )
      ],
    );

    content = Stack(
      children: [
        Positioned.fill(child: content),
        Positioned.fill(
          child: Center(child: _maskWidget()),
        )
      ],
    );

    return content;
  }

  void longPressAction(ChatMessage message) async {
    List<AgoraBottomSheetItem> list = [];
    if (message.body.type == MessageType.TXT) {
      list.add(
        AgoraBottomSheetItem.normal(
          'Copy',
          onTap: () async {
            ChatTextMessageBody body = message.body as ChatTextMessageBody;
            Clipboard.setData(ClipboardData(text: body.content));
            return Navigator.of(context).pop();
          },
        ),
      );
    }
    list.add(
      AgoraBottomSheetItem.normal(
        'Delete',
        onTap: () async {
          msgListViewController.removeMessage(message);
          return Navigator.of(context).pop();
        },
      ),
    );

    var time = DateTime.now().millisecondsSinceEpoch - message.serverTime;

    if (time < 120 * 1000 && message.direction != MessageDirection.RECEIVE) {
      list.add(
        AgoraBottomSheetItem.destructive(
          'Recall',
          onTap: () async {
            msgListViewController.recallMessage(message);
            Navigator.of(context).pop();
          },
        ),
      );
    }

    showAgoraBottomSheet(context: context, items: list);
  }

  void showMoreItems() {
    List<AgoraBottomSheetItem> currentList = widget.moreItems ?? _moreItems();
    if (widget.inputBarMoreActionsOnTap != null) {
      final list = widget.inputBarMoreActionsOnTap!.call(currentList);
      if (list.isNotEmpty) {
        showAgoraBottomSheet(context: context, items: list);
      }
    } else {
      showAgoraBottomSheet(
          context: context, items: widget.moreItems ?? _moreItems());
    }
  }

  List<AgoraBottomSheetItem> _moreItems() {
    return [
      AgoraBottomSheetItem.normal(
          AppLocalizations.of(context)?.agoraCamera ?? 'Camera',
          onTap: () async {
        Navigator.of(context).pop();
        _takePhoto();
      }),
      AgoraBottomSheetItem.normal(
          AppLocalizations.of(context)?.agoraAlbum ?? 'Album', onTap: () async {
        Navigator.of(context).pop();
        _openImagePicker();
      }),
      AgoraBottomSheetItem.normal(
          AppLocalizations.of(context)?.agoraFiles ?? 'Files', onTap: () async {
        Navigator.of(context).pop();
        _openFilePicker();
      }),
    ];
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile? file = result.files.first;
      _sendFile(file);
    }
  }

  void _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _sendImage(photo.path);
      }
    } catch (e) {
      widget.onError?.call(
        AgoraChatUIKitError.toChatError(
            AgoraChatUIKitError.noPermission, "no take photo permission"),
      );
    }
  }

  void _openImagePicker() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _sendImage(image.path);
      }
    } catch (e) {
      widget.onError?.call(
        AgoraChatUIKitError.toChatError(
            AgoraChatUIKitError.noPermission, "no image library permission"),
      );
    }
  }

  void _sendFile(PlatformFile? file) async {
    if (file != null) {
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

  void _sendVoice(String path) async {
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
    if (_playingMessage?.msgId == message.msgId) {
      _stopVoice();
    } else {
      _playVoice(message);
    }
  }

  void _playVoice(ChatMessage message) async {
    _playingMessage = message;
    msgListViewController.play(message);
    msgListViewController.refreshUI();
    ChatVoiceMessageBody body = message.body as ChatVoiceMessageBody;
    await _player.stop();
    _player.play(DeviceFileSource(body.localPath));
    _player.onPlayerComplete.first.whenComplete(() {
      _stopVoice();
    });
  }

  void _stopVoice() async {
    _playingMessage = null;
    await _player.stop();
    msgListViewController.stopPlay();
    msgListViewController.refreshUI();
  }

  void _startRecord() async {
    bool isRequest = false;
    Future(() async {
      return await _audioRecorder.hasPermission();
    }).timeout(const Duration(milliseconds: 500), onTimeout: () {
      isRequest = true;
      return false;
    }).then((value) async {
      if (value == true) {
        _startTimer();
        await _audioRecorder.start();
      } else {
        if (!isRequest) {
          widget.onError?.call(
            AgoraChatUIKitError.toChatError(
                AgoraChatUIKitError.noPermission, 'no record permission'),
          );
        } else {}
      }
    });
  }

  void _stopRecord([bool send = true]) async {
    if (send == false) {
      _cancelRecord();
      return;
    }
    if (!await _audioRecorder.isRecording()) {
      return;
    }
    _endTimer();
    setState(() {
      _recordBtnTouchDown = false;
    });
    String? path = await _audioRecorder.stop();

    bool isExists = false;
    if (path != null) {
      if (Platform.isIOS) {
        if (path.startsWith("file:///")) {
          path = path.substring(8);
        }
      }
      final file = File(path);
      isExists = file.existsSync();
      if (isExists) {
        if (_recordDuration < 1) {
          widget.onError?.call(
            AgoraChatUIKitError.toChatError(
                AgoraChatUIKitError.recordTimeTooShort,
                "record time too short"),
          );
          await file.delete();
          return;
        }
        _sendVoice(path);
        return;
      }
    }
    bool permission = await _audioRecorder.hasPermission();
    if (permission) {
      widget.onError?.call(
        AgoraChatUIKitError.toChatError(
            AgoraChatUIKitError.recordError, 'record error'),
      );
    } else {
      widget.onError?.call(
        AgoraChatUIKitError.toChatError(
            AgoraChatUIKitError.noPermission, 'no record permission'),
      );
    }
  }

  void _cancelRecord() async {
    String? path = await _audioRecorder.stop();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    setState(() {
      _recordBtnTouchDown = false;
    });

    _endTimer();
  }

  void _recordDragInside() {
    setState(() {
      _dragOutside = false;
    });
  }

  void _recordDragOutside() {
    setState(() {
      _dragOutside = true;
    });
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _recordDuration++;
      debugPrint("timer: $_recordDuration");
    });
  }

  void _endTimer() {
    _timer?.cancel();
  }

  Widget? _maskWidget() {
    // if (_recordBtnTouchDown) {
    //   return Container(
    //     width: 300,
    //     height: 300,
    //     color: _dragOutside ? Colors.red : Colors.blue,
    //   );
    // } else {
    //   return null;
    // }
    return null;
  }
}
