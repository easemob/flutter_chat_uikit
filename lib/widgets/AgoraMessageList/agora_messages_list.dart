import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:agora_chat_uikit/controllers/agora_base_controller.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageList/agora_scroll_behavior.dart';

import 'package:flutter/material.dart';

class AgoraMessageListController extends AgoraBaseController {
  AgoraMessageListController(
    this.conversation, {
    super.key,
    this.needReadAck = true,
  }) {
    _addChatManagerListener();
  }

  final bool needReadAck;
  final List<AgoraMessageListItemModel> _oldList = [];
  final List<AgoraMessageListItemModel> _newList = [];
  VoidCallback? dismissInputAction;
  ChatMessage? playingMessage;
  int _latestShowTsTime = -1;
  final ChatConversation conversation;
  bool _hasMore = true;
  bool _loading = false;
  bool hasFirstLoad = false;

// send message
  void sendMessage(ChatMessage message) async {
    int index = -1;
    do {
      index = _newList.indexWhere((element) => message.msgId == element.msgId);
      if (index > -1) {
        _removeListWithIndex(_newList, index);
        break;
      }
      index = _oldList.indexWhere((element) => message.msgId == element.msgId);
      if (index > -1) {
        _removeListWithIndex(_oldList, index);
      }
    } while (false);

    ChatMessage msg =
        await ChatClient.getInstance.chatManager.sendMessage(message);
    _newList.add(_modelCreator(msg));

    await moveToEnd();
  }

  // remove message
  Future<void> removeMessage(ChatMessage message) async {
    int index = -1;
    do {
      index = _newList.indexWhere((element) => message.msgId == element.msgId);
      if (index >= 0) {
        _removeListWithIndex(_newList, index);
        break;
      }
      index = _oldList.indexWhere((element) => message.msgId == element.msgId);
      if (index >= 0) {
        _removeListWithIndex(_oldList, index);
        break;
      }
    } while (false);
    if (index >= 0) {
      await conversation.deleteMessage(message.msgId);
      refreshUI();
    }
  }

  void _removeListWithIndex(List<AgoraMessageListItemModel> list, int index) {
    AgoraMessageListItemModel model = list.removeAt(index);
    if (list.length != index && model.needTime) {
      list[index] = list[index].copyWithNeedTime(true);
    }
  }

