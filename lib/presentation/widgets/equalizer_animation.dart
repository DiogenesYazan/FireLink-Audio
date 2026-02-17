import 'dart:math';

import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// Widget de animação de equalizer — 4 barras verticais que pulam.
///
/// Usado para indicar visualmente que uma track está tocando.
class EqualizerAnimation extends StatefulWidget {
  const EqualizerAnimation({
    super.key,
    this.isPlaying = true,
    this.color = AppColors.lilac,
    this.barWidth = 3.0,
    this.spacing = 2.0,
  });

  final bool isPlaying;
  final Color color;
  final double barWidth;
  final double spacing;

  @override
  State<EqualizerAnimation> createState() => _EqualizerAnimationState();
}

class _EqualizerAnimationState extends State<EqualizerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  final List<double> _heights = [0.3, 0.6, 0.4, 0.8];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(_updateHeights);

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(EqualizerAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        // Reset para alturas baixas quando pausado.
        setState(() {
          for (int i = 0; i < _heights.length; i++) {
            _heights[i] = 0.2;
          }
        });
      }
    }
  }

  void _updateHeights() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _heights.length; i++) {
        // Gera altura aleatória entre 0.2 e 1.0.
        _heights[i] = 0.2 + _random.nextDouble() * 0.8;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (widget.barWidth * 4) + (widget.spacing * 3),
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: widget.barWidth,
            height: 16 * _heights[index],
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.barWidth / 2),
            ),
          );
        }),
      ),
    );
  }
}
