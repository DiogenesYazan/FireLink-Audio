import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/offline/offline_cubit.dart';
import '../blocs/offline/offline_state.dart';
import '../blocs/player/player_bloc.dart';
import '../widgets/gradient_background.dart';
import '../widgets/track_tile.dart';

/// Tela que lista as músicas baixadas para offline via [OfflineCubit].
class OfflineTracksScreen extends StatelessWidget {
  const OfflineTracksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Downloads'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<OfflineCubit, OfflineState>(
          builder: (context, state) {
            if (state.tracks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: AppColors.onSurfaceVariant.withValues(alpha: .5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma música baixada',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Baixe músicas para ouvir sem internet',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 120),
              itemCount: state.tracks.length,
              itemBuilder: (context, index) {
                final track = state.tracks[index];
                return TrackTile(
                  track: track,
                  onTap: () {
                    // Toca a lista de offline.
                    context.read<PlayerBloc>().add(
                      PlayerQueueSet(state.tracks, startIndex: index),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
