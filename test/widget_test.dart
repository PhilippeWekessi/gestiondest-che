// Test de base pour l'application Ziko.
//
// Vérifie que l'application démarre correctement sur le parcours de connexion.

import 'package:flutter_test/flutter_test.dart';

import 'package:gesttache/main.dart';

void main() {
  testWidgets('L\'application démarre sur l\'écran de connexion', (
    WidgetTester tester,
  ) async {
    // Construit l'application et déclenche un frame.
    await tester.pumpWidget(const ZikoApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Ziko'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });
}
