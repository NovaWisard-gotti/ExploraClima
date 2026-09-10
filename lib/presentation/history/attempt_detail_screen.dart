import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/common.dart';
import '../../state/providers.dart';
import '../compare/attempts_compare_screen.dart';
import '../widgets/attempt_report.dart';

class AttemptDetailScreen extends ConsumerWidget {
  const AttemptDetailScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempts = ref.watch(attemptsProvider);
    final matching = attempts.where((a) => a.id == attemptId).toList();

    if (matching.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Informe')),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Intento no disponible',
          message: 'El registro fue eliminado del historial.',
        ),
      );
    }

    final attempt = matching.first;
    final sameScenario =
        attempts.where((a) => a.scenarioId == attempt.scenarioId).length;

    return Scaffold(
      appBar: AppBar(title: Text(attempt.scenarioName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: <Widget>[
          AttemptReportView(attempt: attempt),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: sameScenario < 2
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AttemptsCompareScreen(
                            scenarioId: attempt.scenarioId,
                          ),
                        ),
                      ),
              icon: const Icon(Icons.compare_arrows),
              label: Text(
                sameScenario < 2
                    ? 'Comparación de intentos (requiere 2)'
                    : 'Comparar intentos de este escenario',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
