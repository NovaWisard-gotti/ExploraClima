import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'compare/compare_screen.dart';
import 'home/home_screen.dart';
import 'progress/progress_screen.dart';
import 'scenarios/scenario_list_screen.dart';

/// Índice de la sección activa del shell.
final shellIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellIndexProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: const <Widget>[
            HomeScreen(),
            ScenarioListScreen(),
            CompareScreen(),
            ProgressScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) =>
            ref.read(shellIndexProvider.notifier).state = value,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Escenarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows),
            label: 'Comparar',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }
}
