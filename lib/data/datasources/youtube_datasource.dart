import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:firelink_audio/data/models/track_model.dart';

/// DataSource que usa [youtube_explode_dart] para buscar e resolver
/// streams de áudio do YouTube.
///
/// **Estratégia: Download & Play**
/// Devido a bloqueios severos de headers e proxies no Windows, a estratégia
/// mais robusta é baixar o áudio (que é pequeno, ~3MB) para um arquivo
/// temporário usando o cliente autenticado do youtube_explode, e então
/// tocar o arquivo local.
class YoutubeDataSource {
  final yt.YoutubeExplode _ytExplode;

  YoutubeDataSource() : _ytExplode = yt.YoutubeExplode();

  /// Busca tracks no YouTube.
  Future<List<TrackModel>> searchTracks(String query) async {
    try {
      final results = await _ytExplode.search.search(query);
      return results.map((video) {
        return TrackModel(
          trackId: video.id.value,
          title: video.title,
          artist: video.author,
          duration: video.duration ?? Duration.zero,
          thumbnailUrl: video.thumbnails.highResUrl,
        );
      }).toList();
    } catch (e) {
      debugPrint('YoutubeDataSource: Erro na busca "$query": $e');
      return [];
    }
  }

  /// Retorna tracks "trending" — busca músicas individuais populares.
  ///
  /// Usa queries com nome de artista + "official audio" para evitar
  /// compilações genéricas de 2+ horas.
  Future<List<TrackModel>> getTrendingTracks({String genre = 'music'}) async {
    // Queries específicas por gênero que retornam MÚSICAS individuais.
    final queries = <String, List<String>>{
      'all-music': [
        'Billie Eilish official audio',
        'The Weeknd official audio',
        'Dua Lipa official audio',
      ],
      'pop': [
        'Taylor Swift official audio',
        'Dua Lipa official audio',
        'Sabrina Carpenter official audio',
      ],
      'electronic': [
        'Calvin Harris official audio',
        'David Guetta official audio',
        'Marshmello official audio',
      ],
      'hiphoprap': [
        'Drake official audio',
        'Kendrick Lamar official audio',
        'Travis Scott official audio',
      ],
      'rbsoul': [
        'SZA official audio',
        'The Weeknd official audio',
        'Frank Ocean official audio',
      ],
      'rock': [
        'Imagine Dragons official audio',
        'Arctic Monkeys official audio',
        'Maneskin official audio',
      ],
      'latin': [
        'Bad Bunny official audio',
        'Peso Pluma official audio',
        'Rauw Alejandro official audio',
      ],
      'danceedm': [
        'Tiësto official audio',
        'Martin Garrix official audio',
        'Alok official audio',
      ],
      'country': [
        'Morgan Wallen official audio',
        'Luke Combs official audio',
        'Chris Stapleton official audio',
      ],
      'reggae': [
        'Bob Marley official audio',
        'Sean Paul official audio',
        'Shaggy official audio',
      ],
    };

    final searchQueries = queries[genre] ?? ['top songs official audio'];

    // Busca múltiplas queries e combina os resultados.
    final allTracks = <TrackModel>[];
    for (final query in searchQueries) {
      final results = await searchTracks(query);
      allTracks.addAll(results);
    }

    // Filtra compilações: remove resultados com duração > 10 minutos.
    final filtered = allTracks.where((t) {
      return t.duration.inMinutes <= 10;
    }).toList();

    // Remove duplicatas por trackId.
    final seen = <String>{};
    final unique = filtered.where((t) => seen.add(t.trackId)).toList();

    return unique;
  }

  /// Busca um vídeo DIFERENTE do artista atual para autoplay.
  ///
  /// Estratégia:
  /// 1. Busca pelo ARTISTA (sem o título) para encontrar outras músicas.
  /// 2. Filtra variantes do mesmo título (live, remaster, tradução, etc.).
  /// 3. Evita IDs que já estão na fila.
  Future<TrackModel?> getRelatedVideo({
    required String title,
    required String artist,
    required String currentId,
    Set<String> excludeIds = const {},
  }) async {
    try {
      // Extrai palavras-chave do título atual para filtrar variantes.
      final titleKeywords = _extractKeywords(title);

      // Busca pelo ARTISTA apenas — traz outras músicas do mesmo artista.
      final query = '$artist popular songs';
      final results = await _ytExplode.search.search(query);

      for (final video in results) {
        final videoId = video.id.value;

        // Pula o vídeo atual e os que já estão na fila.
        if (videoId == currentId || excludeIds.contains(videoId)) continue;

        // Pula compilações (> 15 min).
        if ((video.duration?.inMinutes ?? 0) > 15) continue;

        // Pula variantes do mesmo título.
        final videoKeywords = _extractKeywords(video.title);
        if (_isSimilarTitle(titleKeywords, videoKeywords)) continue;

        return TrackModel(
          trackId: videoId,
          title: video.title,
          artist: video.author,
          duration: video.duration ?? Duration.zero,
          thumbnailUrl: video.thumbnails.highResUrl,
        );
      }
    } catch (e) {
      debugPrint('YoutubeDataSource: Erro ao buscar related de $currentId: $e');
    }
    return null;
  }

