import 'package:get_it/get_it.dart';

import 'package:firelink_audio/data/datasources/local_storage_datasource.dart';
import 'package:firelink_audio/data/datasources/lyrics_datasource.dart';
import 'package:firelink_audio/data/datasources/soundcloud_datasource.dart';
import 'package:firelink_audio/data/repositories/liked_songs_repository_impl.dart';
import 'package:firelink_audio/data/repositories/lyrics_repository_impl.dart';
import 'package:firelink_audio/data/repositories/music_repository_impl.dart';
import 'package:firelink_audio/domain/repositories/liked_songs_repository.dart';
import 'package:firelink_audio/domain/repositories/lyrics_repository.dart';
import 'package:firelink_audio/domain/repositories/music_repository.dart';
import 'package:firelink_audio/presentation/blocs/history/history_cubit.dart';
import 'package:firelink_audio/presentation/blocs/home/home_cubit.dart';
import 'package:firelink_audio/presentation/blocs/liked_songs/liked_songs_cubit.dart';
import 'package:firelink_audio/presentation/blocs/lyrics/lyrics_cubit.dart';
import 'package:firelink_audio/presentation/blocs/player/player_bloc.dart';
import 'package:firelink_audio/presentation/blocs/search/search_bloc.dart';

/// Service locator global para injeção de dependências.
final sl = GetIt.instance;

/// Registra todas as dependências no container.
///
/// Chamado uma vez no [main] antes de [runApp].
/// Idempotente — seguro para hot restart (allowReassignment).
void setupDependencies() {
  // Permite hot restart sem '"already registered" errors.
  sl.allowReassignment = true;
  // ── DataSources ────────────────────────────────────────
  sl.registerLazySingleton<SoundCloudDataSource>(() => SoundCloudDataSource());
  sl.registerLazySingleton<LyricsDataSource>(() => LyricsDataSource());
  sl.registerLazySingleton<LocalStorageDatasource>(
    () => LocalStorageDatasource(),
  );

  // ── Repositories ───────────────────────────────────────
  sl.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(soundCloudDataSource: sl<SoundCloudDataSource>()),
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
}
