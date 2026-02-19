part of 'player_bloc.dart';

/// Eventos do PlayerBloc.
sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Seleciona e começa a reproduzir uma track.
class PlayerTrackSelected extends PlayerEvent {
  const PlayerTrackSelected(this.track);
  final Track track;

  @override
  List<Object?> get props => [track];
}

/// Alterna entre play e pause.
class PlayerPlayPauseToggled extends PlayerEvent {
  const PlayerPlayPauseToggled();
}

/// Faz seek para [position].
class PlayerSeeked extends PlayerEvent {
  const PlayerSeeked(this.position);
  final Duration position;

  @override
  List<Object?> get props => [position];
}

/// Pula para a próxima track na fila.
class PlayerNextRequested extends PlayerEvent {
  const PlayerNextRequested();
}

/// Volta para a track anterior na fila.
class PlayerPreviousRequested extends PlayerEvent {
  const PlayerPreviousRequested();
}

/// Define a fila de reprodução e inicia a partir de [startIndex].
class PlayerQueueSet extends PlayerEvent {
  const PlayerQueueSet(this.tracks, {this.startIndex = 0});
  final List<Track> tracks;
  final int startIndex;

  @override
  List<Object?> get props => [tracks, startIndex];
}

/// Altera o volume (0.0 – 1.0).
class PlayerVolumeChanged extends PlayerEvent {
  const PlayerVolumeChanged(this.volume);
  final double volume;

  @override
  List<Object?> get props => [volume];
}

class PlayerShuffleToggled extends PlayerEvent {
  const PlayerShuffleToggled();
}

class PlayerRepeatModeChanged extends PlayerEvent {
  const PlayerRepeatModeChanged();
}

// ── Eventos internos (disparados pelos streams do media_kit) ──

class _PlayerPositionUpdated extends PlayerEvent {
  const _PlayerPositionUpdated(this.position);
  final Duration position;
}

class _PlayerDurationReceived extends PlayerEvent {
  const _PlayerDurationReceived(this.duration);
  final Duration duration;
}

class _PlayerPlayingChanged extends PlayerEvent {
  const _PlayerPlayingChanged(this.playing);
  final bool playing;
}

class _PlayerCompleted extends PlayerEvent {
  const _PlayerCompleted();
}

/// Insere uma track na posição seguinte da fila.
class PlayerAddNext extends PlayerEvent {
  const PlayerAddNext(this.track);
  final Track track;

  @override
  List<Object?> get props => [track];
}

/// Adiciona uma track ao final da fila.
class PlayerAddToQueue extends PlayerEvent {
  const PlayerAddToQueue(this.track);
  final Track track;

  @override
  List<Object?> get props => [track];
}

/// Inicia uma "Rádio do Artista" — busca múltiplas tracks e monta a fila.
class PlayerArtistRadioStarted extends PlayerEvent {
  const PlayerArtistRadioStarted(this.artistName);
  final String artistName;

  @override
  List<Object?> get props => [artistName];
}
