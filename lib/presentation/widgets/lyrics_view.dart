import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme/app_colors.dart';
import '../../domain/entities/lyrics.dart';
import '../blocs/lyrics/lyrics_cubit.dart';
import '../blocs/player/player_bloc.dart';

/// Exibição de letras da música atual.
///
/// Suporta letras sincronizadas (LRC) com scroll automático
/// e highlights na linha atual, ou letras plain text.
class LyricsView extends StatelessWidget {
  const LyricsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle.
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Letras',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<LyricsCubit, LyricsState>(
                  builder: (context, lyricsState) {
                    return switch (lyricsState.status) {
                      LyricsStatus.initial ||
                      LyricsStatus.loading => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.lilac,
                        ),
                      ),
                      LyricsStatus.notFound => const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lyrics_rounded,
                              size: 48,
                              color: AppColors.onSurfaceVariant,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Letras não encontradas',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      LyricsStatus.error => Center(
                        child: Text(
                          lyricsState.errorMessage ?? 'Erro desconhecido',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                      LyricsStatus.loaded => _LyricsContent(
                        lyrics: lyricsState.lyrics!,
                        scrollController: scrollController,
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LyricsContent extends StatelessWidget {
  const _LyricsContent({required this.lyrics, required this.scrollController});

  final Lyrics lyrics;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (lyrics.instrumental) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded, size: 48, color: AppColors.lilac),
            SizedBox(height: 16),
            Text(
              '♪ Instrumental ♪',
              style: TextStyle(
                color: AppColors.lilac,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Se letras sincronizadas disponíveis, usa scroll sync.
    if (lyrics.hasSyncedLyrics) {
      return _SyncedLyricsView(
        lines: lyrics.parsedSyncedLyrics,
        scrollController: scrollController,
      );
    }

    // Fallback para letras plain text.
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      child: Text(
        lyrics.plainLyrics ?? '',
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 16,
          height: 2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Letras sincronizadas com destaque na linha atual.
class _SyncedLyricsView extends StatefulWidget {
  const _SyncedLyricsView({
    required this.lines,
    required this.scrollController,
  });

  final List<LyricsLine> lines;
  final ScrollController scrollController;

  @override
  State<_SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends State<_SyncedLyricsView> {
  int _currentLineIndex = -1;
  final GlobalKey _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (prev, curr) => prev.position != curr.position,
      listener: (context, state) {
        final position = state.position;
        int newIndex = -1;

        for (int i = widget.lines.length - 1; i >= 0; i--) {
          if (position >= widget.lines[i].timestamp) {
            newIndex = i;
            break;
          }
        }

        if (newIndex != _currentLineIndex) {
          setState(() => _currentLineIndex = newIndex);
        }
      },
      child: ListView.builder(
        key: _listKey,
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: widget.lines.length,
        itemBuilder: (context, index) {
          final line = widget.lines[index];
          final isCurrent = index == _currentLineIndex;
          final isPast = index < _currentLineIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isCurrent
                    ? AppColors.lilac
                    : isPast
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface.withValues(alpha: .6),
                fontSize: isCurrent ? 20 : 16,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              child: Text(
                line.text.isEmpty ? '♪' : line.text,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
