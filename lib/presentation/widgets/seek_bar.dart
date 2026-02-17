import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';

/// Barra de seek (progresso) do player.
///
/// Exibe posição atual, duração total e permite seek via drag.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
  });

  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final maxDuration = widget.duration.inMilliseconds.toDouble();
    final currentPosition =
        _dragValue ?? widget.position.inMilliseconds.toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.lilac,
            inactiveTrackColor: AppColors.surfaceVariant,
            thumbColor: AppColors.lilac,
            overlayColor: AppColors.lilac.withValues(alpha: .2),
          ),
          child: Slider(
            min: 0,
            max: maxDuration > 0 ? maxDuration : 1,
            value: currentPosition.clamp(0, maxDuration > 0 ? maxDuration : 1),
            onChanged: (value) {
              setState(() => _dragValue = value);
              widget.onChanged?.call(Duration(milliseconds: value.toInt()));
            },
            onChangeEnd: (value) {
              setState(() => _dragValue = null);
              widget.onChangeEnd?.call(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(
                  _dragValue != null
                      ? Duration(milliseconds: _dragValue!.toInt())
                      : widget.position,
                ),
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                formatDuration(widget.duration),
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
