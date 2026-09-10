import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/indicator.dart';
import '../../data/models/scenario.dart';
import '../../domain/scenario_engine.dart';
import '../../state/providers.dart';
import '../widgets/charts.dart';
import 'scenario_viewer_screen.dart';

class ScenarioListScreen extends ConsumerWidget {
  const ScenarioListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenarios = ref.watch(scenariosProvider);
    final attempts = ref.watch(attemptsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: <Widget>[
        Text(
          'Escenarios climáticos',
          style: context.texts.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Cada escenario plantea un territorio, una tendencia y tres momentos '
          'de decisión a lo largo de la línea temporal.',
          style: context.texts.bodySmall
              ?.copyWith(color: context.palette.neutral, height: 1.45),
        ),
        const SizedBox(height: 16),
        for (final scenario in scenarios)
          _ScenarioCard(
            scenario: scenario,
            attempts:
                attempts.where((a) => a.scenarioId == scenario.id).length,
          ),
        const SizedBox(height: 8),
        const SimulatedDataNotice(),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario, required this.attempts});

  final ClimateScenario scenario;
  final int attempts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = context.scheme;
    final indicator = scenario.highlightIndicators.first;
    final baseSeries = ScenarioEngine.series(scenario, indicator);

    return Panel(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ScenarioViewerScreen(scenarioId: scenario.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: withOpacityValue(scheme.primary, 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: withOpacityValue(scheme.primary, 0.35)),
                ),
                child: Icon(scenario.focus.icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      scenario.name,
                      style: context.texts.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scenario.tagline,
                      style: context.texts.labelSmall?.copyWith(
                        color: palette.neutral,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (attempts > 0)
                Tag(
                  label: attempts == 1 ? '1 intento' : '$attempts intentos',
                  icon: Icons.check_circle_outline,
                  color: palette.positive,
                  filled: true,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Tendencia sin intervención · '
                      '${metaOf(indicator).shortLabel}',
                      style: context.texts.labelSmall?.copyWith(
                        color: palette.neutral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Sparkline(
                      values: baseSeries,
                      color: palette.forIndicator(indicator),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    metaOf(indicator).format(baseSeries.first),
                    style: context.texts.labelSmall
                        ?.copyWith(color: palette.neutral),
                  ),
                  Icon(Icons.arrow_downward, size: 14, color: palette.neutral),
                  Text(
                    metaOf(indicator).format(baseSeries.last),
                    style: context.texts.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.forIndicator(indicator),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scenario.keyQuestion,
            style: context.texts.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Tag(
                label: scenario.focus.label,
                icon: scenario.focus.icon,
                color: scheme.tertiary,
              ),
              const Spacer(),
              Text(
                'Explorar',
                style: context.texts.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: scheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}
