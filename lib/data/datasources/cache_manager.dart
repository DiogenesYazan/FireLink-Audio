import 'dart:io';

import 'package:flutter/foundation.dart';

/// Gerencia o cache de arquivos de áudio em disco.
///
/// Calcula o tamanho total do cache, limpa arquivos mais antigos
/// quando o limite configurado é ultrapassado, e permite limpeza manual.
class CacheManager {
  CacheManager();

  /// Diretório de cache (ficheiros temporários de streaming).
  Directory get cacheDir {
    final tempDir = Directory.systemTemp;
    return Directory('${tempDir.path}/firelink_cache');
  }

  /// Diretório de downloads offline (permanentes).
  Directory get offlineDir {
    final tempDir = Directory.systemTemp;
    final parent = tempDir.parent; // AppData/Local
    return Directory('${parent.path}/firelink_offline');
  }

  /// Calcula o tamanho total do cache em bytes.
  Future<int> getCacheSizeBytes() async {
    final dir = cacheDir;
    if (!dir.existsSync()) return 0;

    int totalSize = 0;
    try {
      for (final entity in dir.listSync()) {
        if (entity is File) {
          totalSize += entity.lengthSync();
        }
      }
    } catch (e) {
      debugPrint('CacheManager: Erro ao calcular tamanho: $e');
    }
    return totalSize;
  }

  /// Retorna o tamanho formatado em MB.
  Future<String> getCacheSizeFormatted() async {
    final bytes = await getCacheSizeBytes();
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Conta o número de arquivos no cache.
  Future<int> getCacheFileCount() async {
    final dir = cacheDir;
    if (!dir.existsSync()) return 0;

    try {
      return dir.listSync().whereType<File>().length;
    } catch (_) {
      return 0;
    }
  }

  /// Limpa TODOS os arquivos do cache.
  Future<void> clearCache() async {
    final dir = cacheDir;
    if (!dir.existsSync()) return;

    try {
      for (final entity in dir.listSync()) {
        if (entity is File) {
          entity.deleteSync();
        }
      }
      debugPrint('CacheManager: Cache limpo com sucesso.');
    } catch (e) {
      debugPrint('CacheManager: Erro ao limpar cache: $e');
    }
  }

  /// Aplica o limite de cache, deletando os arquivos mais antigos primeiro.
  ///
  /// [limitMB] é o tamanho máximo em megabytes.
  Future<void> enforceCacheLimit(int limitMB) async {
    final dir = cacheDir;
    if (!dir.existsSync()) return;

    final limitBytes = limitMB * 1024 * 1024;
    int currentSize = await getCacheSizeBytes();

    if (currentSize <= limitBytes) return;

    // Lista os ficheiros ordenados por data de modificação (mais antigo primeiro).
    final files = dir.listSync().whereType<File>().toList()
      ..sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));

    for (final file in files) {
      if (currentSize <= limitBytes) break;

      final fileSize = file.lengthSync();
      try {
        file.deleteSync();
        currentSize -= fileSize;
        debugPrint(
          'CacheManager: Deletado ${file.path} (${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB)',
        );
      } catch (e) {
        debugPrint('CacheManager: Erro ao deletar ${file.path}: $e');
      }
    }

    debugPrint(
      'CacheManager: Cache ajustado para ${(currentSize / 1024 / 1024).toStringAsFixed(1)} MB (limite: $limitMB MB)',
    );
  }
}
