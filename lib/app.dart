import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/di/service_locator.dart';
import 'config/theme/app_theme.dart';
import 'presentation/blocs/history/history_cubit.dart';
import 'presentation/blocs/liked_songs/liked_songs_cubit.dart';
import 'presentation/blocs/player/player_bloc.dart';
import 'presentation/blocs/search/search_bloc.dart';
import 'presentation/navigation/main_shell.dart';

/// Widget raiz do aplicativo FireLink Audio.
class FireLinkApp extends StatelessWidget {
  const FireLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // PlayerBloc global — persiste durante toda a vida do app.
        BlocProvider<PlayerBloc>.value(value: sl<PlayerBloc>()),
        // SearchBloc global — mantém resultados ao navegar.
        BlocProvider<SearchBloc>.value(value: sl<SearchBloc>()),
        // LikedSongsCubit global — gerencia músicas curtidas.
        BlocProvider<LikedSongsCubit>.value(value: sl<LikedSongsCubit>()),
        // HistoryCubit global — mantém histórico de reprodução.
        BlocProvider<HistoryCubit>.value(value: sl<HistoryCubit>()),
      ],
      child: MaterialApp(
        title: 'FireLink Audio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainShellWithListener(),
      ),
    );
  }
}
