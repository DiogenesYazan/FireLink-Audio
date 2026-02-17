import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/track.dart';
import '../../../domain/repositories/liked_songs_repository.dart';

part 'liked_songs_state.dart';

/// Cubit para gerenciar músicas curtidas.
///
/// Singleton global — compartilhado por todas as telas.
class LikedSongsCubit extends Cubit<LikedSongsState> {
  LikedSongsCubit({required LikedSongsRepository likedSongsRepository})
    : _likedSongsRepository = likedSongsRepository,
      super(const LikedSongsState()) {
    loadLikedSongs();
  }

  final LikedSongsRepository _likedSongsRepository;

  /// Carrega as músicas curtidas do storage.
  Future<void> loadLikedSongs() async {
    emit(state.copyWith(status: LikedSongsStatus.loading));

    try {
      final tracks = await _likedSongsRepository.getLikedTracks();
      final ids = tracks.map((t) => t.trackId).toSet();

      emit(
        state.copyWith(
          status: LikedSongsStatus.loaded,
          likedTracks: tracks,
          likedTrackIds: ids,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LikedSongsStatus.error,
          errorMessage: 'Erro ao carregar músicas curtidas: $e',
        ),
      );
    }
  }

  /// Adiciona ou remove uma track da lista de curtidas.
  Future<void> toggleLike(Track track) async {
    try {
      final wasLiked = await _likedSongsRepository.toggleLike(track);

      // Atualiza estado local.
      final updatedIds = Set<String>.from(state.likedTrackIds);
      final updatedTracks = List<Track>.from(state.likedTracks);

      if (wasLiked) {
        // Foi curtido — adiciona.
        updatedIds.add(track.trackId);
        updatedTracks.insert(0, track);
      } else {
        // Foi descurtido — remove.
        updatedIds.remove(track.trackId);
        updatedTracks.removeWhere((t) => t.trackId == track.trackId);
      }

      emit(
        state.copyWith(likedTracks: updatedTracks, likedTrackIds: updatedIds),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao curtir música: $e'));
    }
  }

  /// Verifica se uma track está curtida.
  bool isLiked(String trackId) {
    return state.likedTrackIds.contains(trackId);
  }
}
