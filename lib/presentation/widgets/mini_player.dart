import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/player/player_bloc.dart';
import 'player_bottom_sheet.dart';

/// Mini player fixo exibido acima do BottomNavigationBar.
///
/// Mostra thumbnail, título, artista e botão play/pause.
/// Ao tocar, expande o [PlayerBottomSheet] com controles completos.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (prev, curr) =>
          prev.currentTrack != curr.currentTrack ||
          prev.status != curr.status ||
          prev.position != curr.position ||
          prev.duration != curr.duration,
      builder: (context, state) {
        if (state.currentTrack == null || state.status == PlayerStatus.idle) {
          return const SizedBox.shrink();
        }

        final track = state.currentTrack!;
        final progress = state.duration.inMilliseconds > 0
            ? state.position.inMilliseconds / state.duration.inMilliseconds
            : 0.0;

        return GestureDetector(
          onTap: () => _showPlayerSheet(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.midnightPurple.withValues(alpha: .5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra de progresso no topo.
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.lilac,
                    ),
                    minHeight: 2,
                  ),
                ),

                // Conteúdo.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Thumbnail.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: CachedNetworkImage(
                            imageUrl: track.thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: AppColors.surfaceVariant),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.music_note_rounded,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Título e artista.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Botões de controle.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PlayPauseButton(state: state),
                          // Next button (se houver próxima).
                          if (state.hasNext)
                            IconButton(
                              icon: const Icon(
                                Icons.skip_next_rounded,
                                color: AppColors.onSurface,
                                size: 24,
                              ),
                              onPressed: () {
                                context.read<PlayerBloc>().add(
                                  const PlayerNextRequested(),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlayerBloc>(),
        child: const PlayerBottomSheet(),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.state});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == PlayerStatus.loading;
    final isPlaying = state.isPlaying;

    return IconButton(
      onPressed: isLoading
          ? null
          : () =>
                context.read<PlayerBloc>().add(const PlayerPlayPauseToggled()),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.lilac,
              ),
            )
          : Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.onSurface,
              size: 28,
            ),
    );
  }
}
