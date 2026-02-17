import '../../domain/entities/track.dart';

/// Modelo de dados para Track, com factories de conversão.
class TrackModel extends Track {
  const TrackModel({
    required super.trackId,
    required super.title,
    required super.artist,
    required super.duration,
    required super.thumbnailUrl,
    super.streamUrl,
  });

  /// Cria [TrackModel] a partir de um objeto track da API SoundCloud v2.
  ///
  /// SoundCloud retorna:
  /// ```json
  /// {
  ///   "id": 123456789,
  ///   "title": "Song Title",
  ///   "user": {"username": "Artist"},
  ///   "duration": 240000,
  ///   "artwork_url": "https://i1.sndcdn.com/.../large.jpg"
  /// }
  /// ```
  factory TrackModel.fromSoundCloud(Map<String, dynamic> json) {
    final id = json['id'];
    final trackId = id is int ? id.toString() : (id as String? ?? '');

    // Artwork: substitui -large por -t500x500 para alta resolução.
    String artworkUrl = json['artwork_url'] as String? ?? '';
    if (artworkUrl.isNotEmpty) {
      artworkUrl = artworkUrl.replaceAll('-large', '-t500x500');
    } else {
      // Fallback: avatar do usuário.
      final user = json['user'] as Map<String, dynamic>?;
      artworkUrl = user?['avatar_url'] as String? ?? '';
      if (artworkUrl.isNotEmpty) {
        artworkUrl = artworkUrl.replaceAll('-large', '-t500x500');
      }
    }

    final user = json['user'] as Map<String, dynamic>?;
    final durationMs = json['duration'] as int? ?? 0;

    return TrackModel(
      trackId: trackId,
      title: json['title'] as String? ?? 'Sem título',
      artist: user?['username'] as String? ?? 'Artista desconhecido',
      duration: Duration(milliseconds: durationMs),
      thumbnailUrl: artworkUrl,
    );
  }

  /// Cria [TrackModel] a partir de um mapa JSON (para cache/mock).
  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      trackId: json['trackId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      duration: Duration(milliseconds: json['durationMs'] as int),
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson() => {
    'trackId': trackId,
    'title': title,
    'artist': artist,
    'durationMs': duration.inMilliseconds,
    'thumbnailUrl': thumbnailUrl,
  };
}
