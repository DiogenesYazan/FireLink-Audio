import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../../domain/entities/track.dart';
import '../blocs/history/history_cubit.dart';
import '../blocs/liked_songs/liked_songs_cubit.dart';
import '../blocs/offline/offline_cubit.dart';
import '../blocs/offline/offline_state.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/playlist/playlist_cubit.dart';
import '../blocs/settings/settings_cubit.dart';
import '../widgets/gradient_background.dart';
import '../widgets/track_tile.dart';
import 'liked_songs_screen.dart';
import 'offline_tracks_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';

/// Tela de biblioteca com músicas curtidas, playlists, downloads e histórico.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: const Text('Biblioteca'),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  tooltip: 'Configurações',
                  onPressed: () {
                    context.read<SettingsCubit>().refreshCacheInfo();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<SettingsCubit>(),
                          child: const SettingsScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Músicas Curtidas Card ──
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

            // ── Downloads Card ──
            SliverToBoxAdapter(
              child: BlocBuilder<OfflineCubit, OfflineState>(
                builder: (context, state) {
                  final count = state.tracks.length;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<OfflineCubit>(),
                              child: BlocProvider.value(
                                value: context.read<PlayerBloc>(),
                                child: const OfflineTracksScreen(),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.lilac.withValues(alpha: .15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.lilac.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.download_done_rounded,
                                size: 28,
                                color: AppColors.lilac,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Downloads',
                                    style: TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$count ${count == 1 ? "música" : "músicas"}',
                                    style: const TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.onSurfaceVariant,
                              size: 16,
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

            // ── Suas Playlists ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Suas Playlists',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCreatePlaylistDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lilac.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: AppColors.lilac,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Criar',
                              style: TextStyle(
                                color: AppColors.lilac,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<PlaylistCubit, PlaylistState>(
                builder: (context, state) {
                  if (state.playlistNames.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: GestureDetector(
                        onTap: () => _showCreatePlaylistDialog(context),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.lilac.withValues(alpha: .1),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.playlist_add_rounded,
                                  color: AppColors.onSurfaceVariant.withValues(
                                    alpha: .5,
                                  ),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Crie sua primeira playlist',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: .7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.playlistNames.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final name = state.playlistNames[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value: context.read<PlaylistCubit>(),
                                    ),
                                    BlocProvider.value(
                                      value: context.read<PlayerBloc>(),
                                    ),
                                  ],
                                  child: PlaylistScreen(name: name),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.lilac.withValues(alpha: .12),
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.deepPurple.withValues(
                                          alpha: .6,
                                        ),
                                        AppColors.lilac.withValues(alpha: .4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.queue_music_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Playlist',
                                  style: TextStyle(
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
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Histórico Agrupado ──
            SliverToBoxAdapter(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, histState) {
                  if (histState.recentTracks.isEmpty) {
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

                  final grouped = context.read<HistoryCubit>().groupedHistory;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: grouped.entries.map((entry) {
                      return _HistorySection(
                        title: entry.key,
                        tracks: entry.value,
                        allTracks: histState.recentTracks,
                      );
                    }).toList(),
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

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Nova Playlist',
          style: TextStyle(color: AppColors.onSurface),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Nome da playlist',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lilac, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<PlaylistCubit>().createPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'Criar',
              style: TextStyle(
                color: AppColors.lilac,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seção do histórico agrupada (Hoje, Ontem, etc.).
class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.tracks,
    required this.allTracks,
  });

  final String title;
  final List<Track> tracks;
  final List<Track> allTracks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              _sectionIcon,
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lilac.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tracks.length}',
                  style: const TextStyle(
                    color: AppColors.lilac,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tracks.map(
          (track) => TrackTile(
            track: track,
            onTap: () {
              final startIndex = allTracks.indexOf(track);
              context.read<PlayerBloc>().add(
                PlayerQueueSet(
                  allTracks,
                  startIndex: startIndex >= 0 ? startIndex : 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget get _sectionIcon {
    switch (title) {
      case 'Hoje':
        return const Icon(
          Icons.today_rounded,
          color: AppColors.lilac,
          size: 18,
        );
      case 'Ontem':
        return const Icon(
          Icons.history_rounded,
          color: AppColors.onSurfaceVariant,
          size: 18,
        );
      case 'Esta semana':
        return const Icon(
          Icons.date_range_rounded,
          color: AppColors.onSurfaceVariant,
          size: 18,
        );
      default:
        return const Icon(
          Icons.access_time_rounded,
          color: AppColors.onSurfaceVariant,
          size: 18,
        );
    }
  }
}
