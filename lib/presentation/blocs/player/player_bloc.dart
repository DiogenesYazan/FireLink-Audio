import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../domain/entities/track.dart';
import '../../../domain/repositories/music_repository.dart';

part 'player_event.dart';
part 'player_state.dart';

/// BLoC responsável pelo controle de reprodução de áudio.
///
/// Fluxo principal:
/// 1. Recebe [PlayerTrackSelected] ou [PlayerQueueSet]
/// 2. Resolve a URL de stream via [MusicRepository.getStreamUrl]
/// 3. Configura o [AudioPlayer] do just_audio
/// 4. Subscreve nos streams de posição, duração e estado
/// 5. Emite [PlayerState] atualizado para a UI
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required MusicRepository musicRepository})
    : _musicRepository = musicRepository,
      _audioPlayer = AudioPlayer(),
      super(const PlayerState()) {
    // Registrar handlers.
    on<PlayerTrackSelected>(_onTrackSelected);
    on<PlayerPlayPauseToggled>(_onPlayPauseToggled);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerNextRequested>(_onNextRequested);
    on<PlayerPreviousRequested>(_onPreviousRequested);
    on<PlayerQueueSet>(_onQueueSet);
    on<PlayerVolumeChanged>(_onVolumeChanged);
    on<_PlayerPositionUpdated>(_onPositionUpdated);
    on<_PlayerDurationReceived>(_onDurationReceived);
    on<_PlayerPlaybackStateChanged>(_onPlaybackStateChanged);

    // Subscrever nos streams do AudioPlayer.
    _listenToAudioPlayer();
  }

  final MusicRepository _musicRepository;
  final AudioPlayer _audioPlayer;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Subscreve nos streams do just_audio para emitir eventos internos.
  void _listenToAudioPlayer() {
    _subscriptions.add(
      _audioPlayer.positionStream.listen((position) {
        add(_PlayerPositionUpdated(position));
      }),
    );

    _subscriptions.add(
      _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          add(_PlayerDurationReceived(duration));
        }
      }),
    );

    _subscriptions.add(
      _audioPlayer.playerStateStream.listen((playerState) {
        add(
          _PlayerPlaybackStateChanged(
            playerState.playing,
            playerState.processingState,
          ),
        );
      }),
    );
  }

  // ── Handlers ───────────────────────────────────────────

  Future<void> _onTrackSelected(
    PlayerTrackSelected event,
    Emitter<PlayerState> emit,
  ) async {
    // Para o player atual antes de trocar de faixa.
    // Sem isso, o MPV/media_kit falha ao trocar de fonte quando
    // o player ainda está no estado completed/playing.
    await _audioPlayer.stop();

    emit(
      state.copyWith(
        status: PlayerStatus.loading,
        currentTrack: event.track,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );

    try {
      // Resolve a URL de stream via SoundCloud API.
      final streamUrl = await _musicRepository.getStreamUrl(
        event.track.trackId,
      );

      debugPrint('PlayerBloc: Playing ${event.track.trackId} from $streamUrl');

      // Configura o AudioSource.
      // No mobile, inclui MediaItem tag para notificação de background.
      // No desktop, just_audio_background não está disponível.
      final isMobile =
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;

      final audioSource = isMobile
          ? AudioSource.uri(
              streamUrl,
              tag: MediaItem(
                id: event.track.trackId,
                title: event.track.title,
                artist: event.track.artist,
                artUri: Uri.parse(event.track.thumbnailUrl),
                duration: event.track.duration,
              ),
            )
          : AudioSource.uri(streamUrl);

      await _audioPlayer.setAudioSource(audioSource);

      await _audioPlayer.play();
    } catch (e, stackTrace) {
      debugPrint('PlayerBloc: Erro ao reproduzir ${event.track.trackId}: $e');
      debugPrint('$stackTrace');
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'Falha ao reproduzir: ${e.toString()}',
        ),
      );
    }
  }

  void _onPlayPauseToggled(
    PlayerPlayPauseToggled event,
    Emitter<PlayerState> emit,
  ) {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _onSeeked(PlayerSeeked event, Emitter<PlayerState> emit) {
    _audioPlayer.seek(event.position);
  }

  Future<void> _onNextRequested(
    PlayerNextRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (!state.hasNext) return;

    final nextIndex = state.queueIndex + 1;
    final nextTrack = state.queue[nextIndex];
    emit(state.copyWith(queueIndex: nextIndex));
    add(PlayerTrackSelected(nextTrack));
  }

  Future<void> _onPreviousRequested(
    PlayerPreviousRequested event,
    Emitter<PlayerState> emit,
  ) async {
    // Se estamos a mais de 3 segundos, reinicia a track atual.
    if (state.position.inSeconds > 3) {
      _audioPlayer.seek(Duration.zero);
      return;
    }

    if (!state.hasPrevious) {
      _audioPlayer.seek(Duration.zero);
      return;
    }

    final prevIndex = state.queueIndex - 1;
    final prevTrack = state.queue[prevIndex];
    emit(state.copyWith(queueIndex: prevIndex));
    add(PlayerTrackSelected(prevTrack));
  }

  Future<void> _onQueueSet(
    PlayerQueueSet event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(queue: event.tracks, queueIndex: event.startIndex));
    add(PlayerTrackSelected(event.tracks[event.startIndex]));
  }

  void _onVolumeChanged(PlayerVolumeChanged event, Emitter<PlayerState> emit) {
    _audioPlayer.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  // ── Handlers internos ──────────────────────────────────

  void _onPositionUpdated(
    _PlayerPositionUpdated event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationReceived(
    _PlayerDurationReceived event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onPlaybackStateChanged(
    _PlayerPlaybackStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    // Ignora eventos de estado do player quando estamos carregando
    // uma nova faixa (download em progresso). O handler _onTrackSelected
    // cuidará de emitir o estado correto após o download.
    if (state.status == PlayerStatus.loading &&
        event.processingState != ProcessingState.ready) {
      return;
    }

    // Quando a track termina, pula para a próxima automaticamente.
    if (event.processingState == ProcessingState.completed) {
      if (state.hasNext) {
        add(const PlayerNextRequested());
      } else {
        emit(
          state.copyWith(status: PlayerStatus.paused, position: Duration.zero),
        );
      }
      return;
    }

    final status = switch (event.processingState) {
      ProcessingState.loading ||
      ProcessingState.buffering => PlayerStatus.loading,
      ProcessingState.ready =>
        event.playing ? PlayerStatus.playing : PlayerStatus.paused,
      _ => state.status,
    };

    emit(state.copyWith(status: status));
  }

  @override
  Future<void> close() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    await _audioPlayer.dispose();
    return super.close();
  }
}
