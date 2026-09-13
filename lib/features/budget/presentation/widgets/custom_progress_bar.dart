import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Gradient gradient;
  final Color backgroundColor;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    required this.gradient,
    this.backgroundColor = const Color(0xFF334155),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              width: constraints.maxWidth * clamped,
              height: height,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
