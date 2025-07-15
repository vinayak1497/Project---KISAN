import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:project_kisan/app.dart'; // ✅ your main app widget

void main() {
  testWidgets('Home screen loads and shows Talk to AI button', (WidgetTester tester) async {
    // Wrap app with EasyLocalization, just like in main.dart
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('kn'),
          Locale('mr'),
        ],
        path: 'lib/l10n',
        fallbackLocale: const Locale('en'),
        child: const ProjectKisanApp(), // ✅ This is your real app widget
      ),
    );

    await tester.pumpAndSettle();

    // ✅ Check for a known label (make sure it's the exact text shown in UI)
    expect(find.text('Talk to AI'), findsOneWidget);
  });
}
