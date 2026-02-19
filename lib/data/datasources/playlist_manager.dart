import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/track.dart';

/// Gerenciador de playlists locais (CRUD).
///
/// Persiste playlists como JSON no diretório de dados do app.
class PlaylistManager {
  static const String _fileName = 'playlists.json';

  File? _file;

  Future<File> _getFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    _file = File('${dir.path}/$_fileName');
    return _file!;
  }

  /// Carrega todas as playlists.
  Future<Map<String, List<Map<String, dynamic>>>> _loadAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return {};
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      return decoded.map(
        (key, value) =>
            MapEntry(key, (value as List).cast<Map<String, dynamic>>()),
      );
    } catch (e) {
      debugPrint('PlaylistManager: Erro ao carregar: $e');
      return {};
    }
  }

  /// Salva todas as playlists.
  Future<void> _saveAll(Map<String, List<Map<String, dynamic>>> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  /// Retorna nomes de todas as playlists.
  Future<List<String>> getPlaylistNames() async {
    final data = await _loadAll();
    return data.keys.toList();
  }

  /// Retorna tracks de uma playlist.
  Future<List<Map<String, dynamic>>> getPlaylistTracks(String name) async {
    final data = await _loadAll();
    return data[name] ?? [];
  }

  /// Cria uma nova playlist (vazia).
  Future<void> createPlaylist(String name) async {
    final data = await _loadAll();
    if (!data.containsKey(name)) {
      data[name] = [];
      await _saveAll(data);
    }
  }

  /// Adiciona uma track a uma playlist.
  Future<void> addTrack(String playlistName, Track track) async {
    final data = await _loadAll();
    data.putIfAbsent(playlistName, () => []);

    // Evita duplicatas.
    final existing = data[playlistName]!;
    if (existing.any((t) => t['trackId'] == track.trackId)) return;

    existing.add({
      'trackId': track.trackId,
      'title': track.title,
      'artist': track.artist,
      'thumbnailUrl': track.thumbnailUrl,
      'durationMs': track.duration.inMilliseconds,
    });
    await _saveAll(data);
  }

  /// Remove uma track de uma playlist.
  Future<void> removeTrack(String playlistName, String trackId) async {
    final data = await _loadAll();
    data[playlistName]?.removeWhere((t) => t['trackId'] == trackId);
    await _saveAll(data);
  }

  /// Deleta uma playlist inteira.
  Future<void> deletePlaylist(String name) async {
    final data = await _loadAll();
    data.remove(name);
    await _saveAll(data);
  }

  /// Renomeia uma playlist.
  Future<void> renamePlaylist(String oldName, String newName) async {
    final data = await _loadAll();
    if (data.containsKey(oldName)) {
      data[newName] = data.remove(oldName)!;
      await _saveAll(data);
    }
  }
}
