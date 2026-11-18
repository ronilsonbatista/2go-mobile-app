import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Age step uses course age brackets copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: TravelersStepContent(
            travelers: const PlanningTravelers(
              adults: 2,
              children: 2,
              elders: 0,
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('13 anos ou mais'), findsOneWidget);
    expect(find.text('Menos de 12 anos'), findsOneWidget);
    expect(find.text('Mais de 65 anos'), findsOneWidget);
    expect(find.text('Adultos'), findsOneWidget);
  });

  testWidgets('Interests step lists course rows with system emoji', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: InterestsStepContent(
            selectedInterests: const [PlanningInterest.gastronomy],
            onToggleInterest: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Gastronomia'), findsOneWidget);
    expect(find.text('🍲'), findsOneWidget);
    expect(find.text('Cultura Geek'), findsOneWidget);
    expect(find.text('👾'), findsOneWidget);
    expect(find.text('Atividades ao ar livre'), findsOneWidget);
  });

  testWidgets('Estilo step shows dollar rows and course title labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: BudgetStepContent(
            selectedBudgetLevel: 'MEDIUM',
            onSelectBudgetLevel: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Econômica'), findsOneWidget);
    expect(find.text('Confortável'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Luxuosa'), findsOneWidget);
    expect(find.text('\$\$'), findsWidgets);
  });

  testWidgets('wizard scaffold has no bottom navigation bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: PlanningWizardScaffold(
          currentStep: 2,
          title: 'Quem vai?',
          body: const SizedBox.shrink(),
          onBack: () {},
          onNext: () {},
        ),
      ),
    );

    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('2 de 6'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('Revisao step 6 shows destino and interesses emoji rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: ReviewStepContent(
            destinations: const [
              PlanningDestination(
                providerPlaceId: 'catalog:roma',
                name: 'Roma',
                country: 'Itália',
                arrivalDate: '2026-07-25',
                arrivalTime: '11:00',
                departureDate: '2026-07-28',
                departureTime: '23:00',
              ),
            ],
            travelers: const PlanningTravelers(adults: 2, children: 2),
            interests: const [
              PlanningInterest.gastronomy,
              PlanningInterest.architecture,
            ],
            activityWindow: const PlanningActivityWindow(),
            budgetLevel: 'HIGH',
            onEditSection: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Tudo pronto para criarmos seu roteiro?'), findsNothing);
    expect(find.text('Destino'), findsOneWidget);
    expect(find.text('Roma'), findsOneWidget);
    expect(find.text('Itália'), findsOneWidget);
    expect(find.text('💡 Toque para editar'), findsOneWidget);
    expect(find.text('Viajantes'), findsOneWidget);
    expect(find.text('2 adultos'), findsOneWidget);
    expect(find.text('Estilo de viagem'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Principais interesses'), findsOneWidget);
    expect(find.text('🍲'), findsOneWidget);
    expect(find.text('Gastronomia'), findsOneWidget);
  });

  testWidgets('confirm dialog Continuar/Cancelar before finalize', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => PlanningConfirmationSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja continuar?'), findsOneWidget);
    expect(
      find.text('Após essa etapa, não será possível alterar as informações.'),
      findsOneWidget,
    );
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('activity hours shows start/end chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: ActivityHoursStepContent(
            activityWindow: const PlanningActivityWindow(
              start: '09:00',
              end: '19:00',
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Início das atividades'), findsOneWidget);
    expect(find.text('Fim das atividades'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget);
  });
}
