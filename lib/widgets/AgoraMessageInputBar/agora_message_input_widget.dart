import 'package:flutter/material.dart';

import '../../agora_chat_uikit.dart';
import 'agora_emoji_widget.dart';

class AgoraMessageInputWidget extends StatefulWidget {
  const AgoraMessageInputWidget({
    super.key,
    this.inputTextStr,
    this.recordTouchDown,
    this.recordTouchUpInside,
    this.recordTouchUpOutside,
    this.recordDragInside,
    this.recordDragOutside,
    this.moreAction,
    this.enableEmoji = true,
    this.enableVoice = true,
    this.enableMore = true,
    this.hiddenStr = "Aa",
    this.onTextFieldChanged,
    this.onSendBtnTap,
    this.onTextFieldFocus,
    required this.msgListViewController,
  });
  final String? inputTextStr;
  final VoidCallback? recordTouchDown;
  final VoidCallback? recordTouchUpInside;
  final VoidCallback? recordTouchUpOutside;
  final VoidCallback? recordDragInside;
  final VoidCallback? recordDragOutside;
  final VoidCallback? moreAction;
  final void Function(String text)? onSendBtnTap;
  final void Function(String text)? onTextFieldChanged;
  final VoidCallback? onTextFieldFocus;
  final bool enableEmoji;
  final bool enableVoice;
  final bool enableMore;
  final String hiddenStr;
  final AgoraMessageListController msgListViewController;
  @override
  State<AgoraMessageInputWidget> createState() =>
      _AgoraMessageInputWidgetState();
}

class _AgoraMessageInputWidgetState extends State<AgoraMessageInputWidget> {
  late TextEditingController textEditingController;
  _AgoraInputType _currentInputType = _AgoraInputType.dismiss;
  _AgoraInputType? _lastInputType;

