import 'package:flutter/material.dart';

import 'app.dart';
import 'di/app_dependencies.dart';

/// Boots the app. Prefer flavor entrypoints (`main_staging.dart`, …).
///
/// `--dart-define=ENV=staging` overrides [environment] so a mistaken
/// `lib/main.dart` target still hits Core instead of localhost (which
/// surfaces Places search as "Sem conexão").
Future<void> bootstrap({required String environment}) async {
  WidgetsFlutterBinding.ensureInitialized();

  const envDefine = String.fromEnvironment('ENV');
  final resolved =
      envDefine.isNotEmpty ? envDefine : environment;

  final deps = await AppDependencies.create(environment: resolved);

  runApp(
    TwoGoApp(
      environment: resolved,
      sessionCubit: deps.sessionCubit,
      authRepository: deps.authRepository,
      dependencies: deps,
    ),
  );
}
