import 'package:agora_chat_uikit/widgets/AgoraMessageList/list/rendering/sliver_fixed_extend_list.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageList/list/rendering/sliver_list.dart';
import 'package:agora_chat_uikit/widgets/AgoraMessageList/list/src/extended_list_library.dart';
import 'package:flutter/widgets.dart';

class ExtendedSliverList extends SliverMultiBoxAdaptorWidget {
  const ExtendedSliverList({
    Key? key,
    required SliverChildDelegate delegate,
    required this.extendedListDelegate,
  }) : super(key: key, delegate: delegate);

  final ExtendedListDelegate extendedListDelegate;

  @override
  ExtendedRenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return ExtendedRenderSliverList(
      childManager: element,
      extendedListDelegate: extendedListDelegate,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, ExtendedRenderSliverList renderObject) {
    renderObject.extendedListDelegate = extendedListDelegate;
  }
}

class ExtendedSliverFixedExtentList extends SliverMultiBoxAdaptorWidget {
  const ExtendedSliverFixedExtentList({
    Key? key,
    required SliverChildDelegate delegate,
    required this.itemExtent,
    required this.extendedListDelegate,
  }) : super(key: key, delegate: delegate);

  final double itemExtent;

  final ExtendedListDelegate extendedListDelegate;
  @override
  ExtendedRenderSliverFixedExtentList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return ExtendedRenderSliverFixedExtentList(
      childManager: element,
      itemExtent: itemExtent,
      extendedListDelegate: extendedListDelegate,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    ExtendedRenderSliverFixedExtentList renderObject,
  ) {
    renderObject.itemExtent = itemExtent;
    renderObject.extendedListDelegate = extendedListDelegate;
  }
}
