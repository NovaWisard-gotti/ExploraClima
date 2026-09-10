import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/common.dart';
import '../../data/models/carbon.dart';
import '../../data/scenarios/reference_data.dart';
import '../../state/providers.dart';

/// Consulta rápida: definiciones breves y contextuales.
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _expandedTerm;
  bool _registered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final query = _query.trim().toLowerCase();
    final entries = GlossaryData.entries.where((entry) {
      if (query.isEmpty) return true;
      return entry.term.toLowerCase().contains(query) ||
          entry.definition.toLowerCase().contains(query);
    }).toList();

    final groups = <String>[];
    for (final entry in entries) {
      if (!groups.contains(entry.group)) groups.add(entry.group);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta rápida')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Buscar un concepto',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message:
                        'No hay conceptos que coincidan con la búsqueda. '
                        'ExploraClima incluye definiciones breves, no una '
                        'enciclopedia climática.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                    children: <Widget>[
                      for (final group in groups) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 6),
                          child: Text(
                            group.toUpperCase(),
                            style: context.texts.labelSmall?.copyWith(
                              color: palette.neutral,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        for (final entry
                            in entries.where((e) => e.group == group))
                          _GlossaryTile(
                            entry: entry,
                            expanded: _expandedTerm == entry.term,
                            onTap: () {
                              setState(() {
                                _expandedTerm =
                                    _expandedTerm == entry.term ? null : entry.term;
                              });
                              if (!_registered) {
                                _registered = true;
                                ref
                                    .read(countersProvider.notifier)
                                    .registerGlossaryConsult();
                              }
                            },
                          ),
                      ],
                      const SizedBox(height: 10),
                      const SimulatedDataNotice(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _GlossaryTile extends StatelessWidget {
  const _GlossaryTile({
    required this.entry,
    required this.expanded,
    required this.onTap,
  });

  final GlossaryEntry entry;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Panel(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      borderColor: expanded ? context.scheme.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.term,
                  style: context.texts.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: palette.neutral,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.definition,
            maxLines: expanded ? null : 2,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: context.texts.bodySmall?.copyWith(height: 1.45),
          ),
          if (expanded) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: context.scheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.explore_outlined,
                      size: 15, color: context.scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.example,
                      style: context.texts.labelSmall?.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
