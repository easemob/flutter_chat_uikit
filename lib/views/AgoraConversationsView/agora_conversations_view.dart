import 'package:agora_chat_uikit/agora_chat_uikit.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:agora_chat_uikit/controllers/agora_base_controller.dart';

class AgoraConversationsController extends AgoraBaseController {
  AgoraConversationsController({
    super.key,
  }) {
    _addListener();
    loadAllConversations();
  }

  final ValueNotifier<List<ChatConversation>> _listValueNotifier =
      ValueNotifier([]);

  final ValueNotifier<int> _totalUnreadCountNotifier = ValueNotifier(0);

  /// Conversation list sorting Handler.
  AgoraConversationSortHandle? sortHandle;

  /// Get conversation list.
  List<ChatConversation> get conversationList => _listValueNotifier.value;
  int get totalUnreadCount => _totalUnreadCountNotifier.value;

  /// Set conversation list.
  set conversationList(List<ChatConversation> list) {
    _listValueNotifier.value = List.from(list);

    ChatClient.getInstance.chatManager
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
    ChatClient.getInstance.chatManager.addEventHandler(
      key,
      ChatEventHandler(
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
    ChatClient.getInstance.chatManager.removeEventHandler(key);
  }

  /// Update the conversations and refresh the list.
  Future<void> loadAllConversations() async {
    List<ChatConversation> list =
        await ChatClient.getInstance.chatManager.loadAllConversations();
    conversationList = await sortHandle?.call(list) ?? list;
  }

  /// Delete conversation with conversation id.
  ///
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
  ///
  /// Param [includeMessage] Whether to delete messages at the same time.
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

/// Conversation list Widget
class AgoraConversationsView extends StatefulWidget {
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
  const AgoraConversationsView({
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
  final AgoraConversationItemWidgetBuilder? itemBuilder;

  /// Avatar builder, if not implemented or returns null will use the default avatar.
  final AgoraConversationWidgetBuilder? avatarBuilder;

  /// Nickname builder, which displays the userId if not set or null is returned.
  final AgoraConversationWidgetBuilder? nicknameBuilder;

  /// Conversation list item Click event callback.
  final void Function(ChatConversation conversation)? onItemTap;

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
  State<AgoraConversationsView> createState() => AgoraConversationsViewState();

  static AgoraConversationsViewState of(BuildContext context) {
    AgoraConversationsViewState? state;
    state = context.findAncestorStateOfType<AgoraConversationsViewState>();

    assert(
      state != null,
      'You must have a AgoraConversationListView widget at the top of you widget tree',
    );

    return state!;
  }
}

class AgoraConversationsViewState extends State<AgoraConversationsView> {
  late final AgoraConversationsController controller;
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

    if (_tmpList.isEmpty) {
      return Center(
        child: AgoraImageLoader.loadImage("conversation_empty.png"),
      );
    }

    return AgoraSwipeAutoCloseBehavior(
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
                ChatConversation conversation = _tmpList[index];
                return widget.itemBuilder?.call(context, index, conversation) ??
                    AgoraSwipeWidget(
                      key: ValueKey(conversation.id),
                      rightSwipeItems: [
                        AgoraSwipeItem(
                          dismissed: (bool dismissed) async {
                            if (dismissed) {
                              {
                                await controller
                                    .deleteConversationWithId(conversation.id);
                              }
                            }
                          },
                          backgroundColor: Colors.red,
                          text: AppLocalizations.of(context)?.agoraDelete ??
                              "Delete",
                          confirmAction: (_) async {
                            return await AgoraBottomSheet(
                                  titleLabel: AppLocalizations.of(context)
                                          ?.agoraDeleteConversation ??
                                      'Delete conversation',
                                  items: [
                                    AgoraBottomSheetItem(
                                        AppLocalizations.of(context)
                                                ?.agoraConfirm ??
                                            'Confirm',
                                        onTap: () =>
                                            Navigator.of(context).pop(true)),
                                    AgoraBottomSheetItem(
                                        AppLocalizations.of(context)
                                                ?.agoraCancel ??
                                            'Cancel',
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
          )
        ],
      ),
    );
  }
}
