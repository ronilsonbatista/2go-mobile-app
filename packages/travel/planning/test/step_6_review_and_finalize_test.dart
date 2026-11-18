import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  group('Step 6 — Review & Finalize Widget Tests', () {
    testWidgets('ReviewStepContent renders course Revisao sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReviewStepContent(
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
        ),
      );

      expect(find.text('Destino'), findsOneWidget);
      expect(find.text('Lisboa'), findsOneWidget);
      expect(find.text('💡 Toque para editar'), findsOneWidget);
      expect(find.text('Viajantes'), findsOneWidget);
      expect(find.text('2 adultos'), findsOneWidget);
      expect(find.text('1 criança'), findsOneWidget);
      expect(find.text('Estilo de viagem'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Principais interesses'), findsOneWidget);
      expect(find.text('Arte'), findsOneWidget);
      expect(find.text('Gastronomia'), findsOneWidget);
      // Course Revisao omits horário row.
      expect(find.text('Atividades das 09:00 às 19:00'), findsNothing);
    });

    testWidgets(
      'PlanningConfirmationSheet renders Continuar/Cancelar before POST',
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
            'Após essa etapa, não será possível alterar as informações.',
          ),
          findsOneWidget,
        );
        expect(find.text('Continuar'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Voltar'), findsNothing);
        expect(find.text('Criar meu roteiro'), findsNothing);
      },
    );
  });
}
