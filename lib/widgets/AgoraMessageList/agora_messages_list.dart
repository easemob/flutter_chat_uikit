import 'package:flutter/material.dart';

import '../../agora_chat_uikit.dart';
import '../../controllers/agora_base_controller.dart';
import 'agora_message_sliver.dart';
import 'agora_scroll_behavior.dart';

class AgoraMessageListController extends AgoraBaseController {
  AgoraMessageListController(
    this.conversation, {
    this.enableReadAck = true,
    this.didRecallMessage,
    super.key,
  }) {
    _addChatManagerListener();
  }

  /// The message recall callback, executed when the message is recalled,
  /// You can return a message that the sdk inserts into the local database.
  final ChatMessage? Function(ChatMessage recalledMessage)? didRecallMessage;

  /// Enable the read receipt. The read receipt supports only single-chat messages.
  /// After text messages are displayed, the system automatically sends the read receipt to the message sender.
  /// Other types of messages require a separate call to the [AgoraMessageListController.sendReadAck] method, which is invalidated if turned off.
  final bool enableReadAck;
  final List<AgoraMessageListItemModel> msgList = [];

  Future<void> Function(bool enableAnimation, bool moveToEnd)? _reloadData;
  void Function(ChatError error)? _onError;

  ChatMessage? _playingMessage;
  int _latestShowTsTime = -1;
  final ChatConversation conversation;
  bool _hasMore = true;
  bool _loading = false;
  bool hasFirstLoad = false;

  /// Send a message.
  ///
  /// Param [message] The message to send.
  void sendMessage(ChatMessage message) async {
    _removeMessageFromList(message);
    try {
      ChatMessage msg =
          await ChatClient.getInstance.chatManager.sendMessage(message);
      msgList.insert(0, _modelCreator(msg));
      await refreshUI(moveToEnd: true);
    } on ChatError catch (e) {
      _onError?.call(e);
    }
  }

  /// Remove a message.
  ///
  /// Param [message] The message to remove.
  Future<void> removeMessage(ChatMessage message) async {
    try {
      await conversation.deleteMessage(message.msgId);
      if (_removeMessageFromList(message)) {
        refreshUI();
      }
    } on ChatError catch (e) {
      _onError?.call(e);
    }
  }

  /// Recall a message.
  ///
  /// Param [message] The message to recall.
  Future<void> recallMessage(
    ChatMessage message,
  ) async {
    try {
      await ChatClient.getInstance.chatManager.recallMessage(message.msgId);
      _recallMessagesCallback([message]);
    } on ChatError catch (e) {
      _onError?.call(e);
    }
  }

  /// load messages
  ///
  /// Param [count] load count.
  Future<void> loadMoreMessage([int count = 10]) async {
    if (_loading) return;
    _loading = true;
    if (!_hasMore) {
      _loading = false;
      return;
    }

    List<ChatMessage> list = await conversation.loadMessages(
      startMsgId: msgList.isEmpty ? "" : msgList.last.msgId,
      loadCount: count,
    );
    if (list.length < count) {
      _hasMore = false;
    }

    List<AgoraMessageListItemModel> models = _modelsCreator(list, _hasMore);

    msgList.addAll(models);
    _loading = false;
    refreshUI();
  }

  /// Set all messages in the current conversation to read. current conversation see [AgoraMessagesList].
  Future<void> markAllMessagesAsRead() async {
    return conversation.markAllMessagesAsRead();
  }

  /// Set a message in the current conversation to read.
  /// affects only unread messages count in the conversation.
  ///
  /// Param [message] The message needs to be set to read. current conversation see [AgoraMessagesList].
  Future<void> markMessageAsRead(ChatMessage message) async {
    if (message.direction == MessageDirection.RECEIVE) {
      await conversation.markMessageAsRead(message.msgId);
    }
  }

  /// Send a message read receipt, the other party will receive a read receipt.
  /// only single-chat messages. Does not take effect when the [AgoraMessageListController.enableReadAck] is false.
  ///
  /// Param [message] Param [message] The message to send read ack.
  Future<void> sendReadAck(ChatMessage message) async {
    if (enableReadAck &&
        !message.hasReadAck &&
        message.direction == MessageDirection.RECEIVE &&
        conversation.type == ChatConversationType.Chat) {
      try {
        await ChatClient.getInstance.chatManager.sendMessageReadAck(message);
      } on ChatError catch (e) {
        _onError?.call(e);
      }
    }
  }

  /// Insert a message to the current conversation. If the message does not belong to the current conversation, it cannot be inserted.
  /// If the timestamp of the inserted Message is within the range of the message timestamp already displayed,
  /// it will be displayed in current [AgoraMessagesList].
  Future<void> insertMessage(ChatMessage message) async {
    if (message.conversationId == conversation.id) {
      try {
        await conversation.insertMessage(message);
        List models = msgList
            .getRange(
              msgList.indexWhere(
                  (element) => element.message.serverTime > message.serverTime),
              msgList.indexWhere(
                  (element) => element.message.serverTime < message.serverTime),
            )
            .toList();
        if (models.isNotEmpty) {
          int index = msgList.indexWhere(
              (element) => element.message.serverTime > message.serverTime);
          AgoraMessageListItemModel model = _modelCreator(message);
          msgList.insert(index + 1, model);
          _hasMore = false;
          refreshUI();
        }

        // ignore: empty_catches
      } catch (e) {}
    }
  }

