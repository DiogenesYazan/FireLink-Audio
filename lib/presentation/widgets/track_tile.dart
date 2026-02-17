import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../domain/entities/track.dart';

/// Tile de uma track para listas (busca, home, fila).
///
/// Exibe thumbnail, título, artista e duração.
class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    this.onTap,
    this.trailing,
    this.isPlaying = false,
  });

  final Track track;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: CachedNetworkImage(
            imageUrl: track.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(
                Icons.music_note_rounded,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            errorWidget: (_, _, _) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(
                Icons.music_note_rounded,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying ? AppColors.lilac : AppColors.onSurface,
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
      ),
      trailing:
          trailing ??
          Text(
            formatDuration(track.duration),
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
      onTap: onTap,
    );
  }
}
