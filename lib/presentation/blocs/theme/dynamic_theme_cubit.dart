import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

/// Cubit para tema dinâmico baseado na arte do álbum.
///
/// Extrai a cor dominante da thumbnail da track atual
/// usando um algoritmo simples de amostragem de pixels.
class DynamicThemeCubit extends Cubit<DynamicThemeState> {
  DynamicThemeCubit() : super(const DynamicThemeState());

  String? _lastUrl;

  /// Extrai a cor dominante da URL da thumbnail.
  Future<void> extractFromUrl(String? thumbnailUrl) async {
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      emit(const DynamicThemeState());
      return;
    }

    // Evita re-processar a mesma URL.
    if (_lastUrl == thumbnailUrl) return;
    _lastUrl = thumbnailUrl;

    try {
      // Baixa a imagem.
      final response = await http.get(Uri.parse(thumbnailUrl));
      if (response.statusCode != 200) return;

      // Decodifica a imagem.
      final codec = await instantiateImageCodec(response.bodyBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Amostra pixels para encontrar a cor dominante.
      final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
      if (byteData == null) return;

      final pixels = byteData.buffer.asUint8List();
      final colorCounts = <int, int>{};

      // Amostra a cada 10 pixels para performance.
      for (var i = 0; i < pixels.length; i += 40) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];

        // Ignora pixels muito escuros ou muito claros.
        final brightness = (r + g + b) / 3;
        if (brightness < 30 || brightness > 220) continue;

        // Quantiza para reduzir variações.
        final qr = (r ~/ 32) * 32;
        final qg = (g ~/ 32) * 32;
        final qb = (b ~/ 32) * 32;

        final key = (qr << 16) | (qg << 8) | qb;
        colorCounts[key] = (colorCounts[key] ?? 0) + 1;
      }

      if (colorCounts.isEmpty) return;

      // Encontra a cor mais frequente.
      final sortedEntries = colorCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final dominantKey = sortedEntries.first.key;
      final dominantColor = Color.fromARGB(
        255,
        (dominantKey >> 16) & 0xFF,
        (dominantKey >> 8) & 0xFF,
        dominantKey & 0xFF,
      );

      // Cria versão muted (mais escura) para backgrounds.
      final hsl = HSLColor.fromColor(dominantColor);
      final mutedColor = hsl
          .withSaturation((hsl.saturation * 0.6).clamp(0.0, 1.0))
          .withLightness((hsl.lightness * 0.3).clamp(0.0, 1.0))
          .toColor();

      emit(
        DynamicThemeState(dominantColor: dominantColor, mutedColor: mutedColor),
      );

      image.dispose();
    } catch (_) {
      // Silently fail — fallback para cor padrão.
    }
  }

  /// Reseta para o tema padrão.
  void reset() {
    _lastUrl = null;
    emit(const DynamicThemeState());
  }
}

/// Estado do tema dinâmico.
class DynamicThemeState {
  const DynamicThemeState({this.dominantColor, this.mutedColor});

  /// Cor dominante da arte do álbum.
  final Color? dominantColor;

  /// Cor muted (escura) para gradientes de fundo.
  final Color? mutedColor;

  bool get hasColors => dominantColor != null && mutedColor != null;
}
