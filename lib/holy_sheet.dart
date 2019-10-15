library holy_sheet;

import 'package:flutter/widgets.dart';
import 'package:harusaki/harusaki.dart';

const double _minFlingVelocity = 1.5;

/// From where does the sheet rise?
enum RiseFrom {
  /// Top Sheet
  Heaven,

  /// Bottom Sheet
  Hell,
}

class HolySheet extends StatefulWidget {
  const HolySheet({
    Key key,
    @required this.riseFrom,
    @required this.animationController,
    this.animationBuilder,
    @required this.builder,
  }) : super(key: key);

  /// From where should the holy sheet rise?
  ///
  /// Heaven = from the top and Hell = from the bottom
  final RiseFrom riseFrom;

  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The HolySheet will manipulate the position of this animation, it
  /// is not just a passive observer.
  final HarusakiAnimationController animationController;

  final TransitionBuilder animationBuilder;

  /// A builder for the contents of the sheet.
  final WidgetBuilder builder;

  @override
  _HolySheetState createState() => _HolySheetState();
}

class _HolySheetState extends State<HolySheet> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'HolySheet child');

  // BouncingScrollPhysics exposes frictionFactor, so we'll keep things DRY
  final _scrollPhysics = BouncingScrollPhysics();

  HarusakiAnimationController get _controller => widget.animationController;

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  double get _sign => widget.riseFrom == RiseFrom.Heaven ? 1 : -1;

  void _handleDragStart(DragStartDetails details) {
    _controller.stop(canceled: true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // if the AnimationController is unbounded, we assume we actually want 0.0 and 1.0
    final lowerBound = _controller.lowerBound == double.negativeInfinity //
        ? 0.0
        : _controller.lowerBound;
    final upperBound = _controller.upperBound == double.infinity //
        ? 1.0
        : _controller.upperBound;

    // overscroll fraction is the diff between our current location and the expected bounds
    final overscrollFraction = _controller.value > upperBound
        ? _controller.value - upperBound
        : _controller.value < lowerBound //
            ? lowerBound - _controller.value
            : 0.0;

    // if we're overscrolling, apply the friction
    final friction =
        overscrollFraction > 0 ? _scrollPhysics.frictionFactor(overscrollFraction) : 1.0;

    // the height of the child (default to the amount dragged to cancel out the divisin)
    final height = _childHeight ?? details.primaryDelta;

    // set the controller value to the amount dragged
    _controller.value += _sign * (details.primaryDelta / height * friction);
  }

  void _handleDragEnd(DragEndDetails details) {
    // compute the _relative_ velocity
    final velocity = details.primaryVelocity / _childHeight;

    // are we flinging the sheet in a specific direction?
    final flinging = velocity.abs() > _minFlingVelocity;
    if (flinging) {
      // if so, ignore where we are in the process and just chuck the sheet to that bounds
      _controller.fling(velocity: _sign * velocity);
      return;
    }

    // if we're not flinging, let's settle somewhere
    final controllerRange = _controller.suggestedUpperBound - _controller.suggestedLowerBound;
    final isInUpperSegment = _controller.value >= (controllerRange * 0.5);
    final isInLowerSegment = !isInUpperSegment;

    // the pointer is moving in the 'higher' direction if
    // 1) when pulling from the top, is positive
    // 2) when pulling from the bottom, is negative
    final isMovingHigher = widget.riseFrom == RiseFrom.Heaven
        ? !details.primaryVelocity.isNegative
        : details.primaryVelocity.isNegative;

    if (isInUpperSegment) {
      _controller.flingTo(_controller.suggestedUpperBound, velocity: _sign * velocity);
      return;
    }

    if (isInLowerSegment) {
      _controller.flingTo(_controller.suggestedLowerBound, velocity: _sign * velocity);
      return;
    }

    // inMiddleSegment
    // in the middle segment we will decide based on which direction we're moving
    // and if not at all, we will use absolute positioning
    // and if perfectly centered, we'll default to closed because fuck you
    if (isMovingHigher) {
      _controller.flingTo(_controller.suggestedUpperBound, velocity: _sign * velocity);
      return;
    }

    // the pointer is either not moving or moving to the lower bound
    _controller.flingTo(_controller.suggestedLowerBound, velocity: _sign * velocity);
    return;
  }

  Widget _defaultSheetAnimationBuilder(BuildContext context, Widget child) {
    return CustomSingleChildLayout(
      delegate: _HolySheetLayout(_controller.value, _sign),
      child: child,
    );
  }

  Widget _sheetAnimationBuilder(BuildContext context, Widget child) {
    return widget.animationBuilder != null
        ? widget.animationBuilder(context, child)
        : _defaultSheetAnimationBuilder(context, child);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: Container(
        key: _childKey,
        child: AnimatedBuilder(
          animation: widget.animationController,
          builder: _sheetAnimationBuilder,
          child: widget.builder(context),
        ),
      ),
    );
  }
}

class _HolySheetLayout extends SingleChildLayoutDelegate {
  _HolySheetLayout(this.progress, this.sign);

  final double progress;
  final double sign;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tight(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final tween = Tween(begin: -1 * sign * childSize.height, end: 0.0);

    return Offset(0.0, tween.transform(progress));
  }

  @override
  bool shouldRelayout(_HolySheetLayout oldDelegate) {
    return progress != oldDelegate.progress || sign != oldDelegate.sign;
  }
}
