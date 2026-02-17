import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// DataSource para persistência local usando SharedPreferences.
///
/// Gerencia músicas curtidas e histórico de reprodução.
class LocalStorageDatasource {
  static const String _likedTracksKey = 'liked_tracks';
  static const String _playbackHistoryKey = 'playback_history';

  /// Salva a lista de tracks curtidas como JSON.
  Future<void> saveLikedTracks(List<Map<String, dynamic>> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tracks);
    await prefs.setString(_likedTracksKey, jsonString);
  }

  /// Carrega a lista de tracks curtidas do JSON.
  Future<List<Map<String, dynamic>>> loadLikedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_likedTracksKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      // Se o JSON estiver corrompido, retorna lista vazia.
      return [];
    }
  }

  /// Salva o histórico de reprodução como JSON.
  /// Limita a 50 itens mais recentes.
  Future<void> savePlaybackHistory(List<Map<String, dynamic>> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    // Mantém apenas os 50 mais recentes.
    final limited = tracks.take(50).toList();
    final jsonString = jsonEncode(limited);
    await prefs.setString(_playbackHistoryKey, jsonString);
  }

  /// Carrega o histórico de reprodução do JSON.
  Future<List<Map<String, dynamic>>> loadPlaybackHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_playbackHistoryKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Limpa todos os dados persistidos (útil para testes ou reset).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_likedTracksKey);
    await prefs.remove(_playbackHistoryKey);
  }
}
