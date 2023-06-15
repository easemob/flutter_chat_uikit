import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../flutter_chat_uikit.dart';
import '../../widgets/chat_swipe_widget/chat_swipe_widget.dart';

class ChatConversationsController extends ChatBaseController {
  ChatConversationsController({
    super.key,
  }) {
    _addListener();
    loadAllConversations();
  }

  final ValueNotifier<List<EMConversation>> _listValueNotifier =
      ValueNotifier([]);

  final ValueNotifier<int> _totalUnreadCountNotifier = ValueNotifier(0);

  /// Conversation list sorting Handler.
  ChatConversationSortHandle? sortHandle;

  /// Get conversation list.
  List<EMConversation> get conversationList => _listValueNotifier.value;
  int get totalUnreadCount => _totalUnreadCountNotifier.value;

  /// Set conversation list.
  set conversationList(List<EMConversation> list) {
    _listValueNotifier.value = List.from(list);

    EMClient.getInstance.chatManager
        .getUnreadMessageCount()
        .then((value) => _totalUnreadCountNotifier.value = value);
  }

  /// Registers the conversation list change event.
  void addListListener(VoidCallback function) {
    _listValueNotifier.addListener(function);
  }

  /// Unregisters the conversation list change event.
  void removeListListener(VoidCallback function) {
    _listValueNotifier.removeListener(function);
  }

  /// Registers the session read-out change event.
  void addTotalUnreadCountListener(VoidCallback function) {
    _totalUnreadCountNotifier.addListener(function);
  }

  /// Unregisters the session read-out change event.
  void removeTotalUnreadCountListener(VoidCallback function) {
    _totalUnreadCountNotifier.removeListener(function);
  }

  void _addListener() {
    EMClient.getInstance.chatManager.addEventHandler(
      key,
      EMChatEventHandler(
        onMessagesReceived: (messages) async {
          loadAllConversations();
        },
        onMessagesRecalled: (messages) {
          loadAllConversations();
        },
      ),
    );
  }

  void dispose() {
    EMClient.getInstance.chatManager.removeEventHandler(key);
  }

  /// load all conversations and refresh the list.
  Future<void> loadAllConversations() async {
    List<EMConversation> list =
        await EMClient.getInstance.chatManager.loadAllConversations();
    conversationList = await sortHandle?.call(list) ?? list;
  }

  /// Delete conversation with conversation id.
  ///
  /// Param [id] conversation id
  Future<void> deleteConversationWithId(String id) async {
    List<EMConversation> list = conversationList;
    int index = list.indexWhere((element) => element.id == id);
    if (index >= 0) {
      list.removeAt(index);
      await EMClient.getInstance.chatManager.deleteConversation(id);
      conversationList = await sortHandle?.call(list) ?? list;
    }
  }

  /// Delete all conversations.
  ///
  /// Param [includeMessage] Whether to delete messages at the same time.
  Future<void> deleteAllConversations({bool includeMessage = true}) async {
    List<EMConversation> list = conversationList;
    await Future.wait(list
        .map((element) => EMClient.getInstance.chatManager.deleteConversation(
              element.id,
              deleteMessages: includeMessage,
            ))).then((value) => conversationList = []);
    if (includeMessage) {
      _totalUnreadCountNotifier.value = 0;
    }
  }

  /// Mark all conversations as read.
  Future<void> markAllConversationAsRead() async {
    await EMClient.getInstance.chatManager.markAllConversationsAsRead();
    await loadAllConversations();
  }

  /// Mark a conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    int index =
        conversationList.indexWhere((element) => element.id == conversationId);
    if (index != -1) {
      EMConversation tmp = conversationList[index];
      await tmp.markAllMessagesAsRead();
      EMConversation? conv = await EMClient.getInstance.chatManager
          .getConversation(tmp.id, type: tmp.type);
      conversationList[index] = conv!;
      await loadAllConversations();
    }
  }
}

/// Conversation list Widget
class ChatConversationsView extends StatefulWidget {
  /// Conversation list Widget
  /// [controller] The ScrollController for the conversation list.
  ///
  /// [onItemTap] Conversation list item Click event callback.
  ///
  /// [reverse] Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model
  /// can control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [primary] Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [physics] Creates a scrollable, linear array of widgets with a custom child model.
  /// For example, a custom child model can control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [shrinkWrap] Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model
  /// can control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [cacheExtent] Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model
  /// can control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [dragStartBehavior] Creates a scrollable, linear array of widgets with a custom child model.For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [keyboardDismissBehavior] Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [restorationId] Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [clipBehavior] Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  ///
  /// [itemBuilder] Conversation list item builder, return a widget if you need to customize it.
  ///
  /// [avatarBuilder] Avatar builder, if not implemented or returns null will use the default avatar.
  ///
  /// [nicknameBuilder] Nickname builder, which displays the userId if not set or null is returned.
  ///
  const ChatConversationsView({
    super.key,
    this.controller,
    this.onItemTap,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.down,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.avatarBuilder,
    this.nicknameBuilder,
  });

