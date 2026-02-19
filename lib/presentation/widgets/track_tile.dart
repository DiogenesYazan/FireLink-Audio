import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../domain/entities/track.dart';
import '../blocs/liked_songs/liked_songs_cubit.dart';
import '../blocs/offline/offline_cubit.dart';
import '../blocs/offline/offline_state.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/playlist/playlist_cubit.dart';
import 'equalizer_animation.dart';

/// Tile de uma track para listas (busca, home, fila).
///
/// Exibe thumbnail, título, artista e duração.
/// Long-press abre menu de contexto (Play Next, Add to Queue, Add to Playlist, Artist Radio).
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

  void _showContextMenu(BuildContext context) {
    // Captura BLoC references antes de abrir o modal.
    final playerBloc = context.read<PlayerBloc>();
    final playlistCubit = context.read<PlaylistCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: playerBloc),
          BlocProvider.value(value: playlistCubit),
        ],
        child: _TrackContextMenu(track: track),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: ListTile(
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
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing:
            trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          context.read<OfflineCubit>().removeTrack(
                            track.trackId,
                          );
                        } else {
                          context.read<OfflineCubit>().downloadTrack(track);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 4),
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
      ),
    );
  }
}

/// Menu de contexto completo do track.
class _TrackContextMenu extends StatelessWidget {
  const _TrackContextMenu({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar.
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withValues(alpha: .3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Track info header.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      track.thumbnailUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 48,
                        height: 48,
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.music_note,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.divider, height: 16),
            _ContextMenuItem(
              icon: Icons.playlist_play_rounded,
              label: 'Tocar Próxima',
              onTap: () {
                context.read<PlayerBloc>().add(PlayerAddNext(track));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Adicionada como próxima: ${track.title}'),
                    backgroundColor: AppColors.deepPurple,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _ContextMenuItem(
              icon: Icons.queue_music_rounded,
              label: 'Adicionar à Fila',
              onTap: () {
                context.read<PlayerBloc>().add(PlayerAddToQueue(track));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Adicionada à fila: ${track.title}'),
                    backgroundColor: AppColors.deepPurple,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _ContextMenuItem(
              icon: Icons.playlist_add_rounded,
              label: 'Adicionar à Playlist',
              onTap: () {
                Navigator.pop(context);
                _showPlaylistPicker(context, track);
              },
            ),
            _ContextMenuItem(
              icon: Icons.radio_rounded,
              label: 'Rádio do Artista',
              onTap: () {
                context.read<PlayerBloc>().add(
                  PlayerArtistRadioStarted(track.artist),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistPicker(BuildContext context, Track track) {
    final playlistCubit = context.read<PlaylistCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: playlistCubit,
        child: _PlaylistPickerSheet(track: track),
      ),
    );
  }
}

/// Sheet para escolher em qual playlist adicionar.
class _PlaylistPickerSheet extends StatelessWidget {
  const _PlaylistPickerSheet({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Adicionar à Playlist',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),
                // Criar nova playlist.
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lilac.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.lilac,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Criar Nova Playlist',
                    style: TextStyle(
                      color: AppColors.lilac,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateAndAdd(context, track);
                  },
                ),
                // Playlists existentes.
                if (state.playlistNames.isNotEmpty) ...[
                  const Divider(color: AppColors.divider, height: 1),
                  ...state.playlistNames.map(
                    (name) => ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.queue_music_rounded,
                          color: AppColors.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        context.read<PlaylistCubit>().addTrackToPlaylist(
                          name,
                          track,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Adicionada a "$name": ${track.title}',
                            ),
                            backgroundColor: AppColors.deepPurple,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateAndAdd(BuildContext context, Track track) {
    final controller = TextEditingController();
    final playlistCubit = context.read<PlaylistCubit>();

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
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await playlistCubit.createPlaylist(name);
                await playlistCubit.addTrackToPlaylist(name, track);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Playlist "$name" criada com ${track.title}',
                      ),
                      backgroundColor: AppColors.deepPurple,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Criar e Adicionar',
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

/// Item do menu de contexto do track.
class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.lilac, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: AppColors.surfaceVariant,
    );
  }
}
