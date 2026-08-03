import 'package:flutter/material.dart';
import 'app.dart';

void bootstrap({required String environment}) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TwoGoApp(environment: environment));
}
