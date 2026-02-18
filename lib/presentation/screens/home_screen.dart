import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/di/service_locator.dart';
import '../../config/theme/app_colors.dart';
import '../blocs/history/history_cubit.dart';
import '../blocs/home/home_cubit.dart';
import '../blocs/home/home_state.dart';
import '../blocs/player/player_bloc.dart';
import '../widgets/gradient_background.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/track_tile.dart';

/// Gêneros disponíveis no SoundCloud para filtro de charts.
const _genres = <String, String>{
  'all-music': 'Tudo',
  'pop': 'Pop',
  'electronic': 'Eletrônica',
  'hiphoprap': 'Hip-Hop',
  'rbsoul': 'R&B',
  'rock': 'Rock',
  'latin': 'Latin',
  'danceedm': 'Dance/EDM',
  'country': 'Country',
  'reggae': 'Reggae',
};

/// Tela inicial com músicas trending do SoundCloud.
///
/// Exibe chips de gênero e uma lista de tracks populares.
/// Ao tocar em uma track, inicia a reprodução e define a fila.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── AppBar ─────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('FireLink Audio'),
                ],
              ),
            ),

            // ── Seção: Boas vindas ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ── Seção: Genre chips ─────────────────────
            SliverToBoxAdapter(
              child: BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (prev, curr) => prev.genre != curr.genre,
                builder: (context, state) {
                  return SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _genres.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final entry = _genres.entries.elementAt(index);
                        final isSelected = state.genre == entry.key;
                        return ChoiceChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (_) {
                            context.read<HomeCubit>().loadTrending(
                              genre: entry.key,
                            );
                          },
                          selectedColor: AppColors.lilac,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.lilac
                                : AppColors.lilac.withValues(alpha: .2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // ── Seção: Tocadas Recentemente ──────────
            SliverToBoxAdapter(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, historyState) {
                  if (historyState.recentTracks.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final displayed = historyState.recentTracks.take(5).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: AppColors.lilac,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tocadas Recentemente',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 132,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: displayed.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final track = displayed[index];
                            return GestureDetector(
                              onTap: () {
                                context.read<PlayerBloc>().add(
                                  PlayerQueueSet(
                                    historyState.recentTracks,
                                    startIndex: index,
                                  ),
                                );
                              },
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 120,
                                        height: 80,
                                        child: CachedNetworkImage(
                                          imageUrl: track.thumbnailUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: AppColors.surface,
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: AppColors.surfaceVariant,
                                                child: const Icon(
                                                  Icons.music_note_rounded,
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Seção: Trending header ────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.lilac,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Trending agora',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Lista de tracks trending ───────────────
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return switch (state.status) {
                  HomeStatus.loading => const SliverFillRemaining(
                    child: ShimmerLoading(),
                  ),
                  HomeStatus.error => SliverFillRemaining(
                    child: _buildError(context, state),
                  ),
                  HomeStatus.loaded =>
                    state.tracks.isEmpty
                        ? const SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'Nenhuma track encontrada',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final track = state.tracks[index];
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
                                          state.tracks,
                                          startIndex: index,
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }, childCount: state.tracks.length),
                          ),
                };
              },
            ),

            // Espaço para o mini player.
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Widget _buildError(BuildContext context, HomeState state) {
    return Center(
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
              state.errorMessage ?? 'Erro ao carregar tracks',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeCubit>().loadTrending();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
