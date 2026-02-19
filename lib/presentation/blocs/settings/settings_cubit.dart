import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/datasources/cache_manager.dart';
import 'settings_state.dart';

/// Cubit para gerenciar preferências do app e cache.
///
/// Persiste configurações via [SharedPreferences].
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required CacheManager cacheManager})
    : _cacheManager = cacheManager,
      super(const SettingsState()) {
    _loadSettings();
  }

  final CacheManager _cacheManager;

  static const String _cacheLimitKey = 'settings_cache_limit_mb';
  static const String _crossfadeKey = 'settings_crossfade_seconds';
  static const String _volumeNormKey = 'settings_volume_normalization';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLimit = prefs.getInt(_cacheLimitKey) ?? 500;
    final savedCrossfade = prefs.getInt(_crossfadeKey) ?? 0;
    final savedNorm = prefs.getBool(_volumeNormKey) ?? false;

    emit(
      state.copyWith(
        cacheLimitMB: savedLimit,
        crossfadeSeconds: savedCrossfade,
        volumeNormalization: savedNorm,
      ),
    );
    await refreshCacheInfo();
  }

  Future<void> refreshCacheInfo() async {
    try {
      final sizeBytes = await _cacheManager.getCacheSizeBytes();
      final sizeMB = sizeBytes / (1024 * 1024);
      final fileCount = await _cacheManager.getCacheFileCount();

      emit(state.copyWith(cacheSizeMB: sizeMB, cacheFileCount: fileCount));
    } catch (e) {
      debugPrint('SettingsCubit: Erro ao carregar info de cache: $e');
    }
  }

  Future<void> setCacheLimit(int limitMB) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheLimitKey, limitMB);
    emit(state.copyWith(cacheLimitMB: limitMB));
    await _cacheManager.enforceCacheLimit(limitMB);
    await refreshCacheInfo();
  }

  Future<void> clearCache() async {
    emit(state.copyWith(isClearing: true));
    await _cacheManager.clearCache();
    await refreshCacheInfo();
    emit(state.copyWith(isClearing: false));
  }

  Future<void> enforceCacheLimit() async {
    await _cacheManager.enforceCacheLimit(state.cacheLimitMB);
    await refreshCacheInfo();
  }

  /// Define a duração do crossfade (0-12 segundos).
  Future<void> setCrossfade(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_crossfadeKey, seconds);
    emit(state.copyWith(crossfadeSeconds: seconds));
  }

  /// Alterna a normalização de volume.
  Future<void> toggleVolumeNormalization() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.volumeNormalization;
    await prefs.setBool(_volumeNormKey, newValue);
    emit(state.copyWith(volumeNormalization: newValue));
  }
}
