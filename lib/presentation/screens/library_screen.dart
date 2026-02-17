import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/history/history_cubit.dart';
import '../blocs/liked_songs/liked_songs_cubit.dart';
import '../blocs/player/player_bloc.dart';
import '../widgets/gradient_background.dart';
import 'liked_songs_screen.dart';

/// Tela de biblioteca com músicas curtidas e histórico.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Text('Biblioteca'),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Músicas Curtidas Card.
            SliverToBoxAdapter(
              child: BlocBuilder<LikedSongsCubit, LikedSongsState>(
                builder: (context, state) {
                  final count = state.likedTracks.length;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<LikedSongsCubit>(),
                              child: BlocProvider.value(
                                value: context.read<PlayerBloc>(),
                                child: const LikedSongsScreen(),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lilac.withValues(alpha: .3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Músicas Curtidas',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$count ${count == 1 ? "música" : "músicas"}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: .8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tocadas Recentemente Header.
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Tocadas Recentemente',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Tocadas Recentemente Grid.
            SliverToBoxAdapter(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  if (state.recentTracks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Nenhuma música ouvida ainda',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  // Mostra até 6 itens.
                  final displayed = state.recentTracks.take(6).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.6,
                          ),
                      itemCount: displayed.length,
                      itemBuilder: (context, index) {
                        final track = displayed[index];
                        return GestureDetector(
                          onTap: () {
                            // Toca a partir do histórico.
                            context.read<PlayerBloc>().add(
                              PlayerQueueSet(
                                state.recentTracks,
                                startIndex: index,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(8),
                                  ),
                                  child: SizedBox(
                                    width: 64,
                                    height: double.infinity,
                                    child: CachedNetworkImage(
                                      imageUrl: track.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: AppColors.surfaceVariant,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: AppColors.surfaceVariant,
                                            child: const Icon(
                                              Icons.music_note_rounded,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    track.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
