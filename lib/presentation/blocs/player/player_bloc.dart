import 'dart:async';
import 'dart:math' show Random;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart' as mk;

import '../../../config/di/service_locator.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/repositories/music_repository.dart';
import '../history/history_cubit.dart';
import '../theme/dynamic_theme_cubit.dart';

part 'player_event.dart';
part 'player_state.dart';

/// BLoC responsável pelo controle de reprodução de áudio.
///
/// **Configuração Final (Win):**
/// Player: [media_kit] (MPV) - Robusto e suporta tudo.
/// Source: Arquivo Local MP4 (baixado pelo [YoutubeDataSource]).
///
/// Isso combina a estabilidade do arquivo local com a potência do MPV.
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required MusicRepository musicRepository})
    : _musicRepository = musicRepository,
      _player = mk.Player(
        configuration: const mk.PlayerConfiguration(
          // Mantendo configuração padrão (osc=true) ou ajustando se necessário.
          // Como vamos tocar um ARQUIVO, osc=false é mais seguro pra audio-only app.
          osc: false,
          // vo: 'null', // Removemos 'vo: null' caso o usuário queira ver o vídeo,
          // ou o MPV precise de output para não crashar certos codecs.
          // Se der erro de janela, voltamos com vo: null.
          logLevel: mk.MPVLogLevel.warn,
        ),
      ),
      super(const PlayerState()) {
    // Registrar handlers.
    on<PlayerTrackSelected>(_onTrackSelected);
    on<PlayerPlayPauseToggled>(_onPlayPauseToggled);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerNextRequested>(_onNextRequested);
    on<PlayerPreviousRequested>(_onPreviousRequested);
    on<PlayerQueueSet>(_onQueueSet);
    on<PlayerVolumeChanged>(_onVolumeChanged);
    on<PlayerShuffleToggled>(_onShuffleToggled);
    on<PlayerRepeatModeChanged>(_onRepeatModeChanged);
    on<_PlayerPositionUpdated>(_onPositionUpdated);
    on<_PlayerDurationReceived>(_onDurationReceived);
    on<_PlayerPlayingChanged>(_onPlayingChanged);
    on<_PlayerCompleted>(_onCompleted);
    on<PlayerAddNext>(_onAddNext);
    on<PlayerAddToQueue>(_onAddToQueue);
    on<PlayerArtistRadioStarted>(_onArtistRadio);

    // Subscrever nos streams do media_kit Player.
    _listenToPlayer();
  }

  final MusicRepository _musicRepository;
  final mk.Player _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Subscreve nos streams do media_kit para emitir eventos internos.
  void _listenToPlayer() {
    _subscriptions.add(
      _player.stream.position.listen((position) {
        add(_PlayerPositionUpdated(position));
      }),
    );

    _subscriptions.add(
      _player.stream.duration.listen((duration) {
        add(_PlayerDurationReceived(duration));
      }),
    );

    _subscriptions.add(
      _player.stream.playing.listen((playing) {
        add(_PlayerPlayingChanged(playing));
      }),
    );

    _subscriptions.add(
      _player.stream.completed.listen((completed) {
        if (completed) {
          add(const _PlayerCompleted());
        }
      }),
    );

    _subscriptions.add(
      _player.stream.error.listen((error) {
        debugPrint('PlayerBloc [MPV ERROR]: $error');
      }),
    );
  }

  // ── Handlers ───────────────────────────────────────────

  Future<void> _onTrackSelected(
    PlayerTrackSelected event,
    Emitter<PlayerState> emit,
  ) async {
    // Para o player atual antes de trocar de faixa.
    _player.stop();

    emit(
      state.copyWith(
        status: PlayerStatus.loading,
        currentTrack: event.track,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );

    try {
      // 1. Obtém o arquivo local (MP4/AAC).
      final filePath = await _musicRepository.getPlayableFilePath(
        event.track.trackId,
      );

      debugPrint('PlayerBloc: Opening local file: $filePath');

      // 2. Abre o arquivo no media_kit.
      await _player.open(mk.Media(filePath));

      // Adiciona ao histórico de reprodução.
      try {
        sl<HistoryCubit>().addToHistory(event.track);
      } catch (_) {
        // Ignora erros no histórico - não é crítico.
      }

      // Extrai cor dominante da arte do álbum.
      try {
        sl<DynamicThemeCubit>().extractFromUrl(event.track.thumbnailUrl);
      } catch (_) {}
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
    _player.playOrPause();
  }

  void _onSeeked(PlayerSeeked event, Emitter<PlayerState> emit) {
    _player.seek(event.position);
  }

  Future<void> _onNextRequested(
    PlayerNextRequested event,
    Emitter<PlayerState> emit,
  ) async {
    // Se há próxima, pula.
    if (state.hasNext) {
      final nextIndex = state.queueIndex + 1;
      final nextTrack = state.queue[nextIndex];
      emit(state.copyWith(queueIndex: nextIndex));
      add(PlayerTrackSelected(nextTrack));
      return;
    }

    // Se PlayerRepeatMode.all e está no final, volta ao início.
    if (state.repeatMode == PlayerRepeatMode.all && state.queue.isNotEmpty) {
      final firstTrack = state.queue[0];
      emit(state.copyWith(queueIndex: 0));
      add(PlayerTrackSelected(firstTrack));
    }
  }

  Future<void> _onPreviousRequested(
    PlayerPreviousRequested event,
    Emitter<PlayerState> emit,
  ) async {
    // Se estamos a mais de 3 segundos, reinicia a track atual.
    if (state.position.inSeconds > 3) {
      _player.seek(Duration.zero);
      return;
    }

    if (!state.hasPrevious) {
      _player.seek(Duration.zero);
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
    // media_kit usa volume 0-100.
    _player.setVolume(event.volume * 100.0);
    emit(state.copyWith(volume: event.volume));
  }

  void _onShuffleToggled(
    PlayerShuffleToggled event,
    Emitter<PlayerState> emit,
  ) {
    if (state.shuffleEnabled) {
      // Desabilita shuffle — restaura fila original.
      if (state.originalQueue.isNotEmpty) {
        final currentTrack = state.currentTrack;
        if (currentTrack != null) {
          final newIndex = state.originalQueue.indexWhere(
            (t) => t.trackId == currentTrack.trackId,
          );
          emit(
            state.copyWith(
              shuffleEnabled: false,
              queue: state.originalQueue,
              queueIndex: newIndex >= 0 ? newIndex : state.queueIndex,
              originalQueue: [],
            ),
          );
        }
      } else {
        emit(state.copyWith(shuffleEnabled: false));
      }
    } else {
      // Habilita shuffle — embaralha fila.
      final currentTrack = state.currentTrack;
      if (currentTrack == null || state.queue.isEmpty) {
        return;
      }

      final originalQueue = List<Track>.from(state.queue);
      final shuffledQueue = List<Track>.from(state.queue);
      shuffledQueue.shuffle(Random());

      shuffledQueue.removeWhere((t) => t.trackId == currentTrack.trackId);
      shuffledQueue.insert(0, currentTrack);

      emit(
        state.copyWith(
          shuffleEnabled: true,
          queue: shuffledQueue,
          queueIndex: 0,
          originalQueue: originalQueue,
        ),
      );
    }
  }

  void _onRepeatModeChanged(
    PlayerRepeatModeChanged event,
    Emitter<PlayerState> emit,
  ) {
    final nextMode = switch (state.repeatMode) {
      PlayerRepeatMode.off => PlayerRepeatMode.all,
      PlayerRepeatMode.all => PlayerRepeatMode.one,
      PlayerRepeatMode.one => PlayerRepeatMode.off,
    };

    emit(state.copyWith(repeatMode: nextMode));
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

  void _onPlayingChanged(
    _PlayerPlayingChanged event,
    Emitter<PlayerState> emit,
  ) {
    // Quando estamos carregando e o player começa a tocar,
    // transiciona para "playing" (corrige o botão travado no spinner).
    if (state.status == PlayerStatus.loading) {
      if (event.playing) {
        emit(state.copyWith(status: PlayerStatus.playing));
      }
      return;
    }

    final status = event.playing ? PlayerStatus.playing : PlayerStatus.paused;
    emit(state.copyWith(status: status));
  }

  Future<void> _onCompleted(
    _PlayerCompleted event,
    Emitter<PlayerState> emit,
  ) async {
    // Quando a track termina, respeita o modo de repetição.
    switch (state.repeatMode) {
      case PlayerRepeatMode.one:
        // Repete a track atual.
        _player.seek(Duration.zero);
        _player.play();
        return;
      case PlayerRepeatMode.all:
        if (state.hasNext) {
          add(const PlayerNextRequested());
        } else if (state.queue.isNotEmpty) {
          final firstTrack = state.queue[0];
          emit(state.copyWith(queueIndex: 0));
          add(PlayerTrackSelected(firstTrack));
        }
        return;
      case PlayerRepeatMode.off:
        if (state.hasNext) {
          add(const PlayerNextRequested());
        } else {
          // Autoplay: Se não há próxima, busca relacionada.
          final currentTrack = state.currentTrack;
          if (currentTrack != null) {
            emit(state.copyWith(status: PlayerStatus.loading));
            try {
              // Coleta IDs já na fila para evitar repetição.
              final queueIds = state.queue.map((t) => t.trackId).toSet();
              final relatedTrack = await _musicRepository.getRelatedTrack(
                currentTrack,
                excludeIds: queueIds,
              );

              if (relatedTrack != null) {
                // Adiciona à fila e toca.
                final newQueue = List<Track>.from(state.queue)
                  ..add(relatedTrack);
                emit(
                  state.copyWith(
                    queue: newQueue,
                    queueIndex: state.queueIndex + 1,
                  ),
                );
                add(PlayerTrackSelected(relatedTrack));
                return;
              }
            } catch (e) {
              debugPrint('PlayerBloc: Falha ao buscar autoplay: $e');
            }
          }

          // Se falhar ou não tiver autoplay, para.
          emit(
            state.copyWith(
              status: PlayerStatus.paused,
              position: Duration.zero,
            ),
          );
        }
        return;
    }
  }

  // ── Queue Management ──

  void _onAddNext(PlayerAddNext event, Emitter<PlayerState> emit) {
    final newQueue = List<Track>.from(state.queue);
    final insertIndex = state.queueIndex + 1;
    newQueue.insert(insertIndex.clamp(0, newQueue.length), event.track);
    emit(state.copyWith(queue: newQueue));
  }

  void _onAddToQueue(PlayerAddToQueue event, Emitter<PlayerState> emit) {
    final newQueue = List<Track>.from(state.queue)..add(event.track);
    emit(state.copyWith(queue: newQueue));
  }

  // ── Artist Radio ──

  Future<void> _onArtistRadio(
    PlayerArtistRadioStarted event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(status: PlayerStatus.loading));
    try {
      final tracks = await _musicRepository.searchTracks(
        '${event.artistName} official audio',
      );

      // Filtra compilações e remove duplicatas.
      final filtered = tracks.where((t) => t.duration.inMinutes <= 10).toList();

      if (filtered.isNotEmpty) {
        // Shuffle para variar.
        filtered.shuffle(Random());
        emit(
          state.copyWith(
            queue: filtered,
            queueIndex: 0,
            shuffleEnabled: false,
            originalQueue: filtered,
          ),
        );
        add(PlayerTrackSelected(filtered.first));
      } else {
        emit(state.copyWith(status: PlayerStatus.idle));
      }
    } catch (e) {
      debugPrint('PlayerBloc: Erro ao iniciar Artist Radio: $e');
      emit(state.copyWith(status: PlayerStatus.idle));
    }
  }

  @override
  Future<void> close() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    await _player.dispose();
    return super.close();
  }
}
