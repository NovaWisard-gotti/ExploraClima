import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/models/attempt.dart';
import '../../data/models/climate_period.dart';
import '../../data/models/decision.dart';
import '../../data/models/indicator.dart';
import '../../state/providers.dart';
import '../widgets/charts.dart';

/// Comparación de dos intentos del mismo escenario.
class AttemptsCompareScreen extends ConsumerStatefulWidget {
  const AttemptsCompareScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  ConsumerState<AttemptsCompareScreen> createState() =>
      _AttemptsCompareScreenState();
}

class _AttemptsCompareScreenState extends ConsumerState<AttemptsCompareScreen> {
  String? _idA;
  String? _idB;
  bool _registered = false;

  @override
  Widget build(BuildContext context) {
    final attempts = ref.watch(attemptsForScenarioProvider(widget.scenarioId));
    final palette = context.palette;

    if (attempts.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comparación de intentos')),
        body: const EmptyState(
          icon: Icons.compare_arrows,
          title: 'Se necesitan dos intentos',
          message:
              'Completa el escenario al menos dos veces con decisiones '
              'distintas para poder comparar los resultados.',
        ),
      );
    }

    final attemptA = attempts.firstWhere(
      (a) => a.id == _idA,
      orElse: () => attempts.first,
    );
    final attemptB = attempts.firstWhere(
      (a) => a.id == _idB && a.id != attemptA.id,
      orElse: () => attempts.firstWhere((a) => a.id != attemptA.id),
    );

    if (!_registered) {
      _registered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(countersProvider.notifier).registerAttemptComparison();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Comparación de intentos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: <Widget>[
          Text(
            attemptA.scenarioName,
            style: context.texts.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Observa qué decisiones cambiaron y qué consecuencias fueron '
            'diferentes.',
            style: context.texts.bodySmall
                ?.copyWith(color: palette.neutral, height: 1.45),
          ),
          const SizedBox(height: 16),
          _AttemptPicker(
            label: 'Primer intento',
            badge: 'A',
            color: palette.seriesA,
            attempts: attempts,
            selectedId: attemptA.id,
            onChanged: (value) => setState(() => _idA = value),
          ),
          const SizedBox(height: 10),
          _AttemptPicker(
            label: 'Segundo intento',
            badge: 'B',
            color: palette.seriesB,
            attempts: attempts,
            selectedId: attemptB.id,
            onChanged: (value) => setState(() => _idB = value),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Estrategia y resultado',
            icon: Icons.route_outlined,
          ),
          Panel(
            child: Column(
              children: <Widget>[
                _TextComparisonRow(
                  label: 'Estrategia',
                  valueA: attemptA.strategy,
                  valueB: attemptB.strategy,
                ),
                Divider(color: context.scheme.outlineVariant, height: 20),
                _TextComparisonRow(
                  label: 'Resultado',
                  valueA: attemptA.outcome,
                  valueB: attemptB.outcome,
                ),
                Divider(color: context.scheme.outlineVariant, height: 20),
                _TextComparisonRow(
                  label: 'Mitigación / adaptación',
                  valueA:
                      '${attemptA.mitigationCount} / ${attemptA.adaptationCount}',
                  valueB:
                      '${attemptB.mitigationCount} / ${attemptB.adaptationCount}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Decisiones por periodo',
            subtitle: 'Se destacan los momentos en que elegiste distinto.',
            icon: Icons.alt_route,
          ),
          for (var i = 0; i < attemptA.choices.length; i++)
            _ChoiceComparison(
              choiceA: attemptA.choices[i],
              choiceB: i < attemptB.choices.length ? attemptB.choices[i] : null,
            ),
          const SizedBox(height: 8),
          const SectionHeader(
            title: 'Indicadores finales',
            subtitle: 'Barra sólida: intento A. Barra con trama: intento B.',
            icon: Icons.bar_chart,
          ),
          Panel(
            child: Column(
              children: <Widget>[
                for (final indicator in kAllIndicators)
                  _IndicatorComparison(
                    indicator: indicator,
                    valueA: attemptA.finalState.get(indicator),
                    valueB: attemptB.finalState.get(indicator),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SimulatedDataNotice(),
        ],
      ),
    );
  }
}

class _AttemptPicker extends StatelessWidget {
  const _AttemptPicker({
    required this.label,
    required this.badge,
    required this.color,
    required this.attempts,
    required this.selectedId,
    required this.onChanged,
  });

  final String label;
  final String badge;
  final Color color;
  final List<AttemptRecord> attempts;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Panel(
      borderColor: withOpacityValue(color, 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                badge,
                style: context.texts.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.palette.neutral),
                ),
                DropdownButton<String>(
                  value: selectedId,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: context.palette.surfaceElevated,
                  iconEnabledColor: context.scheme.onSurface,
                  items: <DropdownMenuItem<String>>[
                    for (final attempt in attempts)
                      DropdownMenuItem<String>(
                        value: attempt.id,
                        child: Text(
                          '${Formats.shortDate(attempt.date)} · '
                          '${attempt.strategy}',
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) onChanged(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextComparisonRow extends StatelessWidget {
  const _TextComparisonRow({
    required this.label,
    required this.valueA,
    required this.valueB,
  });

  final String label;
  final String valueA;
  final String valueB;

  @override
  Widget build(BuildContext context) {
    final same = valueA == valueB;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: context.palette.neutral,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'A · $valueA',
                style: context.texts.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.palette.seriesA,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'B · $valueB',
                style: context.texts.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.palette.seriesB,
                ),
              ),
            ),
          ],
        ),
        if (same)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Sin diferencia entre intentos.',
              style: context.texts.labelSmall
                  ?.copyWith(color: context.palette.neutral),
            ),
          ),
      ],
    );
  }
}

class _ChoiceComparison extends StatelessWidget {
  const _ChoiceComparison({required this.choiceA, required this.choiceB});

