import 'package:flutter/material.dart';

class AppAnimations {
  static Duration defaultDuration = Duration(milliseconds: 300);
  static Duration longDuration = Duration(milliseconds: 500);

  static Widget fadeSlideIn({
    required Widget child,
    required Animation<double> animation,
    double startOffset = 30.0,
    bool horizontal = false,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: horizontal ? Offset(startOffset / 100, 0) : Offset(0, startOffset / 100),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget scaleInOut({
    required Widget child,
    required AnimationController controller,
  }) {
    final Animation<double> scaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));

    return ScaleTransition(
      scale: scaleAnim,
      child: FadeTransition(
        opacity: controller,
        child: child,
      ),
    );
  }

  static Widget listItemAnimation({
    required Widget child,
    required int index,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double delay = index * 0.1;
        final double start = 0.0 + delay;
        final double end = 1.0;

        final Animation<double> curvedAnimation = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return Transform.translate(
          offset: Offset(0, 20 * (1 - curvedAnimation.value)),
          child: Opacity(
            opacity: curvedAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget shimmerLoading({
    required Widget child,
    required bool isLoading,
  }) {
    if (!isLoading) return child;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment(-1.0, -0.3),
          end: Alignment(1.0, 0.3),
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}
