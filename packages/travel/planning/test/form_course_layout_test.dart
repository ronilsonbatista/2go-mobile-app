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
