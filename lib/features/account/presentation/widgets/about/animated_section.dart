import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSection extends StatelessWidget {
  const AnimatedSection({super.key, required this.child, this.delay = 0});
  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
