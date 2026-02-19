import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/track.dart';
import '../models/track_model.dart';
import 'youtube_datasource.dart';

/// Gerencia downloads de músicas para ouvir offline.
///
/// Os ficheiros offline ficam em uma pasta permanente, separada do cache.
class OfflineManager {
  OfflineManager({required YoutubeDataSource youtubeDataSource})
    : _youtubeDataSource = youtubeDataSource;

  final YoutubeDataSource _youtubeDataSource;

  /// Retorna o diretório de armazenamento offline.
  Future<Directory> get offlineDir async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory('${appDir.path}/firelink_offline');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  /// Arquivo de metadados (JSON) com a lista de músicas baixadas.
  Future<File> get _metadataFile async {
    final dir = await offlineDir;
    return File('${dir.path}/metadata.json');
  }

  /// Retorna o caminho do ficheiro para uma track.
  Future<String> getTrackPath(String trackId) async {
    final dir = await offlineDir;
    return '${dir.path}/$trackId.mp4';
  }

  /// Verifica se uma track já está baixada.
  Future<bool> isTrackDownloaded(String trackId) async {
    final path = await getTrackPath(trackId);
    return File(path).existsSync();
  }

  /// Salva metadados da track no JSON local.
  Future<void> _saveMetadata(Track track) async {
    try {
      final tracks = await getOfflineTracks();
      // Remove se já existe para atualizar.
      tracks.removeWhere((t) => t.trackId == track.trackId);
      tracks.add(track);

      final file = await _metadataFile;
      final jsonList = tracks.map((t) {
        // Converte para TrackModel para usar toJson.
        // Se t já for TrackModel, ótimo. Se não, cria um.
        final model = t is TrackModel
            ? t
            : TrackModel(
                trackId: t.trackId,
                title: t.title,
                artist: t.artist,
                duration: t.duration,
                thumbnailUrl: t.thumbnailUrl,
              );
        return model.toJson();
      }).toList();

      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('OfflineManager: Erro ao salvar metadados: $e');
    }
  }

  /// Remove metadados da track.
  Future<void> _removeMetadata(String trackId) async {
    try {
      final tracks = await getOfflineTracks();
      tracks.removeWhere((t) => t.trackId == trackId);

      final file = await _metadataFile;
      final jsonList = tracks.map((t) {
        final model = t is TrackModel
            ? t
            : TrackModel(
                trackId: t.trackId,
                title: t.title,
                artist: t.artist,
                duration: t.duration,
                thumbnailUrl: t.thumbnailUrl,
              );
        return model.toJson();
      }).toList();

      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('OfflineManager: Erro ao remover metadados: $e');
    }
  }

  /// Retorna a lista de tracks offline (com metadados).
  Future<List<Track>> getOfflineTracks() async {
    try {
      final file = await _metadataFile;
      if (!file.existsSync()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);

      return jsonList.map((j) => TrackModel.fromJson(j)).toList();
    } catch (e) {
      debugPrint('OfflineManager: Erro ao ler metadados: $e');
      return [];
    }
  }

  /// Baixa uma track para armazenamento offline e salva metadados.
  ///
  /// Retorna o caminho do arquivo ou null se falhar.
  Future<String?> downloadTrack(Track track) async {
    try {
      // Usa o datasource para baixar — ele retorna o caminho do cache.
      final cachedPath = await _youtubeDataSource.downloadAudio(track.trackId);

      // Copia do cache para a pasta offline permanente.
      final offlinePath = await getTrackPath(track.trackId);
      final sourceFile = File(cachedPath);

      if (sourceFile.existsSync()) {
        await sourceFile.copy(offlinePath);
        // Salva metadados após sucesso.
        await _saveMetadata(track);
        debugPrint('OfflineManager: Salvo offline em $offlinePath');
        return offlinePath;
      }

      return null;
    } catch (e) {
      debugPrint('OfflineManager: Erro ao baixar ${track.title}: $e');
      return null;
    }
  }

  /// Remove uma track offline e seus metadados.
  Future<void> removeTrack(String trackId) async {
    final path = await getTrackPath(trackId);
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
      debugPrint('OfflineManager: Removido $path');
    }
    await _removeMetadata(trackId);
  }

  /// Lista todos os trackIds que estão salvos offline.
  Future<List<String>> getOfflineTrackIds() async {
    final tracks = await getOfflineTracks();
    return tracks.map((t) => t.trackId).toList();
  }

  /// Calcula o tamanho total de armazenamento offline em bytes.
  Future<int> getOfflineSizeBytes() async {
    final dir = await offlineDir;
    if (!dir.existsSync()) return 0;

    int total = 0;
    try {
      for (final entity in dir.listSync()) {
        if (entity is File && entity.path.endsWith('.mp4')) {
          total += entity.lengthSync();
        }
      }
    } catch (_) {}
    return total;
  }
}
