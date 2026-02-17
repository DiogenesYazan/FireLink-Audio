import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/lyrics.dart';
import '../../../domain/repositories/lyrics_repository.dart';

part 'lyrics_state.dart';

/// Cubit para buscar e exibir letras de músicas.
///
/// Usa a API lrclib.net via [LyricsRepository] para buscar letras
/// em texto puro e/ou sincronizadas (formato LRC).
class LyricsCubit extends Cubit<LyricsState> {
  LyricsCubit({required LyricsRepository lyricsRepository})
    : _lyricsRepository = lyricsRepository,
      super(const LyricsState());

  final LyricsRepository _lyricsRepository;

  /// Busca letras para a música identificada por [title] e [artist].
  Future<void> fetchLyrics({
    required String title,
    required String artist,
  }) async {
    emit(const LyricsState(status: LyricsStatus.loading));

    try {
      final lyrics = await _lyricsRepository.getLyrics(title, artist);

      if (lyrics == null) {
        emit(const LyricsState(status: LyricsStatus.notFound));
        return;
      }

      if (lyrics.instrumental) {
        emit(LyricsState(status: LyricsStatus.loaded, lyrics: lyrics));
        return;
      }

      emit(LyricsState(status: LyricsStatus.loaded, lyrics: lyrics));
    } catch (e) {
      emit(
        LyricsState(
          status: LyricsStatus.error,
          errorMessage: 'Erro ao buscar letras: ${e.toString()}',
        ),
      );
    }
  }

  /// Reseta o estado para inicial.
  void reset() {
    emit(const LyricsState());
  }
}
