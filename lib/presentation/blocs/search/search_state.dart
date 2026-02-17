part of 'search_bloc.dart';

/// Status da busca.
enum SearchStatus { initial, loading, loaded, error }

/// Estado do SearchBloc.
class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.tracks = const [],
    this.query = '',
    this.errorMessage,
  });

  final SearchStatus status;
  final List<Track> tracks;
  final String query;
  final String? errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    List<Track>? tracks,
    String? query,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tracks, query, errorMessage];
}
