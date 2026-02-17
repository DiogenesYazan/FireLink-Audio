import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/music_repository.dart';
import 'home_state.dart';

/// Cubit responsável por carregar as tracks trending do SoundCloud.
///
/// Carrega automaticamente ao ser criado e permite trocar o gênero.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required MusicRepository musicRepository})
    : _musicRepository = musicRepository,
      super(const HomeState()) {
    loadTrending();
  }

  final MusicRepository _musicRepository;

  /// Carrega as tracks trending do SoundCloud para o [genre] dado.
  ///
  /// Se [genre] for null, mantém o gênero atual do state.
  Future<void> loadTrending({String? genre}) async {
    final targetGenre = genre ?? state.genre;

    emit(state.copyWith(status: HomeStatus.loading, genre: targetGenre));

    try {
      final tracks = await _musicRepository.getTrendingTracks(
        genre: targetGenre,
      );
      emit(state.copyWith(status: HomeStatus.loaded, tracks: tracks));
    } catch (e) {
      debugPrint('HomeCubit: Erro ao carregar trending: $e');
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Falha ao carregar trending: $e',
        ),
      );
    }
  }
}
