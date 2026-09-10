import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/models/attempt.dart';
import '../../state/providers.dart';
import '../compare/attempts_compare_screen.dart';
import 'attempt_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempts = ref.watch(attemptsProvider);
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: <Widget>[
          if (attempts.isNotEmpty)
            IconButton(
              tooltip: 'Vaciar historial',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: attempts.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: 'Todavía no hay escenarios completados',
              message:
                  'Cuando termines un escenario, su informe quedará guardado '
                  'aquí para revisarlo o compararlo con otros intentos.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: <Widget>[
                Text(
                  '${attempts.length} '
                  '${attempts.length == 1 ? 'escenario completado' : 'escenarios completados'}',
                  style: context.texts.bodySmall
                      ?.copyWith(color: palette.neutral, height: 1.4),
                ),
                const SizedBox(height: 12),
                for (final attempt in attempts)
                  _AttemptTile(
                    attempt: attempt,
                    canCompare: attempts
                            .where((a) => a.scenarioId == attempt.scenarioId)
                            .length >=
                        2,
                  ),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vaciar historial'),
        content: const Text(
          'Se eliminarán todos los intentos guardados en este dispositivo. '
          'Esta acción no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(attemptsProvider.notifier).clear();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

class _AttemptTile extends ConsumerWidget {
  const _AttemptTile({required this.attempt, required this.canCompare});

  final AttemptRecord attempt;
  final bool canCompare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return Panel(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AttemptDetailScreen(attemptId: attempt.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      attempt.scenarioName,
                      style: context.texts.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      Formats.dateTime(attempt.date),
                      style: context.texts.labelSmall
                          ?.copyWith(color: palette.neutral),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: palette.neutral),
                color: palette.surfaceElevated,
                onSelected: (value) {
                  switch (value) {
                    case 'detail':
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AttemptDetailScreen(attemptId: attempt.id),
                        ),
                      );
                      break;
                    case 'compare':
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AttemptsCompareScreen(
                            scenarioId: attempt.scenarioId,
                          ),
                        ),
                      );
                      break;
                    case 'delete':
                      ref.read(attemptsProvider.notifier).remove(attempt.id);
                      break;
                  }
                },
                itemBuilder: (menuContext) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'detail',
                    child: Text('Ver informe'),
                  ),
                  if (canCompare)
                    const PopupMenuItem<String>(
                      value: 'compare',
                      child: Text('Comparar intentos'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Eliminar intento'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Tag(
                label: attempt.strategy,
                icon: Icons.route_outlined,
                color: context.scheme.primary,
                filled: true,
              ),
              Tag(
                label: attempt.outcome,
                icon: Icons.flag_outlined,
                color: context.scheme.tertiary,
              ),
              Tag(
                label:
                    'Clasificación ${attempt.classificationHits}/${attempt.classificationTotal}',
                icon: Icons.fact_check_outlined,
                color: palette.positive,
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final choice in attempt.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.chevron_right, size: 15, color: palette.neutral),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${choice.period.shortLabel}: ${choice.optionTitle}',
                      style: context.texts.labelSmall?.copyWith(
                        color: palette.neutral,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
