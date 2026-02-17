import 'package:equatable/equatable.dart';

import '../../../domain/entities/track.dart';

/// Status do carregamento de tracks da tela Home.
enum HomeStatus { loading, loaded, error }

/// Estado do [HomeCubit].
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.tracks = const [],
    this.genre = 'all-music',
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Track> tracks;
  final String genre;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Track>? tracks,
    String? genre,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      genre: genre ?? this.genre,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tracks, genre, errorMessage];
}
