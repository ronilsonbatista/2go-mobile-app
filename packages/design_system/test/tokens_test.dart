import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('Design System Tokens Unit Tests', () {
    test(
      'TwoGoColors contains expected primitive and semantic brand colors',
      () {
        expect(TwoGoColors.brandLime.value, 0xFFC4E000);
        expect(TwoGoColors.actionPrimary, TwoGoColors.brandLime);
        expect(TwoGoColors.backgroundPrimary, TwoGoColors.neutral0);
        expect(TwoGoColors.contentPrimary, TwoGoColors.neutral900);
      },
    );

    test('TwoGoSpacing scale follows 8pt / 4pt grid guidelines', () {
      expect(TwoGoSpacing.xxs, 4.0);
      expect(TwoGoSpacing.xs, 8.0);
      expect(TwoGoSpacing.sm, 12.0);
      expect(TwoGoSpacing.md, 16.0);
      expect(TwoGoSpacing.lg, 24.0);
      expect(TwoGoSpacing.xl, 32.0);
      expect(TwoGoSpacing.xxl, 48.0);
    });

    test('TwoGoRadius defines border radius constants', () {
      expect(TwoGoRadius.small, 4.0);
      expect(TwoGoRadius.medium, 8.0);
      expect(TwoGoRadius.large, 16.0);
      expect(TwoGoRadius.full, 999.0);
    });

    test('TwoGoBreakpoints identifies compact screen width correctly', () {
      expect(TwoGoBreakpoints.compact, 600.0);
    });
  });
}
