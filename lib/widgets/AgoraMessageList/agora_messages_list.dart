import 'package:flutter/material.dart';

import '../../agora_chat_uikit.dart';
import '../../controllers/agora_base_controller.dart';
import 'agora_message_sliver.dart';
import 'agora_scroll_behavior.dart';

class AgoraMessageListController extends AgoraBaseController {
  AgoraMessageListController(
    this.conversation, {
    super.key,
    this.needReadAck = true,
  }) {
    _addChatManagerListener();
  }
  Future<void> Function(bool enableAnimation, bool moveToEnd)? _reloadData;
  final bool needReadAck;
  final List<AgoraMessageListItemModel> _msgList = [];

  VoidCallback? dismissInputAction;
  ChatMessage? playingMessage;
  int _latestShowTsTime = -1;
  final ChatConversation conversation;
  bool _hasMore = true;
  bool _loading = false;
  bool hasFirstLoad = false;

// send message
  void sendMessage(ChatMessage message) async {
    _removeMessageFromList(message);
    ChatMessage msg =
        await ChatClient.getInstance.chatManager.sendMessage(message);
    _msgList.insert(0, _modelCreator(msg));
    await refreshUI(moveToEnd: true);
  }

  // remove message
  Future<void> removeMessage(ChatMessage message) async {
    try {
      await conversation.deleteMessage(message.msgId);
      if (_removeMessageFromList(message)) {
        refreshUI();
      }
    } on ChatError catch (e) {
      debugPrint(e.toString());
    }
  }

  bool _removeMessageFromList(ChatMessage message) {
    int index = -1;
    do {
      index = _msgList.indexWhere((element) => message.msgId == element.msgId);
      if (index >= 0) {
        _removeListWithIndex(_msgList, index);
        break;
      }
    } while (false);
    return index >= 0;
  }

  void _removeListWithIndex(List<AgoraMessageListItemModel> list, int index) {
    AgoraMessageListItemModel model = list.removeAt(index);
    if (index == 0) {
      if (list.isNotEmpty) {
        _latestShowTsTime = list.first.message.serverTime;
      } else {
        _latestShowTsTime = -1;
      }
    } else {
      if (model.needTime && list.isNotEmpty) {
        list[index - 1] = list[index - 1].copyWithNeedTime(true);
      }
    }
  }

