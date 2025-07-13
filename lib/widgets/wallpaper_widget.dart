import 'package:flutter/material.dart';
import 'dart:math' as math;

class WallpaperWidget extends StatelessWidget {
  final Widget child;
  final String? imagePath;
  final Color? overlayColor;
  final double opacity;

  const WallpaperWidget({
    super.key,
    required this.child,
    this.imagePath,
    this.overlayColor,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: Transform.rotate(
              angle: math.pi / 2, // 90 degrees
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                color: overlayColor?.withOpacity(opacity),
                colorBlendMode: overlayColor != null ? BlendMode.overlay : null,
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
        ),
      ),
      child: child,
    );
  }
}
