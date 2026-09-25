import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum Environment { development, staging, production }

class ApiConfig {
  final Environment environment;
  final String? customBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const ApiConfig({
    this.environment = Environment.development,
    this.customBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
  });

  String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    switch (environment) {
      case Environment.staging:
        // Staging Core (no /api global prefix — Nest routes are root-mounted).
        return 'https://core-api-production-50ce.up.railway.app';
      case Environment.production:
        return 'https://api.2go.app';
      case Environment.development:
        if (kIsWeb) {
          return 'http://localhost:3000';
        }
        if (Platform.isAndroid) {
          // Android Emulator loopback to host Mac
          return 'http://10.0.2.2:3000';
        }
        // iOS Simulator / macOS desktop
        return 'http://localhost:3000';
    }
  }

  String get mercadoPagoPublicKey {
    switch (environment) {
      case Environment.development:
        return const String.fromEnvironment(
          'MERCADO_PAGO_PUBLIC_KEY',
          defaultValue: 'APP_USR-TEST-DEVELOPMENT-PUBLIC-KEY',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'MERCADO_PAGO_PUBLIC_KEY',
          defaultValue: 'APP_USR-TEST-STAGING-PUBLIC-KEY',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'MERCADO_PAGO_PUBLIC_KEY',
          defaultValue: '',
        );
    }
  }
}
