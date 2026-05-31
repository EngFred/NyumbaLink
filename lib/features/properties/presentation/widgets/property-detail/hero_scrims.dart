import 'package:flutter/material.dart';

/// Top and bottom dark gradient scrims for the hero area.
///
/// Expands to fill its parent [Stack] as a non-positioned child, then
/// positions its two gradient overlays internally.
class HeroScrims extends StatelessWidget {
  const HeroScrims({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xBB000000), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xEE000000), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
