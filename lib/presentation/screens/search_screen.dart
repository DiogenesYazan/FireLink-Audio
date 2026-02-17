import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/search/search_bloc.dart';
import '../widgets/gradient_background.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/track_tile.dart';

/// Tela de busca de músicas.
///
/// Barra de pesquisa com debounce que consulta o SoundCloud
/// via [SearchBloc] e exibe resultados como lista de [TrackTile].
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // ── Barra de busca ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (query) {
                  context.read<SearchBloc>().add(SearchQueryChanged(query));
                },
                style: const TextStyle(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'O que você quer ouvir?',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: BlocBuilder<SearchBloc, SearchState>(
                    buildWhen: (prev, curr) => prev.query != curr.query,
                    builder: (context, state) {
                      if (state.query.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchBloc>().add(const SearchCleared());
                          _focusNode.unfocus();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Resultados ─────────────────────────────
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return switch (state.status) {
                    SearchStatus.initial => _buildInitialView(),
                    SearchStatus.loading => const ShimmerLoading(),
                    SearchStatus.loaded => _buildResults(context, state),
                    SearchStatus.error => _buildError(state),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: .4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Busque por músicas, artistas\nou álbuns',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchState state) {
    if (state.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 48,
              color: AppColors.onSurfaceVariant.withValues(alpha: .5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado para "${state.query}"',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: state.tracks.length,
      itemBuilder: (context, index) {
        final track = state.tracks[index];
        return BlocBuilder<PlayerBloc, PlayerState>(
          buildWhen: (prev, curr) =>
              prev.currentTrack?.trackId != curr.currentTrack?.trackId,
          builder: (context, playerState) {
            return TrackTile(
              track: track,
              isPlaying: playerState.currentTrack?.trackId == track.trackId,
              onTap: () {
                // Define a fila com todos os resultados e inicia na posição.
                context.read<PlayerBloc>().add(
                  PlayerQueueSet(state.tracks, startIndex: index),
                );
                // Remove foco da busca.
                _focusNode.unfocus();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildError(SearchState state) {
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
                if (state.query.isNotEmpty) {
                  context.read<SearchBloc>().add(
                    SearchQueryChanged(state.query),
                  );
                }
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
