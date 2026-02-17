import 'package:get_it/get_it.dart';

import 'package:firelink_audio/data/datasources/lyrics_datasource.dart';
import 'package:firelink_audio/data/datasources/soundcloud_datasource.dart';
import 'package:firelink_audio/data/repositories/lyrics_repository_impl.dart';
import 'package:firelink_audio/data/repositories/music_repository_impl.dart';
import 'package:firelink_audio/domain/repositories/lyrics_repository.dart';
import 'package:firelink_audio/domain/repositories/music_repository.dart';
import 'package:firelink_audio/presentation/blocs/home/home_cubit.dart';
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

  // ── Repositories ───────────────────────────────────────
  sl.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(soundCloudDataSource: sl<SoundCloudDataSource>()),
  );
  sl.registerLazySingleton<LyricsRepository>(
    () => LyricsRepositoryImpl(lyricsDataSource: sl<LyricsDataSource>()),
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
}
