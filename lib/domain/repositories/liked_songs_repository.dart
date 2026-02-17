import '../entities/track.dart';

/// Repositório abstrato para gerenciar músicas curtidas.
abstract class LikedSongsRepository {
  /// Retorna todas as tracks curtidas.
  Future<List<Track>> getLikedTracks();

  /// Adiciona ou remove uma track da lista de curtidas.
  /// Retorna true se foi adicionado (curtido), false se foi removido (descurtido).
  Future<bool> toggleLike(Track track);

  /// Verifica se uma track está curtida.
  Future<bool> isLiked(String trackId);

  /// Retorna os IDs de todas as tracks curtidas (para verificação rápida).
  Future<Set<String>> getLikedTrackIds();
}
