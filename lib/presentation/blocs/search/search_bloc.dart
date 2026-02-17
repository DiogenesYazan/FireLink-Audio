import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/track.dart';
import '../../../domain/repositories/music_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

/// BLoC responsável pela busca de músicas no SoundCloud.
///
/// Usa [rxdart] para debounce de 500ms na digitação, evitando
/// chamadas excessivas à API.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required MusicRepository musicRepository})
    : _musicRepository = musicRepository,
      super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      // Debounce de 500ms: espera o usuário parar de digitar.
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .asyncExpand(mapper),
    );
    on<SearchCleared>(_onCleared);
  }

  final MusicRepository _musicRepository;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading, query: query));

    try {
      final tracks = await _musicRepository.searchTracks(query);
      emit(state.copyWith(status: SearchStatus.loaded, tracks: tracks));
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: 'Erro ao buscar: ${e.toString()}',
        ),
      );
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }
}
