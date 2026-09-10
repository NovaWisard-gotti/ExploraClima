import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../state/providers.dart';
import '../carbon/carbon_screen.dart';
import '../energy/energy_screen.dart';
import '../glossary/glossary_screen.dart';
import '../history/history_screen.dart';
import '../shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const _HomeHeader(),
        const SizedBox(height: 18),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStat(
                      value: '${progress.exploredScenarios.length}'
                          '/${progress.totalScenarios}',
                      label: 'Escenarios explorados',
                    ),
                  ),
                  _VerticalDivider(),
                  Expanded(
                    child: _MiniStat(
                      value: '${progress.counters.comparisons}',
                      label: 'Comparaciones',
                    ),
                  ),
                  _VerticalDivider(),
                  Expanded(
                    child: _MiniStat(
                      value: '${progress.decisions}',
                      label: 'Decisiones analizadas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.scenarioCoverage,
                  minHeight: 7,
                  backgroundColor: context.palette.surfaceSunken,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(context.scheme.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _PrimaryAction(
          title: 'Explorar futuros climáticos',
          description:
              'Recorre la línea temporal de un escenario, analiza sus '
              'indicadores y decide qué medidas aplicar.',
          icon: Icons.travel_explore_outlined,
          onTap: () => ref.read(shellIndexProvider.notifier).state = 1,
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Herramientas de análisis',
          subtitle: 'Comparar, medir y consultar durante la exploración.',
        ),
        _ToolTile(
          icon: Icons.compare_arrows,
          title: 'Comparador climático',
          subtitle: 'Enfrenta dos escenarios indicador por indicador.',
          onTap: () => ref.read(shellIndexProvider.notifier).state = 2,
        ),
        _ToolTile(
          icon: Icons.eco_outlined,
          title: 'Huella de carbono',
          subtitle: 'Qué actividades pesan más y cómo reducirlas.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CarbonScreen()),
          ),
        ),
        _ToolTile(
          icon: Icons.bolt_outlined,
          title: 'Energía y decisiones',
          subtitle: 'Efecto de la matriz energética sobre las emisiones.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const EnergyScreen()),
          ),
        ),
        _ToolTile(
          icon: Icons.history,
          title: 'Historial de escenarios',
          subtitle: 'Revisa y compara tus intentos anteriores.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
          ),
        ),
        _ToolTile(
          icon: Icons.menu_book_outlined,
          title: 'Consulta rápida',
          subtitle: 'Definiciones breves de los conceptos clave.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const GlossaryScreen()),
          ),
        ),
        const SizedBox(height: 16),
        const SimulatedDataNotice(),
      ],
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppTheme.nightBlueDeep,
            AppTheme.nightBlue,
            Color(0xFF243A7A),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'ExploraClima',
                      style: context.texts.headlineSmall?.copyWith(
                        color: AppTheme.ivory,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explorador de futuros climáticos',
                      style: context.texts.labelMedium?.copyWith(
                        color: AppTheme.coralSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tema de la aplicación',
                onPressed: () => _showThemeSheet(context, ref, themeMode),
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : themeMode == ThemeMode.light
                          ? Icons.light_mode_outlined
                          : Icons.brightness_auto_outlined,
                  color: AppTheme.ivory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Situación actual → escenario futuro → comparación → '
            'interpretación → decisión → consecuencias.',
            style: context.texts.bodySmall?.copyWith(
              color: withOpacityValue(AppTheme.ivory, 0.85),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Tema de la aplicación',
                  style: sheetContext.texts.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'El modo automático sigue la configuración del dispositivo.',
                  style: sheetContext.texts.bodySmall
                      ?.copyWith(color: sheetContext.palette.neutral),
                ),
                const SizedBox(height: 12),
                for (final entry in <MapEntry<ThemeMode, String>>[
                  const MapEntry(ThemeMode.system, 'Automático (sistema)'),
                  const MapEntry(ThemeMode.light, 'Modo claro'),
                  const MapEntry(ThemeMode.dark, 'Modo oscuro'),
                ])
                  RadioListTile<ThemeMode>(
                    value: entry.key,
                    groupValue: current,
                    title: Text(entry.value),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      if (value == null) return;
                      ref.read(themeModeProvider.notifier).setMode(value);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: context.texts.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.scheme.primary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: context.texts.labelSmall
              ?.copyWith(color: context.palette.neutral, height: 1.3),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: context.scheme.outlineVariant,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Panel(
      onTap: onTap,
      borderColor: scheme.primary,
      background: withOpacityValue(scheme.primary, context.isDark ? 0.16 : 0.07),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: scheme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.texts.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.palette.neutral,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 15, color: scheme.primary),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Panel(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.palette.surfaceSunken,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: context.scheme.outlineVariant),
            ),
            child: Icon(icon, size: 19, color: context.scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.texts.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.palette.neutral, height: 1.3),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.palette.neutral),
        ],
      ),
    );
  }
}
