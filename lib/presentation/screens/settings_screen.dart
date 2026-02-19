import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/settings/settings_cubit.dart';
import '../blocs/settings/settings_state.dart';
import '../widgets/gradient_background.dart';

/// Tela de Configurações Avançadas.
///
/// Permite gerenciar cache de áudio e preferências do app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Configurações'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Seção: Cache ────────────────────────────
                _buildSectionHeader(
                  icon: Icons.storage_rounded,
                  title: 'Cache de Áudio',
                ),
                const SizedBox(height: 12),

                // Info card.
                _buildInfoCard(state),

                const SizedBox(height: 16),

                // Slider de limite.
                _buildCacheLimitSlider(context, state),

                const SizedBox(height: 16),

                // Botão limpar cache.
                _buildClearCacheButton(context, state),

                const SizedBox(height: 32),

                // ── Seção: Reprodução ─────────────────────
                _buildSectionHeader(
                  icon: Icons.tune_rounded,
                  title: 'Reprodução',
                ),
                const SizedBox(height: 12),

                // Crossfade slider.
                _buildCrossfadeSlider(context, state),

                const SizedBox(height: 16),

                // Volume Normalization toggle.
                _buildVolumeNormalizationTile(context, state),

                const SizedBox(height: 32),

                // ── Seção: Sobre ────────────────────────────
                _buildSectionHeader(
                  icon: Icons.info_outline_rounded,
                  title: 'Sobre',
                ),
                const SizedBox(height: 12),
                _buildAboutCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lilac, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(SettingsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lilac.withValues(alpha: .15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                label: 'Tamanho usado',
                value: '${state.cacheSizeMB.toStringAsFixed(1)} MB',
                icon: Icons.folder_rounded,
              ),
              _buildInfoItem(
                label: 'Arquivos',
                value: '${state.cacheFileCount}',
                icon: Icons.audio_file_rounded,
              ),
              _buildInfoItem(
                label: 'Limite',
                value: '${state.cacheLimitMB} MB',
                icon: Icons.speed_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: state.cacheLimitMB > 0
                  ? (state.cacheSizeMB / state.cacheLimitMB).clamp(0.0, 1.0)
                  : 0.0,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.cacheSizeMB / state.cacheLimitMB > 0.8
                    ? AppColors.error
                    : AppColors.lilac,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.lilac, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCacheLimitSlider(BuildContext context, SettingsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lilac.withValues(alpha: .15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Limite de cache',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lilac.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.cacheLimitMB} MB',
                  style: const TextStyle(
                    color: AppColors.lilac,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: state.cacheLimitMB.toDouble(),
            min: 100,
            max: 15000,
            divisions: 149,
            label: '${state.cacheLimitMB} MB',
            onChanged: (value) {
              context.read<SettingsCubit>().setCacheLimit(value.toInt());
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '100 MB',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              Text(
                '15 GB',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClearCacheButton(BuildContext context, SettingsState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isClearing
            ? null
            : () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text(
                      'Limpar cache?',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                    content: Text(
                      'Isso vai apagar ${state.cacheFileCount} arquivos '
                      '(${state.cacheSizeMB.toStringAsFixed(1)} MB). '
                      'As músicas serão baixadas novamente na próxima vez.',
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Limpar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  context.read<SettingsCubit>().clearCache();
                }
              },
        icon: state.isClearing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete_sweep_rounded),
        label: Text(state.isClearing ? 'Limpando...' : 'Limpar todo o cache'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: .15),
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lilac.withValues(alpha: .15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FireLink Audio',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Player de música via YouTube com cache inteligente.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          SizedBox(height: 8),
          Text(
            'Versão 1.0.0',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                launchUrl(
                  Uri.parse('https://diogenesyuri.works/'),
                  mode: LaunchMode.externalApplication,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.lilac,
                side: const BorderSide(color: AppColors.lilac),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Visitar Portfolio'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrossfadeSlider(BuildContext context, SettingsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.lilac,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Crossfade',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                state.crossfadeSeconds == 0
                    ? 'Desativado'
                    : '${state.crossfadeSeconds}s',
                style: const TextStyle(
                  color: AppColors.lilac,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.lilac,
              inactiveTrackColor: AppColors.surfaceVariant,
              thumbColor: AppColors.lilac,
              overlayColor: AppColors.lilac.withValues(alpha: .2),
              trackHeight: 4,
            ),
            child: Slider(
              value: state.crossfadeSeconds.toDouble(),
              min: 0,
              max: 12,
              divisions: 12,
              label: state.crossfadeSeconds == 0
                  ? 'Off'
                  : '${state.crossfadeSeconds}s',
              onChanged: (value) {
                context.read<SettingsCubit>().setCrossfade(value.round());
              },
            ),
          ),
          const Text(
            'Transição suave entre músicas',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeNormalizationTile(
    BuildContext context,
    SettingsState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.equalizer_rounded, color: AppColors.lilac, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Normalização de Volume',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Volume consistente entre faixas',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.volumeNormalization,
            activeThumbColor: AppColors.lilac,
            onChanged: (_) {
              context.read<SettingsCubit>().toggleVolumeNormalization();
            },
          ),
        ],
      ),
    );
  }
}
