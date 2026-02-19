import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/offline_manager.dart';
import '../../../domain/entities/track.dart';
import 'offline_state.dart';

/// Cubit para gerenciar downloads offline de músicas.
class OfflineCubit extends Cubit<OfflineState> {
  OfflineCubit({required OfflineManager offlineManager})
    : _offlineManager = offlineManager,
      super(const OfflineState()) {
    _loadOfflineTracks();
  }

  final OfflineManager _offlineManager;

  /// Carrega a lista de tracks offline ao iniciar.
  Future<void> _loadOfflineTracks() async {
    try {
      final tracks = await _offlineManager.getOfflineTracks();
      emit(state.copyWith(tracks: tracks));
    } catch (e) {
      debugPrint('OfflineCubit: Erro ao carregar offline: $e');
    }
  }

  /// Baixa uma track para offline.
  Future<void> downloadTrack(Track track) async {
    if (state.isOffline(track.trackId) || state.isDownloading(track.trackId)) {
      return;
    }

    // Marca como em download.
    emit(
      state.copyWith(
        downloadingTrackIds: {...state.downloadingTrackIds, track.trackId},
      ),
    );

    try {
      final path = await _offlineManager.downloadTrack(track);

      if (path != null) {
        // Sucesso — adiciona à lista.
        // Recarregamos a lista do disco para garantir consistência.
        // Ou adicionamos manualmente se quisermos ser otimistas.
        final currentTracks = List<Track>.from(state.tracks);
        currentTracks.add(track);

        emit(
          state.copyWith(
            tracks: currentTracks,
            downloadingTrackIds: state.downloadingTrackIds
                .where((id) => id != track.trackId)
                .toSet(),
          ),
        );
      } else {
        // Falha.
        emit(
          state.copyWith(
            downloadingTrackIds: state.downloadingTrackIds
                .where((id) => id != track.trackId)
                .toSet(),
          ),
        );
      }
    } catch (e) {
      debugPrint('OfflineCubit: Erro ao baixar ${track.title}: $e');
      emit(
        state.copyWith(
          downloadingTrackIds: state.downloadingTrackIds
              .where((id) => id != track.trackId)
              .toSet(),
        ),
      );
    }
  }

  /// Remove uma track offline.
  Future<void> removeTrack(String trackId) async {
    await _offlineManager.removeTrack(trackId);

    final currentTracks = List<Track>.from(state.tracks);
    currentTracks.removeWhere((t) => t.trackId == trackId);

    emit(state.copyWith(tracks: currentTracks));
  }

  /// Refresh da lista de offline.
  Future<void> refresh() async {
    await _loadOfflineTracks();
  }
}
