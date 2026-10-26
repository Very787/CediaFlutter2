import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'studyflow/bindings/studyflow_binding.dart';
import 'studyflow/screens/auth_gate.dart';
import 'studyflow/theme/studyflow_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('studyflow_favorites');
  await Hive.openBox<String>('studyflow_drafts');
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StudyFlow IA',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: StudyFlowTheme.light,
      initialBinding: StudyFlowBinding(),
      home: const AuthGate(),
    );
  }
}
