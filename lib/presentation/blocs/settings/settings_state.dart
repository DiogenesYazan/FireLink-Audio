import 'package:equatable/equatable.dart';

/// Estado do Settings (preferências persistentes).
class SettingsState extends Equatable {
  const SettingsState({
    this.cacheLimitMB = 500,
    this.cacheSizeMB = 0.0,
    this.cacheFileCount = 0,
    this.isClearing = false,
  });

  /// Limite máximo de cache em MB (configurável pelo usuário).
  final int cacheLimitMB;

  /// Tamanho atual do cache em MB.
  final double cacheSizeMB;

  /// Número de arquivos no cache.
  final int cacheFileCount;

  /// Se está em processo de limpeza.
  final bool isClearing;

  SettingsState copyWith({
    int? cacheLimitMB,
    double? cacheSizeMB,
    int? cacheFileCount,
    bool? isClearing,
  }) {
    return SettingsState(
      cacheLimitMB: cacheLimitMB ?? this.cacheLimitMB,
      cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
      cacheFileCount: cacheFileCount ?? this.cacheFileCount,
      isClearing: isClearing ?? this.isClearing,
    );
  }

  @override
  List<Object?> get props => [
    cacheLimitMB,
    cacheSizeMB,
    cacheFileCount,
    isClearing,
  ];
}
