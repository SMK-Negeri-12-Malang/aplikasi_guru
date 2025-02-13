import 'package:flutter/material.dart';
import '../utils/animations.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationController controller;
  final VoidCallback? onTap;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppAnimations.listItemAnimation(
      index: index,
      controller: controller,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
