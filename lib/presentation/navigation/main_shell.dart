import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/player/player_bloc.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/search_screen.dart';
import '../widgets/mini_player.dart';

/// Shell principal com BottomNavigationBar e mini player.
///
/// Mantém estado das tabs via [IndexedStack] e exibe o
/// [MiniPlayer] persistente acima da barra de navegação.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [HomeScreen(), SearchScreen(), LibraryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player acima da navbar.
          const MiniPlayer(),

          // Barra de navegação.
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.divider.withValues(alpha: .5),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  activeIcon: Icon(Icons.search_rounded),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_rounded),
                  activeIcon: Icon(Icons.library_music_rounded),
                  label: 'Biblioteca',
                ),
              ],
            ),
          ),
        ],
      ),

      // Listener para erros do player (exibe SnackBar).
      // Envolvemos o body com BlocListener no nível correto.
      // Usando builder para evitar conflito — o listener está aqui:
      extendBody: false,
      resizeToAvoidBottomInset: false,
    );
  }
}

/// Wrapper que adiciona BlocListener para erros do player.
class MainShellWithListener extends StatelessWidget {
  const MainShellWithListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (prev, curr) => curr.status == PlayerStatus.error,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: const MainShell(),
    );
  }
}
