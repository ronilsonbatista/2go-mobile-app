import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  group('Step 6 — Review & Finalize Widget Tests', () {
    testWidgets('ReviewStepContent renders all 5 questionnaire sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewStepContent(
              destinations: const [
                PlanningDestination(
                  providerPlaceId: 'place-1',
                  name: 'Lisboa',
                  arrivalDate: '2026-09-10',
                  arrivalTime: '10:00',
                  departureDate: '2026-09-15',
                  departureTime: '18:00',
                  order: 0,
                ),
              ],
              travelers: const PlanningTravelers(
                adults: 2,
                children: 1,
                elders: 0,
              ),
              interests: const [
                PlanningInterest.art,
                PlanningInterest.gastronomy,
              ],
              activityWindow: const PlanningActivityWindow(
                start: '09:00',
                end: '19:00',
              ),
              budgetLevel: 'HIGH',
              onEditSection: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Lisboa'), findsOneWidget);
      expect(
        find.text('3 viajante(s) (2 adulto(s), 1 criança(s), 0 idoso(s))'),
        findsOneWidget,
      );
      expect(find.text('Arte'), findsOneWidget);
      expect(find.text('Gastronomia'), findsOneWidget);
      expect(find.text('Atividades das 09:00 às 19:00'), findsOneWidget);
      expect(find.textContaining('Premium'), findsOneWidget);
    });

    testWidgets(
      'PlanningConfirmationSheet renders title, warning message and buttons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PlanningConfirmationSheet.show(context),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Deseja continuar?'), findsOneWidget);
        expect(
          find.text(
            'Após essa etapa, não será possível alterar as informações do questionário.',
          ),
          findsOneWidget,
        );
        expect(find.text('Voltar'), findsOneWidget);
        expect(find.text('Criar meu roteiro'), findsOneWidget);
      },
    );
  });
}
