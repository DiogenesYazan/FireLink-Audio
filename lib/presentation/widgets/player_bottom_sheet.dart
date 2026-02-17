import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/di/service_locator.dart';
import '../../config/theme/app_colors.dart';
import '../blocs/liked_songs/liked_songs_cubit.dart';
import '../blocs/lyrics/lyrics_cubit.dart';
import '../blocs/player/player_bloc.dart';
import 'lyrics_view.dart';
import 'queue_view.dart';
import 'seek_bar.dart';

/// Bottom sheet expansível com controles completos do player.
///
/// Exibe capa grande, título, artista, seek bar, controles de transporte
/// (previous, play/pause, next), volume e acesso a letras.
class PlayerBottomSheet extends StatelessWidget {
  const PlayerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            final track = state.currentTrack;
            if (track == null) return const SizedBox.shrink();

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  // Background blurred artwork.
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                        child: Opacity(
                          opacity: 0.3,
                          child: CachedNetworkImage(
                            imageUrl: track.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Overlay gradiente.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.midnightPurple.withValues(alpha: .6),
                            AppColors.background.withValues(alpha: .95),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Conteúdo.
                  SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Handle indicator.
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: .4,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Capa ───────────────────────────
                        Hero(
                          tag: 'player-artwork',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.midnightPurple.withValues(
                                      alpha: .6,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CachedNetworkImage(
                                imageUrl: track.thumbnailUrl,
                                width: MediaQuery.of(context).size.width * 0.75,
                                height:
                                    MediaQuery.of(context).size.width * 0.75,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  height:
                                      MediaQuery.of(context).size.width * 0.75,
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    size: 64,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  height:
                                      MediaQuery.of(context).size.width * 0.75,
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    size: 64,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Título e artista ───────────────
                        Text(
                          track.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                track.artist,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botão de like.
                            BlocBuilder<LikedSongsCubit, LikedSongsState>(
                              buildWhen: (prev, curr) =>
                                  prev.likedTrackIds != curr.likedTrackIds,
                              builder: (context, likedState) {
                                final isLiked = likedState.likedTrackIds
                                    .contains(track.trackId);
                                return IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked
                                        ? AppColors.lilac
                                        : AppColors.onSurfaceVariant,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    context.read<LikedSongsCubit>().toggleLike(
                                      track,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Seek bar ──────────────────────
                        SeekBar(
                          position: state.position,
                          duration: state.duration,
                          onChangeEnd: (pos) =>
                              context.read<PlayerBloc>().add(PlayerSeeked(pos)),
                        ),

                        const SizedBox(height: 16),

                        // ── Controles de transporte ───────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Shuffle
                            IconButton(
                              onPressed: () => context.read<PlayerBloc>().add(
                                const PlayerShuffleToggled(),
                              ),
                              icon: Icon(
                                Icons.shuffle_rounded,
                                size: 28,
                                color: state.shuffleEnabled
                                    ? AppColors.lilac
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Previous
                            IconButton(
                              onPressed: state.hasPrevious
                                  ? () => context.read<PlayerBloc>().add(
                                      const PlayerPreviousRequested(),
                                    )
                                  : null,
                              icon: Icon(
                                Icons.skip_previous_rounded,
                                size: 36,
                                color: state.hasPrevious
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceVariant.withValues(
                                        alpha: .4,
                                      ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Play / Pause (grande, com gradiente).
                            _BigPlayPauseButton(state: state),

                            const SizedBox(width: 16),

                            // Next
                            IconButton(
                              onPressed: state.hasNext
                                  ? () => context.read<PlayerBloc>().add(
                                      const PlayerNextRequested(),
                                    )
                                  : null,
                              icon: Icon(
                                Icons.skip_next_rounded,
                                size: 36,
                                color: state.hasNext
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceVariant.withValues(
                                        alpha: .4,
                                      ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Repeat
                            IconButton(
                              onPressed: () => context.read<PlayerBloc>().add(
                                const PlayerRepeatModeChanged(),
                              ),
                              icon: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    state.repeatMode == PlayerRepeatMode.one
                                        ? Icons.repeat_one_rounded
                                        : Icons.repeat_rounded,
                                    size: 28,
                                    color:
                                        state.repeatMode != PlayerRepeatMode.off
                                        ? AppColors.lilac
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Volume ────────────────────────
                        Row(
                          children: [
                            const Icon(
                              Icons.volume_down_rounded,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            Expanded(
                              child: Slider(
                                value: state.volume,
                                min: 0,
                                max: 1,
                                onChanged: (v) => context
                                    .read<PlayerBloc>()
                                    .add(PlayerVolumeChanged(v)),
                              ),
                            ),
                            const Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Botões de ações ───────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showQueue(context),
                              icon: const Icon(
                                Icons.queue_music_rounded,
                                color: AppColors.lilac,
                              ),
                              label: const Text(
                                'Fila',
                                style: TextStyle(color: AppColors.lilac),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: () => _showLyrics(context, track),
                              icon: const Icon(
                                Icons.lyrics_rounded,
                                color: AppColors.lilac,
                              ),
                              label: const Text(
                                'Letras',
                                style: TextStyle(color: AppColors.lilac),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLyrics(BuildContext context, track) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) =>
            sl<LyricsCubit>()
              ..fetchLyrics(title: track.title, artist: track.artist),
        child: BlocProvider.value(
          value: context.read<PlayerBloc>(),
          child: const LyricsView(),
        ),
      ),
    );
  }

  void _showQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlayerBloc>(),
        child: const QueueView(),
      ),
    );
  }
}

/// Botão grande de play/pause com gradiente.
class _BigPlayPauseButton extends StatelessWidget {
  const _BigPlayPauseButton({required this.state});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == PlayerStatus.loading;
    final isPlaying = state.isPlaying;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () =>
                context.read<PlayerBloc>().add(const PlayerPlayPauseToggled()),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.lilac.withValues(alpha: .4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
        ),
      ),
    );
  }
}
