import 'package:flutter/material.dart';

import '../../agora_chat_uikit.dart';
import 'agora_emoji_widget.dart';

/// The widget of the message input bar.
class AgoraMessageInputWidget extends StatefulWidget {
  const AgoraMessageInputWidget({
    super.key,
    required this.textEditingController,
    required this.focusNode,
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
    this.inputWidgetOnTap,
    this.emojiWidgetOnTap,
  });

  final VoidCallback? inputWidgetOnTap;
  final VoidCallback? emojiWidgetOnTap;
  final VoidCallback? recordTouchDown;
  final VoidCallback? recordTouchUpInside;
  final VoidCallback? recordTouchUpOutside;
  final VoidCallback? recordDragInside;
  final VoidCallback? recordDragOutside;
  final VoidCallback? moreAction;
  final void Function(String text)? onSendBtnTap;
  final void Function(String text)? onTextFieldChanged;

  final bool enableEmoji;
  final bool enableVoice;
  final bool enableMore;
  final String hiddenStr;
  final TextEditingController textEditingController;

  final FocusNode focusNode;
  @override
  State<AgoraMessageInputWidget> createState() =>
      _AgoraMessageInputWidgetState();
}

class _AgoraMessageInputWidgetState extends State<AgoraMessageInputWidget> {
  _AgoraInputType _currentInputType = _AgoraInputType.dismiss;
  _AgoraInputType? _lastInputType;

  final GlobalKey _gestureKey = GlobalKey();
  bool _showSendBtn = false;
  _AgoraVoiceOffsetType _voiceTouchType = _AgoraVoiceOffsetType.noTouch;
  @override
  void initState() {
    super.initState();

    widget.textEditingController.addListener(_adjustSendBtn);

    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        _updateCurrentInputType(_AgoraInputType.text);
      } else {
        if (_currentInputType == _AgoraInputType.text) {
          _updateCurrentInputType(_AgoraInputType.dismiss);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _adjustSendBtn() {
    if (widget.textEditingController.text.isEmpty) {
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
                    : _voiceWidget(),
              ),
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
                                        widget.onSendBtnTap?.call(widget
                                            .textEditingController.text
                                            .trim());
                                        widget.textEditingController.text = "";
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 10, 8, 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: AgoraChatUIKit.of(context)
                                              .agoraTheme
                                              .inputWidgetSendBtnColor,
                                        ),
                                        child: Center(
                                            child: Text(
                                          "Send",
                                          style: AgoraChatUIKit.of(context)
                                              .agoraTheme
                                              .inputWidgetSendBtnStyle,
                                        )),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        widget.focusNode.unfocus();
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
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                widget.onTextFieldChanged?.call(value);
              },
              onTap: () {
                widget.inputWidgetOnTap?.call();
              },
              focusNode: widget.focusNode,
              controller: widget.textEditingController,
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
                    onTap: () {
                      widget.emojiWidgetOnTap?.call();
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
      onEnd: () {},
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 250),
      height: _currentInputType == _AgoraInputType.emoji ? 200 : 0,
      child: Stack(
        children: [
          Positioned(
            child: AgoraEmojiWidget(
              emojiClicked: (emoji) {
                TextEditingValue value = widget.textEditingController.value;
                int current = value.selection.baseOffset;
                if (current < 0) current = 0;
                String text = value.text;
                text = text.substring(0, current) +
                    emoji +
                    text.substring(current);
                widget.textEditingController.value = value.copyWith(
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
                TextEditingValue value = widget.textEditingController.value;
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
                widget.textEditingController.value = value.copyWith(
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
