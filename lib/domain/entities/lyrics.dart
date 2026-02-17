import 'package:equatable/equatable.dart';

/// Entidade que representa letras de uma música.
class Lyrics extends Equatable {
  const Lyrics({
    this.plainLyrics,
    this.syncedLyrics,
    this.instrumental = false,
    this.trackName,
    this.artistName,
  });

  /// Letras em texto puro (sem timestamps).
  final String? plainLyrics;

  /// Letras sincronizadas no formato LRC (com timestamps `[mm:ss.cc]`).
  final String? syncedLyrics;

  /// Se a faixa é instrumental (sem letra).
  final bool instrumental;

  /// Nome da faixa (meta).
  final String? trackName;

  /// Nome do artista (meta).
  final String? artistName;

  /// Se há letras disponíveis (texto ou sincronizadas).
  bool get hasLyrics => plainLyrics != null || syncedLyrics != null;

  /// Se há letras sincronizadas disponíveis.
  bool get hasSyncedLyrics => syncedLyrics != null && syncedLyrics!.isNotEmpty;

  /// Parse das letras sincronizadas em uma lista de [LyricsLine].
  List<LyricsLine> get parsedSyncedLyrics {
    if (!hasSyncedLyrics) return [];

    final lines = <LyricsLine>[];
    final pattern = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]\s*(.*)');

    for (final line in syncedLyrics!.split('\n')) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final centis = match.group(3)!;
        final millis = centis.length == 2
            ? int.parse(centis) * 10
            : int.parse(centis);
        final text = match.group(4)?.trim() ?? '';

        lines.add(
          LyricsLine(
            timestamp: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: millis,
            ),
            text: text,
          ),
        );
      }
    }

    return lines;
  }

  @override
  List<Object?> get props => [
    plainLyrics,
    syncedLyrics,
    instrumental,
    trackName,
    artistName,
  ];
}

/// Uma linha individual de letra sincronizada.
class LyricsLine {
  const LyricsLine({required this.timestamp, required this.text});

  /// Momento em que a linha deve ser exibida.
  final Duration timestamp;

  /// Texto da linha.
  final String text;
}
