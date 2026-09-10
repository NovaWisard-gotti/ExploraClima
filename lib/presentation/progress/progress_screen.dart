import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../state/providers.dart';
import '../history/history_screen.dart';
import '../scenarios/scenario_viewer_screen.dart';
import '../widgets/scenario_visual.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final scenarios = ref.watch(scenariosProvider);
    final attempts = ref.watch(attemptsProvider);
    final palette = context.palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: <Widget>[
        Text(
          'Progreso de aprendizaje',
          style: context.texts.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Registro de la actividad analítica realizada en ExploraClima.',
          style: context.texts.bodySmall
              ?.copyWith(color: palette.neutral, height: 1.45),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RatioBadge(
                value: progress.scenarioCoverage,
                label: 'Escenarios explorados',
              ),
              RatioBadge(
                value: progress.classificationTotal == 0
                    ? 0
                    : progress.classificationHits / progress.classificationTotal,
                label: 'Aciertos al clasificar medidas',
                color: palette.positive,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Actividad registrada',
          icon: Icons.analytics_outlined,
        ),
        Panel(
          child: Column(
            children: <Widget>[
              _ProgressRow(
                icon: Icons.travel_explore_outlined,
                label: 'Escenarios completados',
                value: '${progress.attempts}',
              ),
              _ProgressRow(
                icon: Icons.compare_arrows,
                label: 'Comparaciones entre escenarios',
                value: '${progress.counters.comparisons}',
              ),
              _ProgressRow(
                icon: Icons.history_toggle_off,
                label: 'Comparaciones entre intentos',
                value: '${progress.counters.attemptComparisons}',
              ),
              _ProgressRow(
                icon: Icons.alt_route,
                label: 'Decisiones analizadas',
                value: '${progress.decisions}',
              ),
              _ProgressRow(
                icon: Icons.trending_down,
                label: 'Medidas de mitigación practicadas',
                value: '${progress.mitigationMeasures}',
              ),
              _ProgressRow(
                icon: Icons.security_outlined,
                label: 'Medidas de adaptación practicadas',
                value: '${progress.adaptationMeasures}',
              ),
              _ProgressRow(
                icon: Icons.eco_outlined,
                label: 'Perfiles de huella analizados',
                value: '${progress.counters.carbonAnalyses}',
              ),
              _ProgressRow(
                icon: Icons.bolt_outlined,
                label: 'Exploraciones energéticas',
                value: '${progress.counters.energyExplorations}',
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Estado por escenario',
          icon: Icons.checklist_rtl,
        ),
        for (final scenario in scenarios)
          Panel(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ScenarioViewerScreen(scenarioId: scenario.id),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  progress.exploredScenarios.contains(scenario.id)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: progress.exploredScenarios.contains(scenario.id)
                      ? palette.positive
                      : palette.neutral,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        scenario.name,
                        style: context.texts.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _attemptsLabel(
                          attempts
                              .where((a) => a.scenarioId == scenario.id)
                              .length,
                        ),
                        style: context.texts.labelSmall
                            ?.copyWith(color: palette.neutral),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: palette.neutral),
              ],
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history),
            label: const Text('Abrir historial completo'),
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          background: withOpacityValue(context.scheme.tertiary, 0.08),
          borderColor: withOpacityValue(context.scheme.tertiary, 0.4),
          child: Text(
            'El progreso mide análisis realizado, no puntos acumulados: '
            'ExploraClima no utiliza niveles, monedas ni insignias.',
            style: context.texts.bodySmall?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }

  String _attemptsLabel(int count) {
    if (count == 0) return 'Sin intentos registrados';
    if (count == 1) return '1 intento guardado';
    return '$count intentos guardados';
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: context.scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.texts.bodySmall?.copyWith(height: 1.35),
                ),
              ),
              Text(
                value,
                style: context.texts.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (!last)
          Divider(height: 1, color: context.scheme.outlineVariant),
      ],
    );
  }
}
