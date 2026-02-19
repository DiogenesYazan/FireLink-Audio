import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/playlist/playlist_cubit.dart';
import '../widgets/gradient_background.dart';
import '../widgets/track_tile.dart';

/// Tela de detalhe de uma playlist.
///
/// Exibe a lista de tracks e permite reproduzir/remover.
class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // Carrega as tracks desta playlist ao abrir.
    context.read<PlaylistCubit>().loadPlaylistTracks(name);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(name),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // Botão para tocar todas.
            IconButton(
              icon: const Icon(
                Icons.play_circle_filled_rounded,
                color: AppColors.lilac,
                size: 32,
              ),
              tooltip: 'Reproduzir tudo',
              onPressed: () {
                final state = context.read<PlaylistCubit>().state;
                if (state.currentTracks.isNotEmpty) {
                  context.read<PlayerBloc>().add(
                    PlayerQueueSet(state.currentTracks, startIndex: 0),
                  );
                }
              },
            ),
            // Botão para deletar playlist.
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.onSurfaceVariant,
              ),
              color: AppColors.surface,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Excluir Playlist',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text(
                        'Excluir Playlist?',
                        style: TextStyle(color: AppColors.onSurface),
                      ),
                      content: Text(
                        'A playlist "$name" será excluída permanentemente.',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
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
                            context.read<PlaylistCubit>().deletePlaylist(name);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<PlaylistCubit, PlaylistState>(
          builder: (context, state) {
            if (state.currentTracks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.queue_music_rounded,
                      size: 64,
                      color: AppColors.onSurfaceVariant.withValues(alpha: .4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Playlist vazia',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Segure uma música para adicionar',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: state.currentTracks.length,
              itemBuilder: (context, index) {
                final track = state.currentTracks[index];
                return Dismissible(
                  key: Key(track.trackId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.redAccent.withValues(alpha: .2),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                  onDismissed: (_) {
                    context.read<PlaylistCubit>().removeTrack(
                      name,
                      track.trackId,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removida: ${track.title}'),
                        backgroundColor: AppColors.deepPurple,
                      ),
                    );
                  },
                  child: TrackTile(
                    track: track,
                    onTap: () {
                      context.read<PlayerBloc>().add(
                        PlayerQueueSet(state.currentTracks, startIndex: index),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
