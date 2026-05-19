// CIRO — main.dart
// App entry point. Loads .env securely before runApp.
// Initializes ScenarioEngine with default G-10 scenario.
// App runs cleanly even if .env is missing.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'navigation/app_navigator.dart';
import 'services/scenario_engine.dart';
import 'services/app_config.dart';
import 'services/notification_service.dart';
import 'services/user_profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Load .env securely — silently continues if file is absent
  await AppConfig.load();
  await UserProfileService.instance.load();

  // Initialize engine with default G-10 flooding scenario
  ScenarioEngine.instance.initialize();
  await NotificationService.instance.initialize();

  runApp(const CiroApp());
}

class CiroApp extends StatelessWidget {
  const CiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CIRO — Crisis Intelligence & Response Orchestrator',
      debugShowCheckedModeBanner: false,
      theme: CiroTheme.dark,
      routerConfig: appRouter,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
    );
  }
}
