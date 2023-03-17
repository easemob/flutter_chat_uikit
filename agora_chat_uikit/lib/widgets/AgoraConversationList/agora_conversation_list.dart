import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../controllers/agora_base_controller.dart';

class AgoraConversationListController extends AgoraBaseController {
  AgoraConversationListController({
    super.key,
  }) {
    _addListener();
    loadAllConversations();
  }

  AgoraConversationSortHandle? sortHandle;
  final ValueNotifier<List<ChatConversation>> _listValueNotifier =
      ValueNotifier([]);
  final ValueNotifier<int> _totalUnreadCountNotifier = ValueNotifier(0);

  List<ChatConversation> get conversationList => _listValueNotifier.value;
  int get totalUnreadCount => _totalUnreadCountNotifier.value;

  set conversationList(List<ChatConversation> list) {
    _listValueNotifier.value = List.from(list);

    ChatClient.getInstance.chatManager
        .getUnreadMessageCount()
        .then((value) => _totalUnreadCountNotifier.value = value);
  }

  void addListListener(VoidCallback function) {
    _listValueNotifier.addListener(function);
  }

  void removeListListener(VoidCallback function) {
    _listValueNotifier.removeListener(function);
  }

  void addTotalUnreadCountListener(VoidCallback function) {
    _totalUnreadCountNotifier.addListener(function);
  }

  void removeTotalUnreadCountListener(VoidCallback function) {
    _totalUnreadCountNotifier.removeListener(function);
  }

  void _addListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      key,
      ChatEventHandler(
        onMessagesReceived: (messages) async {
          loadAllConversations();
        },
      ),
    );
  }

  void dispose() {
    ChatClient.getInstance.chatManager.removeEventHandler(key);
  }

  /// LoadAllConversations
  Future<void> loadAllConversations() async {
    List<ChatConversation> list =
        await ChatClient.getInstance.chatManager.loadAllConversations();
    conversationList = await sortHandle?.call(list) ?? list;
  }

  /// Delete conversation with conversation id.
  /// Param [id] conversation id
  Future<void> deleteConversationWithId(String id) async {
    List<ChatConversation> list = conversationList;
    int index = list.indexWhere((element) => element.id == id);
    if (index >= 0) {
      list.removeAt(index);
      await ChatClient.getInstance.chatManager.deleteConversation(id);
      conversationList = await sortHandle?.call(list) ?? list;
    }
  }

  /// Delete all conversation.
  Future<void> deleteAllConversations({bool includeMessage = true}) async {
    List<ChatConversation> list = conversationList;
    await Future.wait(list
        .map((element) => ChatClient.getInstance.chatManager.deleteConversation(
              element.id,
              deleteMessages: includeMessage,
            ))).then((value) => conversationList = []);
    if (includeMessage) {
      _totalUnreadCountNotifier.value = 0;
    }
  }

  /// Mark all conversations as read.
  Future<void> markAllConversationAsRead() async {
    await ChatClient.getInstance.chatManager.markAllConversationsAsRead();
    await loadAllConversations();
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    int index =
        conversationList.indexWhere((element) => element.id == conversationId);
    if (index != -1) {
      ChatConversation tmp = conversationList[index];
      await tmp.markAllMessagesAsRead();
      ChatConversation? conv = await ChatClient.getInstance.chatManager
          .getConversation(tmp.id, type: tmp.type);
      conversationList[index] = conv!;
      await loadAllConversations();
    }
  }
}

class AgoraConversationListView extends StatefulWidget {
  const AgoraConversationListView({
    super.key,
    required this.onItemTap,
    this.controller,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.down,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.avatarBuilder,
    this.nicknameBuilder,
  });

  final ScrollController? controller;
  final AgoraConversationItemWidgetBuilder? itemBuilder;
  final AgoraConversationWidgetBuilder? avatarBuilder;
  final AgoraConversationWidgetBuilder? nicknameBuilder;

  final bool reverse;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final void Function(ChatConversation conversation) onItemTap;
  @override
  State<AgoraConversationListView> createState() =>
      AgoraConversationListViewState();

  static AgoraConversationListViewState of(BuildContext context) {
    AgoraConversationListViewState? state;
    state = context.findAncestorStateOfType<AgoraConversationListViewState>();

    assert(
      state != null,
      'You must have a AgoraConversationListView widget at the top of you widget tree',
    );

    return state!;
  }
}

class AgoraConversationListViewState extends State<AgoraConversationListView> {
  late final AgoraConversationListController controller;
  @override
  void initState() {
    super.initState();
    controller = AgoraChatUIKit.of(context).conversationsController;
    controller.addListListener(_handleDataSourceUpdate);
    controller.loadAllConversations();
  }

  @override
  void dispose() {
    controller.removeListListener(_handleDataSourceUpdate);
    super.dispose();
  }

  void _handleDataSourceUpdate() {
    setState(() {});
  }

  final List<ChatConversation> _tmpList = [];

  @override
  Widget build(BuildContext context) {
    _tmpList.clear();
    _tmpList.addAll(controller.conversationList);

    return AgoraSwipeAutoCloseBehavior(
      child: _tmpList.isEmpty
          ? Center(
              child: AgoraImageLoader.loadImage("conversation_empty.png"),
            )
          : ListView.custom(
              scrollDirection: Axis.vertical,
              reverse: widget.reverse,
              controller: widget.controller,
              primary: widget.primary,
              physics: widget.physics,
              shrinkWrap: widget.shrinkWrap,
              padding: widget.padding,
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  ChatConversation conversation = _tmpList[index];
                  return widget.itemBuilder
                          ?.call(context, index, conversation) ??
                      AgoraSwipeWidget(
                        key: ValueKey(conversation.id),
                        rightSwipeItems: [
                          AgoraSwipeItem(
                            dismissed: (bool dismissed) async {
                              if (dismissed) {
                                {
                                  await controller.deleteConversationWithId(
                                      conversation.id);
                                }
                              }
                            },
                            backgroundColor: Colors.red,
                            text: "Delete",
                            confirmAction: (_) async {
                              return await AgoraBottomSheet(
                                    titleLabel: "Delete conversation",
                                    items: [
                                      AgoraBottomSheetItem("Confirm",
                                          onTap: () =>
                                              Navigator.of(context).pop(true)),
                                      AgoraBottomSheetItem("Cancel",
                                          onTap: () =>
                                              Navigator.of(context).pop(false)),
                                    ],
                                  ).show(context) ??
                                  false;
                            },
                          ),
                        ],
                        child: Container(
                          color: Colors.white,
                          child: AgoraConversationListTile(
                            avatar: widget.avatarBuilder
                                    ?.call(context, conversation) ??
                                AgoraImageLoader.defaultAvatar(size: 40),
                            title: widget.nicknameBuilder
                                ?.call(context, conversation),
                            conversation: conversation,
                            onTap: (conversation) {
                              widget.onItemTap?.call(conversation);
                            },
                          ),
                        ),
                      );
                },
                semanticIndexCallback: (Widget _, int index) => index,
                findChildIndexCallback: (key) {
                  final ValueKey<String> valueKey = key as ValueKey<String>;
                  int index = _tmpList.indexWhere(
                      (conversation) => conversation.id == valueKey.value);

                  return index > -1 ? index : null;
                },
                childCount: _tmpList.length,
              ),
              cacheExtent: widget.cacheExtent ?? 2000,
              dragStartBehavior: widget.dragStartBehavior,
              keyboardDismissBehavior: widget.keyboardDismissBehavior,
              restorationId: widget.restorationId,
              clipBehavior: widget.clipBehavior,
            ),
    );
  }
}
