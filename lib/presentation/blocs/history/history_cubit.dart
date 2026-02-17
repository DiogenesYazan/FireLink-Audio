import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local_storage_datasource.dart';
import '../../../data/models/track_model.dart';
import '../../../domain/entities/track.dart';

part 'history_state.dart';

/// Cubit para gerenciar o histórico de reprodução.
///
/// Mantém as últimas 50 tracks tocadas (sem duplicatas consecutivas).
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required LocalStorageDatasource localStorageDatasource})
    : _localStorageDatasource = localStorageDatasource,
      super(const HistoryState()) {
    loadHistory();
  }

  final LocalStorageDatasource _localStorageDatasource;

  /// Carrega o histórico do storage.
  Future<void> loadHistory() async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final jsonList = await _localStorageDatasource.loadPlaybackHistory();
      final tracks = jsonList.map((json) => TrackModel.fromJson(json)).toList();

      emit(state.copyWith(status: HistoryStatus.loaded, recentTracks: tracks));
    } catch (e) {
      emit(
        state.copyWith(
          status: HistoryStatus.error,
          errorMessage: 'Erro ao carregar histórico: $e',
        ),
      );
    }
  }

  /// Adiciona uma track ao histórico.
  ///
  /// Evita duplicatas consecutivas — só adiciona se for diferente da última.
  Future<void> addToHistory(Track track) async {
    // Se é a mesma track que já está no topo, não adiciona.
    if (state.recentTracks.isNotEmpty &&
        state.recentTracks.first.trackId == track.trackId) {
      return;
    }

    // Remove ocorrências anteriores desta track (para movê-la pro topo).
    final updatedTracks = state.recentTracks
        .where((t) => t.trackId != track.trackId)
        .toList();

    // Adiciona no topo.
    updatedTracks.insert(0, track);

    // Limita a 50 itens.
    final limited = updatedTracks.take(50).toList();

    emit(state.copyWith(recentTracks: limited));

    // Persiste.
    try {
      final jsonList = limited
          .map(
            (t) => TrackModel(
              trackId: t.trackId,
              title: t.title,
              artist: t.artist,
              duration: t.duration,
              thumbnailUrl: t.thumbnailUrl,
              streamUrl: t.streamUrl,
            ).toJson(),
          )
          .toList();

      await _localStorageDatasource.savePlaybackHistory(jsonList);
    } catch (e) {
      // Erro ao persistir — não afeta o estado.
    }
  }

  /// Limpa o histórico.
  Future<void> clearHistory() async {
    emit(state.copyWith(recentTracks: []));
    await _localStorageDatasource.savePlaybackHistory([]);
  }
}