  final FocusNode _inputFocusNode = FocusNode();
  final GlobalKey _gestureKey = GlobalKey();
  bool _showSendBtn = false;
  _AgoraVoiceOffsetType _voiceTouchType = _AgoraVoiceOffsetType.noTouch;
  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController(
      text: widget.inputTextStr,
    )..addListener(() {
        _adjustSendBtn();
      });

    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        _updateCurrentInputType(_AgoraInputType.text);
      }
    });

    widget.msgListViewController.dismissInputAction = () {
      if (_inputFocusNode.hasFocus) {
        _inputFocusNode.unfocus();
      }
      if (_currentInputType != _AgoraInputType.dismiss) {
        _updateCurrentInputType(_AgoraInputType.dismiss);
      }
    };
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _adjustSendBtn() {
    if (textEditingController.text.isEmpty) {
      if (_showSendBtn) {
        setState(() => _showSendBtn = false);
      }
    } else {
      if (!_showSendBtn) {
        setState(() => _showSendBtn = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(3, 3, 6, 4),
                child: Offstage(
                  offstage: !widget.enableVoice,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          child: _currentInputType == _AgoraInputType.voice
                              ? AgoraImageLoader.loadImage(
                                  "input_bar_btn_selected.png",
                                  width: 36,
                                  height: 36)
                              : AgoraImageLoader.loadImage(
                                  "input_bar_speaker.png",
                                  width: 36,
                                  height: 36),
                          onTap: () {
                            _updateCurrentInputType(_AgoraInputType.voice);
                          }),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: _currentInputType != _AgoraInputType.voice
                      ? _inputWidget()
                      : _voiceWidget()),
              () {
                return _currentInputType != _AgoraInputType.voice
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10, 3, 4, 2.5),
                        child: Offstage(
                          offstage: !widget.enableMore,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _showSendBtn
                                  ? InkWell(
                                      key: const ValueKey("1"),
                                      onTap: () {
                                        widget.onSendBtnTap?.call(
                                            textEditingController.text.trim());
                                        textEditingController.text = "";
                                      },
                                      child: Container(
                                        width: 55,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color.fromRGBO(
                                              17, 78, 255, 1),
                                        ),
                                        child: const Center(
                                            child: Text(
                                          "Send",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        _inputFocusNode.unfocus();
                                        widget.moreAction?.call();
                                        _updateCurrentInputType(
                                            _AgoraInputType.dismiss);
                                      },
                                      child: _currentInputType !=
                                              _AgoraInputType.more
                                          ? AgoraImageLoader.loadImage(
                                              "input_bar_more.png",
                                              width: 36,
                                              height: 36,
                                            )
                                          : AgoraImageLoader.loadImage(
                                              "input_bar_btn_selected.png",
                                              width: 35,
                                              height: 35,
                                            ),
                                    ),
                            ],
                          ),
                        ),
                      )
                    : Container();
              }(),
            ],
          ),
        ),
        _faceWidget(),
      ],
    );
  }

  void _updateCurrentInputType(_AgoraInputType type) {
    if (type == _currentInputType && _lastInputType != null) {
      if (_currentInputType == _lastInputType!) {
        _currentInputType = _AgoraInputType.text;
      } else {
        _currentInputType = _AgoraInputType.text;
      }
      _lastInputType = null;
    } else {
      _lastInputType = _currentInputType;
      _currentInputType = type;
    }
    setState(() {});
  }

  Widget _inputWidget() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150, minHeight: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                widget.onTextFieldChanged?.call(value);
              },
              onTap: () {
                widget.msgListViewController.refreshUI(moveToEnd: true);
                widget.onTextFieldFocus?.call();
              },
              focusNode: _inputFocusNode,
              controller: textEditingController,
              maxLines: null,
              decoration: InputDecoration(
                prefixText: " ",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                isCollapsed: true,
                labelStyle: const TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontWeight: FontWeight.w400),
                hintText: widget.hiddenStr,
                hintStyle: const TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(191, 191, 191, 1),
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(3, 3, 4, 4),
            child: Offstage(
              offstage: !widget.enableEmoji,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      _inputFocusNode.unfocus();
                      widget.msgListViewController.refreshUI(moveToEnd: true);
                      _updateCurrentInputType(_AgoraInputType.emoji);
                    },
                    child: _currentInputType == _AgoraInputType.emoji
                        ? AgoraImageLoader.loadImage(
                            "input_bar_btn_selected.png",
                            width: 34,
                            height: 34,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(2),
                            child: AgoraImageLoader.loadImage(
                              "input_bar_emoji.png",
                              width: 29,
                              height: 29,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voiceWidget() {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 230, 230, 230)),
        height: 42,
        key: _gestureKey,
        child: Center(
          child: Text(
            () {
              switch (_voiceTouchType) {
                case _AgoraVoiceOffsetType.noTouch:
                  return "Hold to Talk";
                case _AgoraVoiceOffsetType.dragInside:
                  return "Release to send";
                case _AgoraVoiceOffsetType.dragOutside:
                  return "Release to cancel";
              }
            }(),
            style: const TextStyle(
                color: Color.fromRGBO(165, 167, 166, 1),
                fontWeight: FontWeight.w400,
                fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _faceWidget() {
    return AnimatedContainer(
      onEnd: () {
        widget.onTextFieldFocus?.call();
      },
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 250),
      height: _currentInputType == _AgoraInputType.emoji ? 200 : 0,
      child: Stack(
        children: [
          Positioned(
            child: AgoraEmojiWidget(
              emojiClicked: (emoji) {
                TextEditingValue value = textEditingController.value;
                int current = value.selection.baseOffset;
                if (current < 0) current = 0;
                String text = value.text;
                text = text.substring(0, current) +
                    emoji +
                    text.substring(current);
                textEditingController.value = value.copyWith(
                  text: text,
                  selection: TextSelection.fromPosition(
                    TextPosition(
                      affinity: TextAffinity.downstream,
                      offset: current + 2,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: InkWell(
              onTap: () {
                TextEditingValue value = textEditingController.value;
                int current = value.selection.baseOffset;
                String mStr = "";
                int offset = 0;
                do {
                  if (current == 0) {
                    return;
                  }
                  if (current == 1) {
                    mStr = value.text.substring(1);
                    break;
                  }

                  if (current >= 2) {
                    String subText = value.text.substring(current - 2, current);
                    if (AgoraEmojiData.emojiList.contains(subText)) {
                      mStr = value.text.substring(0, current - 2) +
                          value.text.substring(current);
                      offset = current - 2;
                      break;
                    } else {
                      mStr = value.text.substring(0, current - 1) +
                          value.text.substring(current);
                      offset = current - 1;
                      break;
                    }
                  }
                } while (false);
                textEditingController.value = value.copyWith(
                  text: mStr,
                  selection: TextSelection.fromPosition(
                    TextPosition(
                      affinity: TextAffinity.downstream,
                      offset: offset,
                    ),
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(17, 78, 255, 1),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  weight: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onPointerDown(PointerDownEvent event) {
    setState(() => _voiceTouchType = _AgoraVoiceOffsetType.dragInside);
    widget.recordTouchDown?.call();
  }

  _onPointerMove(PointerMoveEvent event) {
    RenderBox renderBox =
        _gestureKey.currentContext?.findRenderObject() as RenderBox;
    Offset offset = event.localPosition;
    bool outside = false;
    if (offset.dx < 0 || offset.dy < 0) {
      outside = true;
    } else if (renderBox.size.width - offset.dx < 0 ||
        renderBox.size.height - offset.dy < 0) {
      outside = true;
    }
    _AgoraVoiceOffsetType type = _AgoraVoiceOffsetType.noTouch;
    if (!outside) {
      type = _AgoraVoiceOffsetType.dragInside;
      widget.recordDragInside?.call();
    } else {
      type = _AgoraVoiceOffsetType.dragOutside;
      widget.recordDragOutside?.call();
    }
    if (_voiceTouchType != type) {
      setState(() => _voiceTouchType = type);
    }
  }

  _onPointerUp(PointerUpEvent event) {
    RenderBox renderBox =
        _gestureKey.currentContext?.findRenderObject() as RenderBox;
    Offset offset = event.localPosition;
    bool outside = false;
    if (offset.dx < 0 || offset.dy < 0) {
      outside = true;
    } else if (renderBox.size.width - offset.dx < 0 ||
        renderBox.size.height - offset.dy < 0) {
      outside = true;
    }

    setState(() => _voiceTouchType = _AgoraVoiceOffsetType.noTouch);

    if (!outside) {
      widget.recordTouchUpInside?.call();
    } else {
      widget.recordTouchUpOutside?.call();
    }
  }
}

enum _AgoraInputType { dismiss, text, voice, emoji, more }

enum _AgoraVoiceOffsetType { noTouch, dragInside, dragOutside }
