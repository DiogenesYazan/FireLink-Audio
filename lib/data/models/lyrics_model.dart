import '../../domain/entities/lyrics.dart';

/// Modelo de dados para Lyrics com JSON parsing (lrclib.net).
class LyricsModel extends Lyrics {
  const LyricsModel({
    super.plainLyrics,
    super.syncedLyrics,
    super.instrumental,
    super.trackName,
    super.artistName,
  });

  /// Cria [LyricsModel] a partir da resposta JSON do lrclib.net.
  ///
  /// Formato esperado:
  /// ```json
  /// {
  ///   "trackName": "...",
  ///   "artistName": "...",
  ///   "instrumental": false,
  ///   "plainLyrics": "...",
  ///   "syncedLyrics": "[00:17.12] ..."
  /// }
  /// ```
  factory LyricsModel.fromJson(Map<String, dynamic> json) {
    return LyricsModel(
      trackName: json['trackName'] as String?,
      artistName: json['artistName'] as String?,
      instrumental: json['instrumental'] as bool? ?? false,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );
  }
}
