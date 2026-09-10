import 'package:exploraclima/app.dart';
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
    expect(find.text('Comparador climático'), findsWidgets);
    expect(find.text('Huella de carbono'), findsWidgets);
  });
}
