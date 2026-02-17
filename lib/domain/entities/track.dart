import 'package:equatable/equatable.dart';

/// Entidade que representa uma track de áudio.
///
/// Contém metadados obtidos do SoundCloud
/// e, opcionalmente, a URL de stream já resolvida.
class Track extends Equatable {
  const Track({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.duration,
    required this.thumbnailUrl,
    this.streamUrl,
  });

  /// ID da track no SoundCloud.
  final String trackId;

  /// Título da música.
  final String title;

  /// Nome do artista.
  final String artist;

  /// Duração total da track.
  final Duration duration;

  /// URL da thumbnail (alta resolução).
  final String thumbnailUrl;

  /// URL do stream de áudio. Null antes de resolver via [MusicRepository].
  final Uri? streamUrl;

  /// Retorna cópia com [streamUrl] preenchida.
  Track copyWithStreamUrl(Uri url) => Track(
    trackId: trackId,
    title: title,
    artist: artist,
    duration: duration,
    thumbnailUrl: thumbnailUrl,
    streamUrl: url,
  );

  @override
  List<Object?> get props => [trackId, title, artist, duration, thumbnailUrl];
}
