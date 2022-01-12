library animated_gesture_detector;

import 'package:flutter/material.dart';

/// Gesture detector but with size in/out animation
class AnimatedGestureDetector extends StatefulWidget {
  /// Creates a gesture detector with animated size in/out when user interact with it
  const AnimatedGestureDetector({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 120),
    this.onTap,
    this.onLongPress,
    this.isLongPressEnd = false,
    this.onLongPressEnd,
    this.onLongTapStart,
    this.scaleStrength = .1,
    this.makeBigger = false,
  }) : super(key: key);

  /// On user Tap
  final VoidCallback? onTap;

  /// On user long Tap
  final VoidCallback? onLongPress;

  /// On long press end
  final VoidCallback? onLongPressEnd;

  /// On long press start
  final VoidCallback? onLongTapStart;

  /// Widget inside button
  final Widget child;

  /// Duration of resize animation
  final Duration duration;

  /// Is onLongTap should be called when user still hold the button
  final bool isLongPressEnd;

  /// How much button should be resized
  final double scaleStrength;

  /// Is button become bigger when user tap it
  final bool makeBigger;

  @override
  _AnimatedGestureDetectorState createState() =>
      _AnimatedGestureDetectorState();
}

class _AnimatedGestureDetectorState extends State<AnimatedGestureDetector>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _animate;

  @override
  void initState() {
    _animate = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        upperBound: widget.scaleStrength)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = widget.makeBigger ? (1 + _animate.value) : (1 - _animate.value);
    return Listener(
      onPointerUp: (_) => onLongTapEnd(),
      child: GestureDetector(
        onTap: _onTap,
        onLongPress: _onLongPress,
        onTapDown: (_) => onLongTapStart(),
        onLongPressEnd: (_) => onLongTapEnd(),
        onLongPressCancel: onLongTapCancel,
        child: Transform.scale(
          scale: _scale,
          child: Container(
            color: Colors.transparent,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _onTap() {
    if (!_animate.isAnimating) _animate.forward();

    Future.delayed(widget.duration, () {
      if (widget.onLongPressEnd != null) widget.onLongPressEnd!();
      _animate.reverse();

      if (widget.onTap != null) widget.onTap!();
    });
  }

  void _onLongPress() {
    Future.delayed(widget.duration, () {
      if (widget.isLongPressEnd) _animate.reverse();

      if (widget.onLongPress != null) widget.onLongPress!();
    });
  }

  void onLongTapStart() {
    if (widget.onLongTapStart != null) widget.onLongTapStart!();
    if (!_animate.isAnimating) _animate.forward();
  }

  void onLongTapEnd() {
    if (widget.onLongPressEnd != null) widget.onLongPressEnd!();
    if (mounted) _animate.reverse();
  }

  void onLongTapCancel() {
    if (mounted) _animate.reverse();
  }
}