  /// Deletes all messages in the current conversation. Only the local database is deleted.
  /// If the message roaming interface is called, the deleted message can still be retrieved.
  /// current conversation see [AgoraMessagesList]. message roaming see [ChatManager.fetchHistoryMessages].
  Future<void> deleteAllMessages() async {
    await ChatClient.getInstance.chatManager
        .deleteConversation(conversation.id);
    _latestShowTsTime = -1;
    msgList.clear();
    refreshUI();
  }

  /// Refresh AgoraMessagesList Widget. see [AgoraMessagesList].
  Future<void>? refreshUI({
    bool enableAnimation = false,
    bool moveToEnd = false,
  }) {
    return _reloadData?.call(enableAnimation, moveToEnd);
  }

  void play(ChatMessage message) {
    _playingMessage = message;
  }

  void stopPlay() {
    _playingMessage = null;
  }

  void _replaceMessage(ChatMessage fromMessage, ChatMessage toMessage) {
    int index = -1;
    do {
      index =
          msgList.indexWhere((element) => fromMessage.msgId == element.msgId);
      if (index >= 0) {
        AgoraMessageListItemModel model = msgList[index].copyWithMsg(toMessage);
        msgList[index] = model;
        break;
      }
    } while (false);
  }

  bool _removeMessageFromList(ChatMessage message) {
    int index = -1;
    do {
      index = msgList.indexWhere((element) => message.msgId == element.msgId);
      if (index >= 0) {
        _removeListWithIndex(msgList, index);
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

  void _handleMessage(String msgId, ChatMessage message) {
    int index = -1;
    do {
      index = msgList.indexWhere((element) => msgId == element.msgId);
      if (index > -1) {
        AgoraMessageListItemModel model = msgList[index].copyWithMsg(message);
        msgList[index] = model;
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
            _onError?.call(error);
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

          msgList.insertAll(0, tmp.map((e) => _modelCreator(e)).toList());
          refreshUI();
        },
        onMessagesRecalled: (messages) {
          _recallMessagesCallback(messages);
        },
      ),
    );
  }

  void _recallMessagesCallback(List<ChatMessage> msgs) async {
    bool needReload = false;
    for (var msg in msgs) {
      ChatMessage? needInsertMessage = didRecallMessage?.call(msg);
      if (needInsertMessage != null) {
        await conversation.insertMessage(needInsertMessage);
        _replaceMessage(msg, needInsertMessage);
        needReload = true;
      } else {
        if (_removeMessageFromList(msg)) {
          needReload = true;
        }
      }
    }
    if (needReload) {
      refreshUI();
    }
  }

  void _updateMessageItems(List<ChatMessage> list) {
    bool hasChange = false;

    for (var message in list) {
      int index = -1;
      do {
        index = msgList.indexWhere((element) => message.msgId == element.msgId);
        if (index > -1) {
          msgList[index] = msgList[index].copyWithMsg(message);
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
    void Function(ChatError error)? onError,
  }) {
    _reloadData = reloadData;
    _onError = onError;
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
    this.onError,
    this.enableScrollBar = true,
    this.needDismissInputWidgetAction,
  });

  /// Current conversation.
  final ChatConversation conversation;

  /// Error callback.
  final void Function(ChatError error)? onError;

  /// Message list controller.
  final AgoraMessageListController? messageListViewController;

  /// Message bubble builder.
  final AgoraMessageListItemBuilder? itemBuilder;

  /// Bubble click callback.
  final AgoraMessageTapAction? onTap;

  /// Bubble long press callback.
  final AgoraMessageTapAction? onBubbleLongPress;

  /// Bubble double-click the callback.
  final AgoraMessageTapAction? onBubbleDoubleTap;

  /// Avatar builder.
  final AgoraWidgetBuilder? avatarBuilder;

  /// Nickname builder.
  final AgoraWidgetBuilder? nicknameBuilder;

  /// Enable scroll bar.
  final bool enableScrollBar;

  /// Dismiss the input widget callback. If you use a customized inputBar,
  /// dismiss the inputBar when you receive the callback,
  /// for example, by calling [FocusNode.unfocus], see [AgoraMessageInputWidget].
  final VoidCallback? needDismissInputWidgetAction;

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

    controller._bindingActions(
      reloadData: _reloadData,
      onError: _onError,
    );
    controller.loadMoreMessage();
  }

  void _onError(ChatError err) {
    widget.onError?.call(err);
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
    widget.needDismissInputWidgetAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    List<AgoraMessageListItemModel> list = controller.msgList;

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
        ),
      ],
    );

    if (widget.enableScrollBar) {
      content = Scrollbar(child: content);
    }

    content = ScrollConfiguration(
      behavior: AgoraScrollBehavior(),
      child: content,
    );

    return content;
  }

  Widget messageWidget(AgoraMessageListItemModel model) {
    ChatMessage message = model.message;
    controller.sendReadAck(message);

    ValueKey<String>? valueKey; //ValueKey(message.msgId);

    Widget content = widget.itemBuilder?.call(context, model) ??
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
              bubblePadding: EdgeInsets.zero,
              bubbleColor: Colors.transparent,
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
              bubbleColor: const Color.fromRGBO(242, 242, 242, 1),
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
              isPlay: controller._playingMessage?.msgId == message.msgId,
              unreadFlagBuilder: message.hasRead
                  ? null
                  : (context) {
                      return Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.pink,
                        ),
                        width: 10,
                        height: 10,
                      );
                    },
            );
          }

          return Container(width: 100, height: 100, color: Colors.red);
        }();

    return content;
  }
}
