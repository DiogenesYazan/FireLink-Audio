part of 'search_bloc.dart';

/// Eventos do SearchBloc.
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Query de busca alterada pelo usuário (com debounce embutido).
class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Limpa os resultados da busca.
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
