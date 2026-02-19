import 'package:get_it/get_it.dart';

import 'package:firelink_audio/data/datasources/cache_manager.dart';
import 'package:firelink_audio/data/datasources/local_storage_datasource.dart';
import 'package:firelink_audio/data/datasources/offline_manager.dart';

import 'package:firelink_audio/data/datasources/lyrics_datasource.dart';
import 'package:firelink_audio/data/datasources/youtube_datasource.dart';
import 'package:firelink_audio/data/repositories/liked_songs_repository_impl.dart';
import 'package:firelink_audio/data/repositories/lyrics_repository_impl.dart';
import 'package:firelink_audio/data/repositories/youtube_music_repository.dart';
import 'package:firelink_audio/domain/repositories/liked_songs_repository.dart';
import 'package:firelink_audio/domain/repositories/lyrics_repository.dart';
import 'package:firelink_audio/domain/repositories/music_repository.dart';
import 'package:firelink_audio/presentation/blocs/history/history_cubit.dart';
import 'package:firelink_audio/presentation/blocs/home/home_cubit.dart';
import 'package:firelink_audio/presentation/blocs/liked_songs/liked_songs_cubit.dart';
import 'package:firelink_audio/presentation/blocs/lyrics/lyrics_cubit.dart';
import 'package:firelink_audio/presentation/blocs/offline/offline_cubit.dart';
import 'package:firelink_audio/presentation/blocs/player/player_bloc.dart';
import 'package:firelink_audio/presentation/blocs/search/search_bloc.dart';
import 'package:firelink_audio/presentation/blocs/settings/settings_cubit.dart';
import 'package:firelink_audio/presentation/blocs/sleep_timer/sleep_timer_cubit.dart';
import 'package:firelink_audio/presentation/blocs/playlist/playlist_cubit.dart';
import 'package:firelink_audio/presentation/blocs/theme/dynamic_theme_cubit.dart';
import 'package:firelink_audio/data/datasources/playlist_manager.dart';

/// Service locator global para injeção de dependências.
final sl = GetIt.instance;

/// Registra todas as dependências no container.
///
/// Chamado uma vez no [main] antes de [runApp].
/// Idempotente — seguro para hot restart (allowReassignment).
void setupDependencies() {
  // Permite hot restart sem "already registered" errors.
  sl.allowReassignment = true;
  // ── DataSources ────────────────────────────────────────
  sl.registerLazySingleton<YoutubeDataSource>(() => YoutubeDataSource());
  sl.registerLazySingleton<LyricsDataSource>(() => LyricsDataSource());
  sl.registerLazySingleton<LocalStorageDatasource>(
    () => LocalStorageDatasource(),
  );
  sl.registerLazySingleton<CacheManager>(() => CacheManager());
  sl.registerLazySingleton<OfflineManager>(
    () => OfflineManager(youtubeDataSource: sl<YoutubeDataSource>()),
  );

  // ── Repositories ───────────────────────────────────────
  sl.registerLazySingleton<MusicRepository>(
    () => YoutubeMusicRepository(youtubeDataSource: sl<YoutubeDataSource>()),
  );
  sl.registerLazySingleton<LyricsRepository>(
    () => LyricsRepositoryImpl(lyricsDataSource: sl<LyricsDataSource>()),
  );
  sl.registerLazySingleton<LikedSongsRepository>(
    () => LikedSongsRepositoryImpl(
      localStorageDatasource: sl<LocalStorageDatasource>(),
    ),
  );

  // ── BLoCs / Cubits ─────────────────────────────────────

  // PlayerBloc é singleton (persiste durante toda a vida do app).
  sl.registerLazySingleton<PlayerBloc>(
    () => PlayerBloc(musicRepository: sl<MusicRepository>()),
  );

  // SearchBloc pode ser recriado (factory), mas usaremos singleton
  // para manter resultados ao navegar entre tabs.
  sl.registerLazySingleton<SearchBloc>(
    () => SearchBloc(musicRepository: sl<MusicRepository>()),
  );

  // LyricsCubit recriado por track (factory).
  sl.registerFactory<LyricsCubit>(
    () => LyricsCubit(lyricsRepository: sl<LyricsRepository>()),
  );

  // HomeCubit carrega trending automaticamente ao ser criado.
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(musicRepository: sl<MusicRepository>()),
  );

  // LikedSongsCubit é singleton — compartilhado por todas as telas.
  sl.registerLazySingleton<LikedSongsCubit>(
    () => LikedSongsCubit(likedSongsRepository: sl<LikedSongsRepository>()),
  );

  // HistoryCubit é singleton — mantém histórico global.
  sl.registerLazySingleton<HistoryCubit>(
    () => HistoryCubit(localStorageDatasource: sl<LocalStorageDatasource>()),
  );

  // SettingsCubit é singleton — gerencia preferências e cache.
  sl.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(cacheManager: sl<CacheManager>()),
  );

  // OfflineCubit é singleton — gerencia downloads em background.
  sl.registerLazySingleton<OfflineCubit>(
    () => OfflineCubit(offlineManager: sl<OfflineManager>()),
  );

  // SleepTimerCubit é singleton — gerencia timer global.
  sl.registerLazySingleton<SleepTimerCubit>(
    () => SleepTimerCubit(playerBloc: sl<PlayerBloc>()),
  );

  // PlaylistManager — CRUD de playlists locais.
  sl.registerLazySingleton<PlaylistManager>(() => PlaylistManager());

  // PlaylistCubit — gerencia estado de playlists.
  sl.registerLazySingleton<PlaylistCubit>(
    () => PlaylistCubit(playlistManager: sl<PlaylistManager>()),
  );

  // DynamicThemeCubit — tema baseado na arte do álbum.
  sl.registerLazySingleton<DynamicThemeCubit>(() => DynamicThemeCubit());
}
