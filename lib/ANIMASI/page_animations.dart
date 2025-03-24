import 'package:flutter/material.dart';

class PageAnimations {
  static Widget slideAnimation({
    required Widget child,
    required AnimationController controller,
    double startOffset = 100.0,
    bool horizontal = false,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: horizontal 
              ? Offset(startOffset * (1 - controller.value), 0)
              : Offset(0, startOffset * (1 - controller.value)),
          child: Opacity(
            opacity: controller.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget fadeAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    return FadeTransition(
      opacity: controller,
      child: child,
    );
  }

  static Widget scaleAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
      child: child,
    );
  }
}
