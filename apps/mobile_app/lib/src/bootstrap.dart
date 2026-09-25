import 'package:flutter/material.dart';

import 'app.dart';
import 'di/app_dependencies.dart';

Future<void> bootstrap({required String environment}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final deps = await AppDependencies.create(environment: environment);

  runApp(
    TwoGoApp(
      environment: environment,
      sessionCubit: deps.sessionCubit,
      authRepository: deps.authRepository,
      dependencies: deps,
    ),
  );
}
