import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/liked_songs/liked_songs_cubit.dart';
import '../blocs/player/player_bloc.dart';
import '../widgets/gradient_background.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/track_tile.dart';

/// Tela com a lista completa de músicas curtidas.
///
/// Permite tocar tudo (shuffle) e remover músicas curtidas.
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Músicas Curtidas'),
          actions: [
            // Botão shuffle play all.
            BlocBuilder<LikedSongsCubit, LikedSongsState>(
              builder: (context, state) {
                if (state.likedTracks.isEmpty) return const SizedBox.shrink();

                return IconButton(
                  icon: const Icon(
                    Icons.shuffle_rounded,
                    color: AppColors.lilac,
                  ),
                  tooltip: 'Tocar tudo (aleatório)',
                  onPressed: () {
                    // Ativa shuffle e toca a lista de curtidas.
                    final tracks = state.likedTracks;
                    context.read<PlayerBloc>().add(
                      PlayerQueueSet(tracks, startIndex: 0),
                    );
                    context.read<PlayerBloc>().add(
                      const PlayerShuffleToggled(),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<LikedSongsCubit, LikedSongsState>(
            builder: (context, state) {
              return switch (state.status) {
                LikedSongsStatus.initial ||
                LikedSongsStatus.loading => const ShimmerLoading(),
                LikedSongsStatus.error => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'Erro desconhecido',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<LikedSongsCubit>().loadLikedSongs();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
                LikedSongsStatus.loaded =>
                  state.likedTracks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 64,
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: .4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhuma música curtida ainda',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Curta músicas pressionando ♡',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            // Header com contador.
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                child: Text(
                                  '${state.likedTracks.length} ${state.likedTracks.length == 1 ? "música" : "músicas"}',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Lista de tracks.
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final track = state.likedTracks[index];
                                return BlocBuilder<PlayerBloc, PlayerState>(
                                  buildWhen: (prev, curr) =>
                                      prev.currentTrack?.trackId !=
                                      curr.currentTrack?.trackId,
                                  builder: (context, playerState) {
                                    final isPlaying =
                                        playerState.currentTrack?.trackId ==
                                        track.trackId;
                                    return TrackTile(
                                      track: track,
                                      isPlaying: isPlaying,
                                      onTap: () {
                                        context.read<PlayerBloc>().add(
                                          PlayerQueueSet(
                                            state.likedTracks,
                                            startIndex: index,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }, childCount: state.likedTracks.length),
                            ),

                            const SliverToBoxAdapter(
                              child: SizedBox(height: 100),
                            ),
                          ],
                        ),
              };
            },
          ),
        ),
      ),
    );
  }
}
