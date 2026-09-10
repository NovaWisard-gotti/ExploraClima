import 'package:exploraclima/app.dart';
import 'package:exploraclima/presentation/home/home_screen.dart';
import 'package:exploraclima/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('la pantalla de inicio se construye correctamente',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ExploraClimaApp(),
      ),
    );
    await tester.pump();

    expect(find.text('ExploraClima'), findsWidgets);

    final homeScrollable = find.descendant(
      of: find.byType(HomeScreen),
      matching: find.byType(Scrollable),
    );

    await tester.scrollUntilVisible(
      find.text('Comparador climático'),
      300,
      scrollable: homeScrollable,
    );
    expect(find.text('Comparador climático'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Huella de carbono'),
      300,
      scrollable: homeScrollable,
    );
    expect(find.text('Huella de carbono'), findsWidgets);
  });
}
