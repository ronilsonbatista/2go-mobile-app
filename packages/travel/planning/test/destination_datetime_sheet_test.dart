import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  testWidgets('Onde datetime sheet shows Horário previsto hour pills', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  DestinationDateTimeSheet.show(
                    context,
                    initialDate: DateTime(2026, 7, 25),
                    firstDate: DateTime(2026, 7, 1),
                    lastDate: DateTime(2026, 12, 31),
                    initialTime: '09:00',
                    primaryLabel: 'Próximo',
                    secondaryLabel: 'Fechar',
                  );
                },
                child: const Text('Abrir'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Horário previsto'), findsOneWidget);
    expect(find.text('09:00'), findsWidgets);
    expect(find.text('07:00'), findsOneWidget);
    expect(find.text('Próximo'), findsOneWidget);
    expect(find.text('Fechar'), findsOneWidget);

    // Select another hour pill and confirm.
    await tester.tap(find.text('10:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();

    expect(find.text('Horário previsto'), findsNothing);
  });
}
