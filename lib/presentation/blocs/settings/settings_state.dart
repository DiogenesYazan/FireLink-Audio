import 'package:equatable/equatable.dart';

/// Estado do Settings (preferências persistentes).
class SettingsState extends Equatable {
  const SettingsState({
    this.cacheLimitMB = 500,
    this.cacheSizeMB = 0.0,
    this.cacheFileCount = 0,
    this.isClearing = false,
    this.crossfadeSeconds = 0,
    this.volumeNormalization = false,
  });

  final int cacheLimitMB;
  final double cacheSizeMB;
  final int cacheFileCount;
  final bool isClearing;

  /// Duração do crossfade em segundos (0 = desativado).
  final int crossfadeSeconds;

  /// Se a normalização de volume está ativada.
  final bool volumeNormalization;

  SettingsState copyWith({
    int? cacheLimitMB,
    double? cacheSizeMB,
    int? cacheFileCount,
    bool? isClearing,
    int? crossfadeSeconds,
    bool? volumeNormalization,
  }) {
    return SettingsState(
      cacheLimitMB: cacheLimitMB ?? this.cacheLimitMB,
      cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
      cacheFileCount: cacheFileCount ?? this.cacheFileCount,
      isClearing: isClearing ?? this.isClearing,
      crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
      volumeNormalization: volumeNormalization ?? this.volumeNormalization,
    );
  }

  @override
  List<Object?> get props => [
    cacheLimitMB,
    cacheSizeMB,
    cacheFileCount,
    isClearing,
    crossfadeSeconds,
    volumeNormalization,
  ];
}
