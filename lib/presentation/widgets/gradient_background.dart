import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// Container com gradiente roxo para backgrounds.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child, this.gradient});

  final Widget child;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.backgroundGradient,
      ),
      child: child,
    );
  }
}
