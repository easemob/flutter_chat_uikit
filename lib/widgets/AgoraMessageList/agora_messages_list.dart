import 'package:agora_chat_uikit/agora_chat_uikit.dart';
import 'package:agora_chat_uikit/controllers/agora_base_controller.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageList/agora_scroll_behavior.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageList/list/extended_list_library.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageList/list/widgets/scroll_view.dart';

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

    await moveToEnd();
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
    if (list.length != index && model.needTime) {
      list[index] = list[index].copyWithNeedTime(true);
    }
  }

  Future<void> recallMessage(BuildContext context, ChatMessage message) async {
    try {
      await ChatClient.getInstance.chatManager.recallMessage(message.msgId);
      if (_removeMessageFromList(message)) {
        refreshUI();
      }
    } on ChatError catch (e) {
      String str = e.description;
      final snackBar = SnackBar(content: Text(str));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // load message message
  Future<void> loadMoreMessage([int count = 15]) async {
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

    List<AgoraMessageListItemModel> models =
        _modelsCreator(list.reversed.toList(), _hasMore);

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
      index = _msgList.indexWhere((element) => msgId == element.msgId);
      if (index > -1) {
        _msgList[index] = _msgList[index].copyWithMsg(message);
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

            _msgList.addAll(tmp.map((e) => _modelCreator(e)).toList());
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
          _msgList[index] = AgoraMessageListItemModel(message);
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

  Future<void> _reloadData() async {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant AgoraMessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
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
  }

  @override
  Widget build(BuildContext context) {
    List<AgoraMessageListItemModel> list = controller._msgList;
    Widget content = ExtendedListView.custom(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      cacheExtent: 1500,
      reverse: true,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          return messageWidget(list[index]);
        },
        childCount: list.length,
      ),
      extendedListDelegate: const ExtendedListDelegate(closeToTrailing: true),
    );

    return ScrollConfiguration(
      behavior: AgoraScrollBehavior(),
      child: Scrollbar(child: content),
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

    bool ret = await widget.onBubbleLongPress?.call(ctx, msg) ?? false;

    return ret;
  }
}