  Future<void> recallMessage(BuildContext context, ChatMessage message) async {
    int index = -1;
    do {
      index = _newList.indexWhere((element) => message.msgId == element.msgId);
      if (index >= 0) {
        _removeListWithIndex(_newList, index);
        break;
      }
      index = _oldList.indexWhere((element) => message.msgId == element.msgId);
      if (index >= 0) {
        _removeListWithIndex(_oldList, index);
        break;
      }
    } while (false);
    if (index >= 0) {
      try {
        await ChatClient.getInstance.chatManager.recallMessage(message.msgId);
        refreshUI();
      } on ChatError catch (e) {
        String str = e.description;
        final snackBar = SnackBar(content: Text(str));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  // load message message
  Future<void> loadMoreMessage([int count = 10]) async {
    if (_loading) return;
    _loading = true;
    if (!_hasMore) return;
    List<AgoraMessageListItemModel> tmpList = _oldList + _newList;
    List<ChatMessage> list = await conversation.loadMessages(
      startMsgId: tmpList.isEmpty ? "" : tmpList.first.msgId,
      loadCount: count,
    );
    if (list.length < count) {
      _hasMore = false;
    }

    List<AgoraMessageListItemModel> models = _modelsCreator(list, _hasMore);

    if (!hasFirstLoad) {
      _newList.addAll(models);
      hasFirstLoad = true;
    } else {
      _oldList.insertAll(0, models);
    }
    _loading = false;
    refreshUI();
  }

  // mark all messages as read;
  Future<void> markAllMessagesAsRead() async {
    return conversation.markAllMessagesAsRead();
  }

  // mark a message as read;
  Future<void> markMessageAsRead(ChatMessage message) async {
    if (message.direction == MessageDirection.RECEIVE) {
      await conversation.markMessageAsRead(message.msgId);
    }
  }

  // 发送 read ack
  void sendReadAck(ChatMessage message) async {
    if (needReadAck &&
        !message.hasReadAck &&
        message.direction == MessageDirection.RECEIVE) {
      await ChatClient.getInstance.chatManager.sendMessageReadAck(message);
    }
  }

  void _handleMessage(String msgId, ChatMessage message) {
    int index = -1;
    do {
      index = _newList.indexWhere((element) => msgId == element.msgId);
      if (index > -1) {
        _newList[index] = _newList[index].copyWithMsg(message);
        break;
      }
      index = _oldList.indexWhere((element) => msgId == element.msgId);
      if (index > -1) {
        _oldList[index] = _oldList[index].copyWithMsg(message);
      }
    } while (false);
    if (index > -1) {
      refreshUI();
    }
  }

  void _addChatManagerListener() {
    ChatClient.getInstance.chatManager.addMessageEvent(
        key,
        ChatMessageEvent(
          onProgress: (msgId, progress) {},
          onSuccess: _handleMessage,
          onError: (msgId, msg, error) {
            _handleMessage.call(msgId, msg);
          },
        ));
    ChatClient.getInstance.chatManager.addEventHandler(
        key,
        ChatEventHandler(
          onMessagesRead: _updateMessageItems,
          onMessagesReceived: (messages) {
            List<ChatMessage> tmp = messages
                .where((element) => element.conversationId == conversation.id)
                .toList();

            _newList.addAll(tmp.map((e) => _modelCreator(e)).toList());
            refreshUI();
          },
          onMessagesRecalled: (messages) {
            // TODO: need delete message from ui.
          },
        ));
  }

  void _updateMessageItems(List<ChatMessage> list) {
    bool hasChange = false;

    for (var message in list) {
      int index = -1;
      do {
        index =
            _newList.indexWhere((element) => message.msgId == element.msgId);
        if (index > -1) {
          _newList[index] = AgoraMessageListItemModel(message);
          hasChange = true;
          break;
        }
        index =
            _oldList.indexWhere((element) => message.msgId == element.msgId);
        if (index > -1) {
          _oldList[index] = AgoraMessageListItemModel(message);
        }
        hasChange = true;
      } while (false);
    }
    if (hasChange) {
      refreshUI();
    }
  }

  void _remoteChatManagerListener() {
    ChatClient.getInstance.chatManager.removeEventHandler(key);
    ChatClient.getInstance.chatManager.removeMessageEvent(key);
  }

  List<AgoraMessageListItemModel> _modelsCreator(
      List<ChatMessage> msgs, bool hasMore) {
    List<AgoraMessageListItemModel> list = [];
    for (var i = 0; i < msgs.length; i++) {
      if (i == 0 && !_hasMore) {
        _latestShowTsTime = msgs[i].serverTime;
        list.add(AgoraMessageListItemModel(msgs[i], true));
      } else {
        list.add(_modelCreator(msgs[i]));
      }
    }
    return list;
  }

  AgoraMessageListItemModel _modelCreator(ChatMessage message) {
    bool needShowTs = false;
    if (_latestShowTsTime < 0) {
      needShowTs = true;
    } else if ((message.serverTime - _latestShowTsTime).abs() > 120 * 1000) {
      needShowTs = true;
    }
    if (needShowTs == true) {
      _latestShowTsTime = message.serverTime;
    }
    return AgoraMessageListItemModel(message, needShowTs);
  }

  Future<void> Function([int milliseconds])? _moveToEnd;
  Future<void> Function()? _reloadData;

  void _bindingActions({
    Future<void> Function([int milliseconds])? moveToEnd,
    Future<void> Function()? reloadData,
  }) {
    _moveToEnd = moveToEnd;
    _reloadData = reloadData;
  }

  Future<void>? moveToEnd([int milliseconds = 50]) {
    return _moveToEnd?.call(milliseconds);
  }

  Future<void>? refreshUI() {
    return _reloadData?.call();
  }

  void play(ChatMessage message) {
    playingMessage = message;
  }

  void stopPlay(ChatMessage message) {
    playingMessage = null;
  }

  void dispose() {
    _remoteChatManagerListener();
  }
}

class AgoraMessagesList extends StatefulWidget {
  const AgoraMessagesList({
    super.key,
    required this.conversation,
    this.messageListViewController,
    this.itemBuilder,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.avatarBuilder,
    this.nicknameBuilder,
  });

  final ChatConversation conversation;
  final AgoraMessageListController? messageListViewController;
  final AgoraMessageListItemBuilder? itemBuilder;
  final AgoraMessageTapAction? onTap;
  final AgoraMessageLongPressAction? onBubbleLongPress;
  final AgoraMessageTapAction? onBubbleDoubleTap;
  final AgoraWidgetBuilder? avatarBuilder;
  final AgoraWidgetBuilder? nicknameBuilder;

  @override
  State<AgoraMessagesList> createState() => _AgoraMessagesListState();
}

class _AgoraMessagesListState extends State<AgoraMessagesList>
    with WidgetsBindingObserver {
  late AgoraMessageListController controller;

  final ScrollController _scrollController = ScrollController();
  late final ValueKey _centerKey;
  bool _hasLongPress = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _centerKey = ValueKey(widget.conversation.id);
    _scrollController.addListener(scrollListener);

    controller = widget.messageListViewController ??
        AgoraMessageListController(
          widget.conversation,
        );

    controller._bindingActions(
      moveToEnd: _moveToEnd,
      reloadData: _reloadData,
    );
    controller.loadMoreMessage();
  }

  Future<void> _moveToEnd([int milliseconds = 50]) async {
    setState(() {});
    if (_scrollController.position.extentAfter > 100) {
      _scrollController.jumpTo(100);
    }

    _scrollToEnd(milliseconds);
  }

  Future<void> _reloadData() async {
    setState(() {});
    _scrollToEnd();
  }

  Future<void> _scrollToEnd(
      [int milliseconds = 100, bool force = false]) async {
    if (_scrollController.position.extentAfter <= 30 || force) {
      await Future.delayed(Duration(milliseconds: milliseconds));
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  void didUpdateWidget(covariant AgoraMessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!_hasLongPress) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    if (_scrollController.position.extentBefore == 0) {
      controller.loadMoreMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AgoraMessageListItemModel> oldList = controller._oldList;
    List<AgoraMessageListItemModel> newList = controller._newList;

    return ScrollConfiguration(
      behavior: AgoraScrollBehavior(),
      child: Scrollbar(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          center: _centerKey,
          controller: _scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return messageWidget(oldList[oldList.length - 1 - index]);
                },
                childCount: oldList.length,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.zero,
              key: _centerKey,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return messageWidget(newList[index]);
                },
                childCount: newList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageWidget(AgoraMessageListItemModel model) {
    ChatMessage message = model.message;
    controller.sendReadAck(message);

    Widget content = widget.itemBuilder?.call(context, model.message) ??
        () {
          if (message.body.type == MessageType.TXT) {
            return AgoraMessageListTextItem(
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: _longPressed,
              onResendTap: () => controller.sendMessage(message),
            );
          } else if (message.body.type == MessageType.IMAGE) {
            return AgoraMessageListImageItem(
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: _longPressed,
              onResendTap: () => controller.sendMessage(message),
            );
          } else if (message.body.type == MessageType.FILE) {
            return AgoraMessageListFileItem(
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: _longPressed,
              onResendTap: () => controller.sendMessage(message),
            );
          } else if (message.body.type == MessageType.VOICE) {
            return AgoraMessageListVoiceItem(
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: _longPressed,
              onResendTap: () => controller.sendMessage(message),
              isPlay: controller.playingMessage?.msgId == message.msgId,
            );
          }

          return Container(width: 100, height: 100, color: Colors.red);
        }();

    return content;
  }

  Future<bool> _longPressed(BuildContext ctx, ChatMessage msg) async {
    controller.dismissInputAction?.call();
    _hasLongPress = true;
    bool ret = await widget.onBubbleLongPress?.call(ctx, msg) ?? false;

    Future.delayed(const Duration(seconds: 1))
        .then((value) => _hasLongPress = false);

    return ret;
  }
}
