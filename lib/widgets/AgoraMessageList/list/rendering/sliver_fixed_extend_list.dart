import 'dart:math' as math;

import 'package:agora_chat_uikit/widgets/AgoraMessageList/list/src/extended_list_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

abstract class ExtendedRenderSliverFixedExtentBoxAdaptor
    extends RenderSliverMultiBoxAdaptor with ExtendedRenderObjectMixin {
  ExtendedRenderSliverFixedExtentBoxAdaptor({
    required RenderSliverBoxChildManager childManager,
    required ExtendedListDelegate extendedListDelegate,
  })  : _extendedListDelegate = extendedListDelegate,
        super(childManager: childManager);

  ExtendedListDelegate _extendedListDelegate;

  @override
  ExtendedListDelegate get extendedListDelegate => _extendedListDelegate;
  set extendedListDelegate(ExtendedListDelegate value) {
    if (_extendedListDelegate == value) {
      return;
    }
    if (_extendedListDelegate.closeToTrailing != value.closeToTrailing) {
      markNeedsLayout();
    }
    _extendedListDelegate = value;
  }

  double get itemExtent;

  @protected
  double indexToLayoutOffset(double itemExtent, int index) =>
      itemExtent * index;

  @protected
  int getMinChildIndexForScrollOffset(double scrollOffset, double itemExtent) {
    if (itemExtent > 0.0) {
      final double actual = scrollOffset / itemExtent;
      final int round = actual.round();
      if ((actual - round).abs() < precisionErrorTolerance) {
        return round;
      }
      return actual.floor();
    }
    return 0;
  }

  @protected
  int getMaxChildIndexForScrollOffset(double scrollOffset, double itemExtent) {
    if (itemExtent > 0.0) {
      final double actual = scrollOffset / itemExtent - 1;
      final int round = actual.round();
      if (_isWithinPrecisionErrorTolerance(actual, round)) {
        return math.max(0, round);
      }
      return math.max(0, actual.ceil());
    }
    return 0;
  }

  @protected
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  }) {
    return childManager.estimateMaxScrollOffset(
      constraints,
      firstIndex: firstIndex,
      lastIndex: lastIndex,
      leadingScrollOffset: leadingScrollOffset,
      trailingScrollOffset: trailingScrollOffset,
    );
  }

  @protected
  double computeMaxScrollOffset(
      SliverConstraints constraints, double itemExtent) {
    return childManager.childCount * itemExtent;
  }

  int _calculateLeadingGarbage(int firstIndex) {
    RenderBox? walker = firstChild;
    int leadingGarbage = 0;
    while (walker != null && indexOf(walker) < firstIndex) {
      leadingGarbage += 1;
      walker = childAfter(walker);
    }
    return leadingGarbage;
  }

  int _calculateTrailingGarbage(int? targetLastIndex) {
    RenderBox? walker = lastChild;
    int trailingGarbage = 0;
    while (walker != null && indexOf(walker) > targetLastIndex!) {
      trailingGarbage += 1;
      walker = childBefore(walker);
    }
    return trailingGarbage;
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double itemExtent = this.itemExtent;

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    final BoxConstraints childConstraints = constraints.asBoxConstraints(
      minExtent: itemExtent,
      maxExtent: itemExtent,
    );

    final int firstIndex =
        getMinChildIndexForScrollOffset(scrollOffset, itemExtent);
    final int? targetLastIndex = targetEndScrollOffset.isFinite
        ? getMaxChildIndexForScrollOffset(targetEndScrollOffset, itemExtent)
        : null;

    if (firstChild != null) {
      final int leadingGarbage = _calculateLeadingGarbage(firstIndex);
      final int trailingGarbage = targetLastIndex != null
          ? _calculateTrailingGarbage(targetLastIndex)
          : 0;
      collectGarbage(leadingGarbage, trailingGarbage);
      //zmt
      callCollectGarbage(
        collectGarbage: extendedListDelegate.collectGarbage,
        leadingGarbage: leadingGarbage,
        trailingGarbage: trailingGarbage,
        firstIndex: firstIndex,
        targetLastIndex: targetLastIndex,
      );
    } else {
      collectGarbage(0, 0);
    }

    if (firstChild == null) {
      if (!addInitialChild(
          index: firstIndex,
          layoutOffset: indexToLayoutOffset(itemExtent, firstIndex))) {
        final double max;
        if (firstIndex <= 0) {
          max = 0.0;
        } else {
          max = computeMaxScrollOffset(constraints, itemExtent);
        }
        geometry = SliverGeometry(
          scrollExtent: max,
          maxPaintExtent: max,
        );
        childManager.didFinishLayout();
        return;
      }
    }

    handleCloseToTrailingBegin(closeToTrailing);

    RenderBox? trailingChildWithLayout;

    for (int index = indexOf(firstChild!) - 1; index >= firstIndex; --index) {
      final RenderBox? child = insertAndLayoutLeadingChild(childConstraints);
      if (child == null) {
        geometry = SliverGeometry(scrollOffsetCorrection: index * itemExtent);
        return;
      }
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(itemExtent, index);
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
    }

    if (trailingChildWithLayout == null) {
      firstChild!.layout(childConstraints);
      final SliverMultiBoxAdaptorParentData childParentData =
          firstChild!.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset =
          indexToLayoutOffset(itemExtent, firstIndex);
      trailingChildWithLayout = firstChild;
    }

    double estimatedMaxScrollOffset = double.infinity;
    for (int index = indexOf(trailingChildWithLayout!) + 1;
        targetLastIndex == null || index <= targetLastIndex;
        ++index) {
      RenderBox? child = childAfter(trailingChildWithLayout!);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(childConstraints,
            after: trailingChildWithLayout);
        if (child == null) {
          estimatedMaxScrollOffset = index * itemExtent;
          break;
        }
      } else {
        child.layout(childConstraints);
      }
      trailingChildWithLayout = child;
      final SliverMultiBoxAdaptorParentData childParentData =
          child.parentData as SliverMultiBoxAdaptorParentData;
      assert(childParentData.index == index);
      childParentData.layoutOffset =
          indexToLayoutOffset(itemExtent, childParentData.index!);
    }

    final int lastIndex = indexOf(lastChild!);
    final double leadingScrollOffset =
        indexToLayoutOffset(itemExtent, firstIndex);
    double trailingScrollOffset =
        indexToLayoutOffset(itemExtent, lastIndex + 1);

    final double result =
        handleCloseToTrailingEnd(closeToTrailing, trailingScrollOffset);
    if (result != trailingScrollOffset) {
      trailingScrollOffset = result;
      estimatedMaxScrollOffset = result;
    }

    lastChild!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double paintExtend = paintExtentOf(lastChild!);
    trailingScrollOffset = childScrollOffset(lastChild!)! + paintExtend;
    if (trailingScrollOffset < constraints.remainingPaintExtent) {
      final SliverMultiBoxAdaptorParentData childParentData =
          lastChild!.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset =
          constraints.remainingPaintExtent - paintExtend;
      trailingScrollOffset = constraints.remainingPaintExtent;
    }
    estimatedMaxScrollOffset = trailingScrollOffset;
    assert(firstIndex == 0 ||
        childScrollOffset(firstChild!)! - scrollOffset <=
            precisionErrorTolerance);
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild!) == firstIndex);
    assert(targetLastIndex == null || lastIndex <= targetLastIndex);

    estimatedMaxScrollOffset = math.min(
      estimatedMaxScrollOffset,
      estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      ),
    );

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    final int? targetLastIndexForPaint = targetEndScrollOffsetForPaint.isFinite
        ? getMaxChildIndexForScrollOffset(
            targetEndScrollOffsetForPaint, itemExtent)
        : null;

    ///zmt
    callViewportBuilder(
        viewportBuilder: extendedListDelegate.viewportBuilder,
        getPaintExtend: (RenderBox? child) {
          return itemExtent;
        });

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      hasVisualOverflow: (targetLastIndexForPaint != null &&
              lastIndex >= targetLastIndexForPaint) ||
          constraints.scrollOffset > 0.0,
    );

    if (estimatedMaxScrollOffset == trailingScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }
}

class ExtendedRenderSliverFixedExtentList
    extends ExtendedRenderSliverFixedExtentBoxAdaptor {
  ExtendedRenderSliverFixedExtentList(
      {required RenderSliverBoxChildManager childManager,
      required double itemExtent,
      required ExtendedListDelegate extendedListDelegate})
      : _itemExtent = itemExtent,
        super(
          childManager: childManager,
          extendedListDelegate: extendedListDelegate,
        );

  @override
  double get itemExtent => _itemExtent;
  double _itemExtent;
  set itemExtent(double value) {
    if (_itemExtent == value) {
      return;
    }
    _itemExtent = value;
    markNeedsLayout();
  }
}

bool _isWithinPrecisionErrorTolerance(double actual, int round) {
  return (actual - round).abs() < precisionErrorTolerance;
}
