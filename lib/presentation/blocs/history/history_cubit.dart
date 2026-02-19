import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local_storage_datasource.dart';
import '../../../data/models/track_model.dart';
import '../../../domain/entities/track.dart';

part 'history_state.dart';

/// Cubit para gerenciar o histórico de reprodução.
///
/// Mantém as últimas 50 tracks tocadas (sem duplicatas consecutivas).
/// Agora com timestamps para agrupar em seções (Hoje, Ontem, etc.).
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

      // Carregar timestamps.
      final rawTimestamps = await _localStorageDatasource
          .loadHistoryTimestamps();

      emit(
        state.copyWith(
          status: HistoryStatus.loaded,
          recentTracks: tracks,
          timestamps: rawTimestamps,
        ),
      );
    } catch (e) {
      debugPrint('HistoryCubit: Erro ao carregar histórico: $e');
      emit(
        state.copyWith(
          status: HistoryStatus.error,
          errorMessage: 'Erro ao carregar histórico: $e',
        ),
      );
    }
  }

  /// Adiciona uma track ao histórico.
  Future<void> addToHistory(Track track) async {
    if (state.recentTracks.isNotEmpty &&
        state.recentTracks.first.trackId == track.trackId) {
      return;
    }

    final updatedTracks = state.recentTracks
        .where((t) => t.trackId != track.trackId)
        .toList();

    updatedTracks.insert(0, track);
    final limited = updatedTracks.take(50).toList();

    // Atualiza timestamp.
    final updatedTimestamps = Map<String, DateTime>.from(state.timestamps);
    updatedTimestamps[track.trackId] = DateTime.now();

    emit(state.copyWith(recentTracks: limited, timestamps: updatedTimestamps));

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
      await _localStorageDatasource.saveHistoryTimestamps(updatedTimestamps);
    } catch (e) {
      // Erro ao persistir — não afeta o estado.
    }
  }

  /// Limpa o histórico.
  Future<void> clearHistory() async {
    emit(state.copyWith(recentTracks: [], timestamps: {}));
    await _localStorageDatasource.savePlaybackHistory([]);
    await _localStorageDatasource.saveHistoryTimestamps({});
  }

  /// Retorna as tracks agrupadas por seção temporal.
  Map<String, List<Track>> get groupedHistory {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final sections = <String, List<Track>>{
      'Hoje': [],
      'Ontem': [],
      'Esta semana': [],
      'Mais antigos': [],
    };

    for (final track in state.recentTracks) {
      final timestamp = state.timestamps[track.trackId];
      if (timestamp == null) {
        sections['Mais antigos']!.add(track);
        continue;
      }

      final trackDate = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
      );
      if (trackDate == today || trackDate.isAfter(today)) {
        sections['Hoje']!.add(track);
      } else if (trackDate == yesterday || trackDate.isAfter(yesterday)) {
        sections['Ontem']!.add(track);
      } else if (trackDate.isAfter(weekAgo)) {
        sections['Esta semana']!.add(track);
      } else {
        sections['Mais antigos']!.add(track);
      }
    }

    // Remove seções vazias.
    sections.removeWhere((_, tracks) => tracks.isEmpty);
    return sections;
  }
}
