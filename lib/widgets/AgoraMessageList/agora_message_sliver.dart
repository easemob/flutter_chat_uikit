import 'package:flutter/widgets.dart';

import 'agora_message_sliver_list.dart';

class AgoraMessageSliver extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places box children in a linear array.
  const AgoraMessageSliver({
    super.key,
    required super.delegate,
  });

  @override
  SliverMultiBoxAdaptorElement createElement() =>
      SliverMultiBoxAdaptorElement(this, replaceMovedChildren: true);

  @override
  AgoraMessageRenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return AgoraMessageRenderSliverList(childManager: element);
  }
}