  Future<void> recallMessage(BuildContext context, ChatMessage message) async {
    try {
      await ChatClient.getInstance.chatManager.recallMessage(message.msgId);
      if (_removeMessageFromList(message)) {
        refreshUI();
      }
    } on ChatError catch (e) {
      // TODO: callback error?
      String str = e.description;
      final snackBar = SnackBar(content: Text(str));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // load message message
  Future<void> loadMoreMessage([int count = 10]) async {
    if (_loading) return;
    _loading = true;
    if (!_hasMore) {
      _loading = false;
      return;
    }

    List<ChatMessage> list = await conversation.loadMessages(
      startMsgId: _msgList.isEmpty ? "" : _msgList.last.msgId,
      loadCount: count,
    );
    if (list.length < count) {
      _hasMore = false;
    }

    List<AgoraMessageListItemModel> models = _modelsCreator(list, _hasMore);

    _msgList.addAll(models);
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
  Future<void> sendReadAck(ChatMessage message) async {
    if (needReadAck &&
        !message.hasReadAck &&
        message.direction == MessageDirection.RECEIVE) {
      await ChatClient.getInstance.chatManager.sendMessageReadAck(message);
    }
  }

  Future<void> deleteAllMessages() async {
    await ChatClient.getInstance.chatManager
        .deleteConversation(conversation.id);
    _latestShowTsTime = -1;
    _msgList.clear();
    refreshUI();
  }

  void _handleMessage(String msgId, ChatMessage message) {
    int index = -1;
    do {
      index = _msgList.indexWhere((element) => msgId == element.msgId);
      if (index > -1) {
        AgoraMessageListItemModel model = _msgList[index].copyWithMsg(message);
        _msgList[index] = model;
        break;
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

            _msgList.insertAll(0, tmp.map((e) => _modelCreator(e)).toList());
            refreshUI();
          },
          onMessagesRecalled: (messages) {
            bool needRefresh = false;
            for (var msg in messages) {
              if (msg.conversationId == conversation.id) {
                bool tmp = _removeMessageFromList(msg);
                if (tmp && !needRefresh) {
                  needRefresh = true;
                }
              }
            }
            if (needRefresh) refreshUI();
          },
        ));
  }

  void _updateMessageItems(List<ChatMessage> list) {
    bool hasChange = false;

    for (var message in list) {
      int index = -1;
      do {
        index =
            _msgList.indexWhere((element) => message.msgId == element.msgId);
        if (index > -1) {
          _msgList[index] = _msgList[index].copyWithMsg(message);
          hasChange = true;
          break;
        }

        hasChange = true;
      } while (false);
    }
    if (hasChange) {
      refreshUI();
    }
  }

  void _removeChatManagerListener() {
    ChatClient.getInstance.chatManager.removeEventHandler(key);
    ChatClient.getInstance.chatManager.removeMessageEvent(key);
  }

  List<AgoraMessageListItemModel> _modelsCreator(
      List<ChatMessage> msgs, bool hasMore) {
    List<AgoraMessageListItemModel> list = [];
    for (var i = 0; i < msgs.length; i++) {
      if (!_hasMore && i == 0) {
        _latestShowTsTime = msgs[i].serverTime;
        list.add(AgoraMessageListItemModel(msgs[i], true));
      } else {
        list.add(_modelCreator(msgs[i]));
      }
    }
    return list.reversed.toList();
  }

  AgoraMessageListItemModel _modelCreator(ChatMessage message) {
    bool needShowTs = false;
    if (_latestShowTsTime < 0) {
      needShowTs = true;
    } else if ((message.serverTime - _latestShowTsTime).abs() > 60 * 1000) {
      needShowTs = true;
    }
    if (needShowTs == true && message.serverTime > _latestShowTsTime) {
      _latestShowTsTime = message.serverTime;
    }
    return AgoraMessageListItemModel(message, needShowTs);
  }

  void _bindingActions({
    Future<void> Function(bool enableAnimation, bool moveToEnd)? reloadData,
  }) {
    _reloadData = reloadData;
  }

  Future<void>? refreshUI({
    bool enableAnimation = false,
    bool moveToEnd = false,
  }) {
    return _reloadData?.call(enableAnimation, moveToEnd);
  }

  void play(ChatMessage message) {
    playingMessage = message;
  }

  void stopPlay(ChatMessage message) {
    playingMessage = null;
  }

  void dispose() {
    _removeChatManagerListener();
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
  final AgoraMessageTapAction? onBubbleLongPress;
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

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(scrollListener);

    controller = widget.messageListViewController ??
        AgoraMessageListController(
          widget.conversation,
        );

    controller._bindingActions(reloadData: _reloadData);
    controller.loadMoreMessage();
  }

  Future<void> _reloadData(bool enableAnimation, bool moveToEnd) async {
    setState(() {});
    if (moveToEnd) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      controller.loadMoreMessage();
    }
    controller.dismissInputAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    List<AgoraMessageListItemModel> list = controller._msgList;

    Widget content = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      cacheExtent: 1500,
      reverse: true,
      slivers: [
        AgoraMessageSliver(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return messageWidget(list[index]);
            },
            childCount: list.length,
          ),
        )
      ],
    );

    return ScrollConfiguration(
      behavior: AgoraScrollBehavior(),
      child: Scrollbar(child: content),
    );
  }

  Widget messageWidget(AgoraMessageListItemModel model) {
    ChatMessage message = model.message;
    controller.sendReadAck(message);

    ValueKey<String>? valueKey; //ValueKey(message.msgId);

    Widget content = widget.itemBuilder?.call(context, model.message) ??
        () {
          if (message.body.type == MessageType.TXT) {
            return AgoraMessageListTextItem(
              key: valueKey,
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: widget.onBubbleLongPress,
              onResendTap: () => controller.sendMessage(message),
            );
          } else if (message.body.type == MessageType.IMAGE) {
            return AgoraMessageListImageItem(
              key: valueKey,
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: widget.onBubbleLongPress,
              onResendTap: () => controller.sendMessage(message),
            );
          } else if (message.body.type == MessageType.FILE) {
            return AgoraMessageListFileItem(
              key: valueKey,
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: widget.onBubbleLongPress,
              onResendTap: () => controller.sendMessage(message),
            );
          } else if (message.body.type == MessageType.VOICE) {
            return AgoraMessageListVoiceItem(
              key: valueKey,
              model: model,
              onTap: widget.onTap,
              avatarBuilder: widget.avatarBuilder,
              nicknameBuilder: widget.nicknameBuilder,
              onBubbleDoubleTap: widget.onBubbleDoubleTap,
              onBubbleLongPress: widget.onBubbleLongPress,
              onResendTap: () => controller.sendMessage(message),
              isPlay: controller.playingMessage?.msgId == message.msgId,
            );
          }

          return Container(width: 100, height: 100, color: Colors.red);
        }();

    return content;
  }
}
