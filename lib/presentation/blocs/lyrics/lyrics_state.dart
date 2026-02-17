part of 'lyrics_cubit.dart';

/// Status da busca de letras.
enum LyricsStatus { initial, loading, loaded, notFound, error }

/// Estado do LyricsCubit.
class LyricsState extends Equatable {
  const LyricsState({
    this.status = LyricsStatus.initial,
    this.lyrics,
    this.errorMessage,
  });

  final LyricsStatus status;
  final Lyrics? lyrics;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, lyrics, errorMessage];
}
