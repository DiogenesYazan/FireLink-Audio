import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Um serviço de Proxy Local que age como um "Mini-Lavalink".
///
/// **Por que isso é necessário?**
/// O MPV (e outros players nativos) frequentemente falham ao tentar tocar
/// streams do YouTube diretamente devido a:
/// 1. Bloqueio de headers (Googlevideo recusa conexões sem headers específicos).
/// 2. Throttling e expiração de links.
/// 3. Complexidade de codecs (DASH splitting).
///
/// **Como funciona:**
/// 1. Sobe um servidor HTTP local em `localhost:0` (porta aleatória).
/// 2. Aceita requisições em `/play/{videoId}`.
/// 3. Usa [YoutubeExplode] para pegar o *link real* de áudio mais recente.
/// 4. Faz o streaming (pipe) dos bytes do YouTube para o Player.
/// 5. O Player acha que está tocando um arquivo HTTP normal e estável.
class StreamProxyService {
  HttpServer? _server;
  final YoutubeExplode _yt;
  int get port => _server?.port ?? 0;

  StreamProxyService() : _yt = YoutubeExplode();

  /// Inicia o servidor proxy.
  Future<void> start() async {
    if (_server != null) return;
    try {
      // 'loopbackIPv4' garante que ouvimos apenas em 127.0.0.1
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      debugPrint(
        'StreamProxyService: Proxy iniciado em http://127.0.0.1:$port',
      );
      _server!.listen(
        (req) => _handleRequest(req),
        onError: (e) => debugPrint('StreamProxyService: Erro no server: $e'),
      );
    } catch (e) {
      debugPrint('StreamProxyService: Falha ao iniciar proxy: $e');
    }
  }

  /// Retorna a URL local que o Player deve usar para tocar este vídeo.
  String getUrlFor(String videoId) {
    if (_server == null) {
      debugPrint(
        'StreamProxyService: AVISO - Proxy não iniciado, tentando iniciar...',
      );
      // Em teoria deveria esperar, mas aqui retornamos placeholder ou erro.
      return '';
    }
    return 'http://127.0.0.1:$port/play/$videoId';
  }

  /// Processa as requisições do Player.
  Future<void> _handleRequest(HttpRequest request) async {
    // Rota esperada: /play/{videoId}
    if (request.uri.pathSegments.length < 2 ||
        request.uri.pathSegments[0] != 'play') {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final videoId = request.uri.pathSegments[1];

    try {
      // 1. Resolve o manifesto de streams mais recente.
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // 2. Escolhe o melhor stream de áudio (audio-only, maior bitrate).
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      if (audioStreamInfo == null) {
        throw Exception('Nenhum stream de áudio encontrado para $videoId');
      }

      // 3. Abre o stream real do YouTube.
      final stream = _yt.videos.streamsClient.get(audioStreamInfo);

      // 4. Configura headers de resposta para o Player.
      // O MPV gosta de saber o Content-Type e Length se possível.
      request.response.headers.contentType = ContentType(
        'audio',
        'mpeg',
      ); // Genérico ou específico
      request.response.headers.set('Accept-Ranges', 'bytes');

      if (audioStreamInfo.size.totalBytes != 0) {
        request.response.contentLength = audioStreamInfo.size.totalBytes;
      }

      // 5. Pipe (transfere) os dados.
      await stream.pipe(request.response);
    } catch (e) {
      debugPrint('StreamProxyService: Erro ao processar $videoId: $e');
      if (!request.response.headers.chunkedTransferEncoding) {
        try {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write('Erro no proxy: $e');
        } catch (_) {}
      }
      await request.response.close();
    }
  }

  /// Encerra o servidor.
  Future<void> dispose() async {
    await _server?.close(force: true);
    _server = null;
    _yt.close();
  }
}