  /// The ScrollController for the conversation list.
  final ScrollController? controller;

  /// Conversation list item builder, return a widget if you need to customize it.
  final ChatConversationItemWidgetBuilder? itemBuilder;

  /// Avatar builder, if not implemented or returns null will use the default avatar.
  final ChatConversationWidgetBuilder? avatarBuilder;

  /// Nickname builder, which displays the userId if not set or null is returned.
  final ChatConversationWidgetBuilder? nicknameBuilder;

  /// Conversation list item Click event callback.
  final void Function(EMConversation conversation)? onItemTap;

  /// Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model
  /// can control the algorithm used to estimate the size of children that are not actually visible.
  final bool reverse;

  /// Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  final bool? primary;

  /// Creates a scrollable, linear array of widgets with a custom child model.
  /// For example, a custom child model can control the algorithm used to estimate the size of children that are not actually visible.
  final ScrollPhysics? physics;

  /// Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model
  /// can control the algorithm used to estimate the size of children that are not actually visible.
  final bool shrinkWrap;

  /// Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model
  /// can control the algorithm used to estimate the size of children that are not actually visible.
  final double? cacheExtent;

  /// Creates a scrollable, linear array                                                                                                                                                                                                                                                                                                         of widgets with a custom child model.For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  final DragStartBehavior dragStartBehavior;

  /// Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  final String? restorationId;

  /// Creates a scrollable, linear array of widgets with a custom child model. For example, a custom child model can
  /// control the algorithm used to estimate the size of children that are not actually visible.
  final Clip clipBehavior;

  @override
  State<ChatConversationsView> createState() => ChatConversationsViewState();

  static ChatConversationsViewState of(BuildContext context) {
    ChatConversationsViewState? state;
    state = context.findAncestorStateOfType<ChatConversationsViewState>();

    assert(
      state != null,
      'You must have a ChatConversationListView widget at the top of you widget tree',
    );

    return state!;
  }
}

class ChatConversationsViewState extends State<ChatConversationsView> {
  late final ChatConversationsController controller;
  @override
  void initState() {
    super.initState();
    controller = ChatUIKit.of(context).conversationsController;
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

  final List<EMConversation> _tmpList = [];

  @override
  Widget build(BuildContext context) {
    _tmpList.clear();
    _tmpList.addAll(controller.conversationList);

    if (_tmpList.isEmpty) {
      return Center(
        child: ChatImageLoader.loadImage("conversation_empty.png"),
      );
    }

    return ChatSwipeAutoCloseBehavior(
      child: CustomScrollView(
        clipBehavior: widget.clipBehavior,
        restorationId: widget.restorationId,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        dragStartBehavior: widget.dragStartBehavior,
        cacheExtent: widget.cacheExtent,
        shrinkWrap: widget.shrinkWrap,
        controller: widget.controller,
        primary: widget.primary,
        reverse: widget.reverse,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                EMConversation conversation = _tmpList[index];
                return widget.itemBuilder?.call(context, index, conversation) ??
                    ChatSwipeWidget(
                      key: ValueKey(conversation.id),
                      rightSwipeItems: [
                        ChatSwipeItem(
                          dismissed: (bool dismissed) async {
                            if (dismissed) {
                              {
                                await controller
                                    .deleteConversationWithId(conversation.id);
                              }
                            }
                          },
                          backgroundColor: Colors.red,
                          text: AppLocalizations.of(context)?.uikitDelete ??
                              "Delete",
                          confirmAction: (_) async {
                            List<ChatBottomSheetItem> list = [
                              ChatBottomSheetItem.normal(
                                'Confirm',
                                onTap: () async {
                                  return Navigator.of(context).pop(true);
                                },
                              ),
                              ChatBottomSheetItem.normal(
                                'Cancel',
                                onTap: () async {
                                  return Navigator.of(context).pop(false);
                                },
                              )
                            ];

                            return await showChatBottomSheet(
                                  context: context,
                                  title: 'Delete conversation',
                                  items: list,
                                ) ??
                                false;
                          },
                        ),
                      ],
                      child: Container(
                        color: Colors.white,
                        child: ChatConversationListTile(
                          avatar: widget.avatarBuilder
                                  ?.call(context, conversation) ??
                              ChatImageLoader.defaultAvatar(size: 40),
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
          )
        ],
      ),
    );
  }
}
