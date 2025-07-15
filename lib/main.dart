import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('kn'),
        Locale('mr'),
      ],
      path: 'lib/l10n', // Folder containing JSON files
      fallbackLocale: const Locale('en'),
      child: const ProjectKisanApp(),
    ),
  );
}