  /// Extrai palavras-chave significativas de um título (ignora ruído).
  Set<String> _extractKeywords(String title) {
    // Remove termos comuns de variante/ruído.
    final noise = {
      'official',
      'audio',
      'video',
      'music',
      'hd',
      'hq',
      'lyrics',
      'lyric',
      'live',
      'ao',
      'vivo',
      'remaster',
      'remastered',
      'remix',
      'cover',
      'acoustic',
      'version',
      'ft',
      'feat',
      'featuring',
      'tradução',
      'legendado',
      'sub',
      'extended',
      'edit',
      'mix',
      'performance',
      'concert',
      'tour',
      'session',
      'visualizer',
    };
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove pontuação
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1 && !noise.contains(w))
        .toSet();
  }

  /// Verifica se dois conjuntos de keywords representam a mesma música.
  /// Se >= 60% das palavras-chave do título original aparecem no candidato,
  /// considera variante.
  bool _isSimilarTitle(Set<String> original, Set<String> candidate) {
    if (original.isEmpty) return false;
    final overlap = original.intersection(candidate).length;
    return overlap / original.length >= 0.6;
  }

  /// Baixa o áudio do vídeo para um arquivo temporário local.
  ///
  /// **IMPORTANTE:** Prioriza containers MP4/M4A para máxima
  /// compatibilidade cross-platform (Windows + Android).
  Future<String> downloadAudio(String videoId) async {
    final tempDir = Directory.systemTemp;
    final cacheDir = Directory('${tempDir.path}/firelink_cache');

    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }

    // Procura por arquivos já baixados com ESSE formato (mp4).
    try {
      final cachedFile = cacheDir.listSync().whereType<File>().firstWhere(
        (f) =>
            f.path.contains('firelink_yt_$videoId') &&
            (f.path.endsWith('.mp4') || f.path.endsWith('.m4a')),
        orElse: () => File(''),
      );

      if (cachedFile.path.isNotEmpty && cachedFile.lengthSync() > 0) {
        debugPrint('YoutubeDataSource: Cache hit (MP4) para $videoId');
        return cachedFile.path;
      }
    } catch (_) {}

    final manifest = await _ytExplode.videos.streamsClient.getManifest(
      yt.VideoId(videoId),
    );

    // Estratégia "Play the Video":
    // O usuário pediu para usar o vídeo se necessário. Muxed MP4 (Video + Audio)
    // é o formato mais compatível que existe (H.264 + AAC).
    // O just_audio vai tocar a faixa de áudio desse arquivo perfeitamente.
    yt.StreamInfo? streamInfo;

    // 1. Prioridade: Muxed MP4 (rock-solid em todas as plataformas).
    final muxedMp4 = manifest.muxed
        .where((s) => s.container.name.toLowerCase() == 'mp4')
        .sortByBitrate();

    if (muxedMp4.isNotEmpty) {
      // Pega o menor bitrate aceitável (360p/720p) para economizar dados,
      // já que só queremos o áudio, mas garantindo compatibilidade.
      // Ou pega o maior se o user quiser "qualidade". Vamos no maior para garantir e depois otimizamos.
      streamInfo = muxedMp4.last;
      debugPrint(
        'YoutubeDataSource: Selecionado Muxed MP4 (Video+Audio) para compatibilidade máxima.',
      );
    } else {
      // 2. Fallback: Audio-Only MP4
      final audioMp4 = manifest.audioOnly
          .where((s) => s.container.name.toLowerCase() == 'mp4')
          .sortByBitrate();

      if (audioMp4.isNotEmpty) {
        streamInfo = audioMp4.last;
      }
    }

    // Se falhar MP4, última esperança é WebM, mas logamos aviso.
    if (streamInfo == null) {
      debugPrint(
        'YoutubeDataSource: AVISO - Nenhum MP4 encontrado. Tentando WebM (funciona no Android, pode falhar no Windows).',
      );
      streamInfo = manifest.audioOnly.withHighestBitrate();
    }

    final ext = streamInfo.container.name; // 'mp4' ou 'webm'
    final filePath = '${cacheDir.path}/firelink_yt_$videoId.$ext';
    final tempFile = File(filePath);

    debugPrint('YoutubeDataSource: Baixando para $filePath...');

    final stream = _ytExplode.videos.streamsClient.get(streamInfo);
    final sink = tempFile.openWrite();

    try {
      await stream.pipe(sink);
    } catch (e) {
      await sink.close();
      if (tempFile.existsSync()) tempFile.deleteSync();
      rethrow;
    }

    await sink.flush();
    await sink.close();

    debugPrint('YoutubeDataSource: Download concluído.');
    return filePath;
  }

  /// Libera recursos.
  void dispose() {
    _ytExplode.close();
  }
}
