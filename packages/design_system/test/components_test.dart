import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoCard & TwoGoListTile Widget Tests', () {
    testWidgets('TwoGoCard renders child and handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoCard(
              onTap: () => tapped = true,
              child: const Text('Conteúdo do Card'),
            ),
          ),
        ),
      );

      expect(find.text('Conteúdo do Card'), findsOneWidget);
      await tester.tap(find.byType(TwoGoCard));
      expect(tapped, isTrue);
    });

    testWidgets('TwoGoListTile renders title, subtitle, and responds to tap', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoListTile(
              title: 'Cartão de crédito',
              subtitle: '**** 4408',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Cartão de crédito'), findsOneWidget);
      expect(find.text('**** 4408'), findsOneWidget);
      await tester.tap(find.byType(TwoGoListTile));
      expect(tapped, isTrue);
    });
  });

  group('TwoGoCheckbox Widget Test', () {
    testWidgets('toggles check state on tap', (tester) async {
      bool checked = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: TwoGoCheckbox(
                  value: checked,
                  label: 'Salvar dados do cartão',
                  onChanged: (val) => setState(() => checked = val ?? false),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Salvar dados do cartão'), findsOneWidget);
      await tester.tap(find.byType(TwoGoCheckbox));
      await tester.pump();

      expect(checked, isTrue);
    });
  });

  group('TwoGoSnackbar & TwoGoStatusMessage Widget Tests', () {
    testWidgets('TwoGoSnackbar renders toast message and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TwoGoSnackbar(
              message: 'Código reenviado com sucesso',
              variant: TwoGoSnackbarVariant.success,
            ),
          ),
        ),
      );

      expect(find.text('Código reenviado com sucesso'), findsOneWidget);
    });

    testWidgets(
      'TwoGoStatusMessage renders title, description, and action button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TwoGoStatusMessage(
                type: TwoGoStatusMessageType.success,
                title: 'Pagamento confirmado',
                description: 'Já pode fazer as malas!',
                action: TwoGoButton(text: 'Acessar roteiro', onPressed: () {}),
              ),
            ),
          ),
        );

        expect(find.text('Pagamento confirmado'), findsOneWidget);
        expect(find.text('Já pode fazer as malas!'), findsOneWidget);
        expect(find.text('Acessar roteiro'), findsOneWidget);
      },
    );
  });

  group('TwoGoBottomSheet Widget Test', () {
    testWidgets('renders bottom sheet title and child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    TwoGoBottomSheet.show<void>(
                      context,
                      title: 'Adicionar cupom',
                      child: const Text('Insira o cupom abaixo'),
                    );
                  },
                  child: const Text('Abrir Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Adicionar cupom'), findsOneWidget);
      expect(find.text('Insira o cupom abaixo'), findsOneWidget);
    });
  });
}