  final AttemptChoice choiceA;
  final AttemptChoice? choiceB;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final different = choiceB == null || choiceA.optionId != choiceB!.optionId;

    return Panel(
      margin: const EdgeInsets.only(bottom: 10),
      borderColor: different ? withOpacityValue(context.scheme.tertiary, 0.6) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${choiceA.period.label} · ${choiceA.stageTitle}',
                  style: context.texts.labelSmall?.copyWith(
                    color: palette.neutral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (different)
                Tag(
                  label: 'Decisión distinta',
                  icon: Icons.swap_horiz,
                  color: context.scheme.tertiary,
                  filled: true,
                ),
            ],
          ),
          const SizedBox(height: 10),
          _ChoiceLine(
            badge: 'A',
            color: palette.seriesA,
            title: choiceA.optionTitle,
            type: choiceA.realType.shortLabel,
          ),
          const SizedBox(height: 8),
          if (choiceB != null)
            _ChoiceLine(
              badge: 'B',
              color: palette.seriesB,
              title: choiceB!.optionTitle,
              type: choiceB!.realType.shortLabel,
            )
          else
            Text(
              'El segundo intento no registró esta etapa.',
              style: context.texts.labelSmall
                  ?.copyWith(color: palette.neutral),
            ),
        ],
      ),
    );
  }
}

class _ChoiceLine extends StatelessWidget {
  const _ChoiceLine({
    required this.badge,
    required this.color,
    required this.title,
    required this.type,
  });

  final String badge;
  final Color color;
  final String title;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          badge,
          style: context.texts.labelSmall
              ?.copyWith(fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: context.texts.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600, height: 1.35),
              ),
              Text(
                type,
                style: context.texts.labelSmall
                    ?.copyWith(color: context.palette.neutral),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndicatorComparison extends StatelessWidget {
  const _IndicatorComparison({
    required this.indicator,
    required this.valueA,
    required this.valueB,
  });

  final ClimateIndicator indicator;
  final double valueA;
  final double valueB;

  @override
  Widget build(BuildContext context) {
    final meta = metaOf(indicator);
    final palette = context.palette;
    final difference = valueA - valueB;
    final threshold = meta.decimals > 0 ? 0.005 : 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(meta.icon, size: 15, color: palette.forIndicator(indicator)),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  meta.label,
                  style: context.texts.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (difference.abs() < threshold)
                Text(
                  'Igual',
                  style: context.texts.labelSmall
                      ?.copyWith(color: palette.neutral),
                )
              else
                DeltaChip(
                  indicator: indicator,
                  delta: difference,
                  dense: true,
                ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              SizedBox(
                width: 16,
                child: Text(
                  'A',
                  style: context.texts.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.seriesA,
                  ),
                ),
              ),
              Expanded(
                child: ComparisonBar(
                  fraction: meta.normalize(valueA),
                  color: palette.seriesA,
                  striped: false,
                ),
              ),
              SizedBox(
                width: 58,
                child: Text(
                  meta.formatWithUnit(valueA),
                  textAlign: TextAlign.right,
                  style: context.texts.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              SizedBox(
                width: 16,
                child: Text(
                  'B',
                  style: context.texts.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.seriesB,
                  ),
                ),
              ),
              Expanded(
                child: ComparisonBar(
                  fraction: meta.normalize(valueB),
                  color: palette.seriesB,
                  striped: true,
                ),
              ),
              SizedBox(
                width: 58,
                child: Text(
                  meta.formatWithUnit(valueB),
                  textAlign: TextAlign.right,
                  style: context.texts.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
