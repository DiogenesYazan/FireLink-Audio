import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../widgets/gradient_background.dart';

/// Tela de biblioteca (placeholder para funcionalidade futura).
///
/// Em uma implementação completa, exibiria playlists salvas,
/// músicas curtidas e histórico de reprodução.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──────────────────────────────────
            const SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Text('Biblioteca'),
            ),

            // ── Conteúdo placeholder ────────────────────
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.library_music_rounded,
                        size: 40,
                        color: AppColors.lilac,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sua biblioteca',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Em breve: playlists, favoritos e\nhistórico de reprodução.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: null, // Desabilitado (placeholder).
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Criar playlist'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
