import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../domain/entities/track.dart';
import '../blocs/liked_songs/liked_songs_cubit.dart';
import '../blocs/offline/offline_cubit.dart';
import '../blocs/offline/offline_state.dart';
import 'equalizer_animation.dart';

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
      leading: Stack(
        children: [
          ClipRRect(
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
          // Overlay de equalizer quando está tocando.
          if (isPlaying)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lilac.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: EqualizerAnimation()),
              ),
            ),
        ],
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão de like.
              BlocBuilder<LikedSongsCubit, LikedSongsState>(
                builder: (context, state) {
                  final isLiked = state.likedTrackIds.contains(track.trackId);
                  return IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked
                          ? AppColors.lilac
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () {
                      context.read<LikedSongsCubit>().toggleLike(track);
                    },
                  );
                },
              ),
              // Botão de download offline.
              BlocBuilder<OfflineCubit, OfflineState>(
                builder: (context, state) {
                  final isDownloaded = state.isOffline(track.trackId);
                  final isDownloading = state.isDownloading(track.trackId);

                  if (isDownloading) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.lilac,
                        ),
                      ),
                    );
                  }

                  return IconButton(
                    icon: Icon(
                      isDownloaded
                          ? Icons.download_done_rounded
                          : Icons.download_rounded,
                      color: isDownloaded
                          ? AppColors.lilac
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () {
                      if (isDownloaded) {
                        context.read<OfflineCubit>().removeTrack(track.trackId);
                      } else {
                        context.read<OfflineCubit>().downloadTrack(track);
                      }
                    },
                  );
                },
              ),
              const SizedBox(width: 4),
              // Duração.
              Text(
                formatDuration(track.duration),
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
      onTap: onTap,
    );
  }
}
