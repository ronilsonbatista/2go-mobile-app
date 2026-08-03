import 'dart:io';

void main() {
  print('=== 2GO Architecture Lint Checker ===');
  final packagesDir = Directory('packages');
  if (!packagesDir.existsSync()) {
    print('No packages directory found.');
    exit(0);
  }

  int violations = 0;

  // Rule 1: Design System must not import features, networking, analytics or core features
  final designSystemDir = Directory('packages/design_system');
  if (designSystemDir.existsSync()) {
    designSystemDir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        if (content.contains('package:networking/') ||
            content.contains('package:analytics/') ||
            content.contains('package:trips/') ||
            content.contains('package:payments/')) {
          print('VIOLATION in Design System: ${entity.path} contains forbidden import.');
          violations++;
        }
      }
    });
  }

  // Rule 2: Core must not import business modules or feature modules
  final coreDir = Directory('packages/foundation/core');
  if (coreDir.existsSync()) {
    coreDir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        if (content.contains('package:authentication/') ||
            content.contains('package:trips/') ||
            content.contains('package:payments/')) {
          print('VIOLATION in Core: ${entity.path} imports domain module.');
          violations++;
        }
      }
    });
  }

  if (violations > 0) {
    print('Architecture lint check failed with $violations violation(s).');
    exit(1);
  } else {
    print('All architecture dependency checks PASSED cleanly!');
  }
}
