import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/carbon.dart';
import '../../data/scenarios/reference_data.dart';
import '../../state/providers.dart';

/// Análisis simplificado de huella de carbono.
///
/// No es una calculadora certificada: compara el peso relativo de distintas
/// actividades y muestra cuánto podría reducirse cambiando decisiones.
class CarbonScreen extends ConsumerStatefulWidget {
  const CarbonScreen({super.key});

  @override
  ConsumerState<CarbonScreen> createState() => _CarbonScreenState();
}

class _CarbonScreenState extends ConsumerState<CarbonScreen> {
  double? _reference;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(carbonProfileProvider);
    final palette = context.palette;
    final total = CarbonData.totalFor(profile);
    final minimum = CarbonData.minimumTotal;
    final maximum = CarbonData.maximumTotal;

    final entries = <_CategoryValue>[
      for (final category in CarbonData.categories)
        _CategoryValue(
          category: category,
          option: category.optionById(
            profile.selection[category.id] ?? category.options.first.id,
          ),
        ),
    ];
    entries.sort((a, b) =>
        b.option.relativeValue.compareTo(a.option.relativeValue));

    return Scaffold(
      appBar: AppBar(title: const Text('Huella de carbono')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: <Widget>[
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Huella relativa semanal',
                  style: context.texts.labelMedium
                      ?.copyWith(color: palette.neutral),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      total.toStringAsFixed(0),
                      style: context.texts.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'unidades relativas',
                      style: context.texts.labelSmall
                          ?.copyWith(color: palette.neutral),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StackedBreakdown(entries: entries, total: total),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Mínimo alcanzable: ${minimum.toStringAsFixed(0)} · '
                        'Máximo del modelo: ${maximum.toStringAsFixed(0)}',
                        style: context.texts.labelSmall
                            ?.copyWith(color: palette.neutral, height: 1.35),
                      ),
                    ),
                  ],
                ),
                if (_reference != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: withOpacityValue(
                        total <= _reference! ? palette.positive : palette.negative,
                        0.12,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      total <= _reference!
                          ? 'Reducción de ${(_reference! - total).toStringAsFixed(0)} '
                              'unidades respecto al perfil guardado.'
                          : 'Aumento de ${(total - _reference!).toStringAsFixed(0)} '
                              'unidades respecto al perfil guardado.',
                      style: context.texts.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Actividades analizadas',
            subtitle:
                'Elige la opción que mejor describe tu situación y observa '
                'cómo cambia el peso relativo.',
            icon: Icons.checklist_outlined,
          ),
          for (final category in CarbonData.categories)
            _CategoryPanel(
              category: category,
              selectedId: profile.selection[category.id] ??
                  category.options.first.id,
              onSelected: (optionId) {
                ref
                    .read(carbonProfileProvider.notifier)
                    .select(category.id, optionId);
              },
            ),
          const SizedBox(height: 6),
          const SectionHeader(
            title: 'Dónde está tu mayor emisión',
            icon: Icons.priority_high,
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'La actividad con mayor peso es '
                  '"${entries.first.category.label}" con '
                  '${entries.first.option.relativeValue.toStringAsFixed(0)} '
                  'unidades.',
                  style: context.texts.bodySmall?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 10),
                Text(
                  _reductionMessage(entries.first),
                  style: context.texts.bodySmall?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                setState(() => _reference = total);
                ref.read(countersProvider.notifier).registerCarbonAnalysis();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Perfil registrado. Cambia opciones para comparar la '
                      'reducción.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_added_outlined),
              label: const Text('Registrar perfil actual'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(carbonProfileProvider.notifier).resetProfile();
                setState(() => _reference = null);
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Restablecer perfil'),
            ),
          ),
          const SizedBox(height: 16),
          const SimulatedDataNotice(),
        ],
      ),
    );
  }

  String _reductionMessage(_CategoryValue entry) {
    final best = entry.category.lowest;
    if (best.id == entry.option.id) {
      return 'Ya seleccionaste la alternativa de menor huella en esta '
          'categoría.';
    }
    final saving = entry.option.relativeValue - best.relativeValue;
    return 'Cambiar a "${best.label}" reduciría aproximadamente '
        '${saving.toStringAsFixed(0)} unidades relativas: es la decisión con '
        'mayor efecto individual en tu perfil.';
  }
}

class _CategoryValue {
  const _CategoryValue({required this.category, required this.option});

  final CarbonCategory category;
  final CarbonOption option;
}

class _StackedBreakdown extends StatelessWidget {
  const _StackedBreakdown({required this.entries, required this.total});

  final List<_CategoryValue> entries;
  final double total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = <Color>[
      palette.emisiones,
      palette.energia,
      palette.vegetacion,
      palette.agua,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: Row(
              children: <Widget>[
                for (var i = 0; i < entries.length; i++)
                  Expanded(
                    flex: (entries[i].option.relativeValue * 10)
                        .round()
                        .clamp(1, 100000),
                    child: Container(color: colors[i % colors.length]),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: <Widget>[
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entries[i].category.label,
                    style: context.texts.labelSmall?.copyWith(
                      color: context.scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${entries[i].option.relativeValue.toStringAsFixed(0)} u '
                  '(${total == 0 ? 0 : ((entries[i].option.relativeValue / total) * 100).round()} %)',
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

class _CategoryPanel extends StatelessWidget {
  const _CategoryPanel({
    required this.category,
    required this.selectedId,
    required this.onSelected,
  });

  final CarbonCategory category;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Panel(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(category.icon, size: 18, color: context.scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.label,
                  style: context.texts.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            category.note,
            style: context.texts.labelSmall
                ?.copyWith(color: palette.neutral, height: 1.35),
          ),
          const SizedBox(height: 12),
          for (final option in category.options)
            _OptionTile(
              option: option,
              selected: option.id == selectedId,
              onTap: () => onSelected(option.id),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CarbonOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? withOpacityValue(scheme.primary, context.isDark ? 0.18 : 0.08)
              : context.palette.surfaceSunken,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 17,
              color: selected ? scheme.primary : context.palette.neutral,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    option.label,
                    style: context.texts.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.detail,
                    style: context.texts.labelSmall?.copyWith(
                      color: context.palette.neutral,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${option.relativeValue.toStringAsFixed(0)} u',
              style: context.texts.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
