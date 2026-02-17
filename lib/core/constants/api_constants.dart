/// Constantes de API utilizadas no app.
abstract final class ApiConstants {
  /// Base URL da API lrclib.net para busca de letras.
  static const String lrclibBaseUrl = 'https://lrclib.net';

  /// User-Agent enviado nas requisições HTTP.
  static const String userAgent = 'FireLink-Audio/1.0.0 (Flutter)';

  /// Timeout padrão para chamadas HTTP, em segundos.
  static const int httpTimeoutSeconds = 15;

  /// Base URL da API v2 do SoundCloud.
  static const String soundCloudBaseUrl = 'https://api-v2.soundcloud.com';

  /// Client ID do app registrado no SoundCloud Developer.
  static const String soundCloudClientId = 'wpEviruMaQdsnyKwF4ycJsphzBHR82VQ';

  /// Client Secret do app registrado no SoundCloud Developer.
  static const String soundCloudClientSecret =
      '86lUc14qyAwr9LoJGPAjfNR5cAzcA0Tu';
}
