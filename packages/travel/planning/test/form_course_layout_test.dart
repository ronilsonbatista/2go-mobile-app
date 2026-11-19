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
          // Harness: step content is scrollable inside the wizard scaffold.
          body: SingleChildScrollView(
            child: InterestsStepContent(
              selectedInterests: const [PlanningInterest.gastronomy],
              onToggleInterest: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Gastronomia'), findsOneWidget);
    expect(find.text('🍲'), findsOneWidget);
    expect(find.text('Cultura Geek'), findsOneWidget);
    expect(find.text('👾'), findsOneWidget);
    expect(find.text('Atividades ao ar livre'), findsOneWidget);
    // Selected row uses Material check (not a broken storefront glyph).
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Estilo step shows dollar rows and course title labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: BudgetStepContent(
              selectedBudgetLevel: 'MEDIUM',
              onSelectBudgetLevel: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Econômica'), findsOneWidget);
    expect(find.text('Confortável'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Luxuosa'), findsOneWidget);
    // Course Estilo uses Image.asset dollar glyphs, not text "$$".
    expect(find.byType(FormEstiloDollarGlyph), findsNWidgets(4));
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
    expect(find.byType(TwoGoBottomNavigation), findsNothing);
    expect(find.text('2 de 6'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    // Q&A back: white circle + dark left chevron (ref 716686ac).
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  });

  testWidgets('Age steppers use white-circle black +/− icons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: TravelersStepContent(
            travelers: const PlanningTravelers(
              adults: 2,
              children: 1,
              elders: 0,
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(TwoGoIcons.add), findsNWidgets(3));
    expect(find.byIcon(TwoGoIcons.remove), findsNWidgets(3));
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
                providerPlaceId: 'ChIJu46S-ZZhLxMROG5lkwZ3D7k',
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
    // Destino thumb is PlaceThumb (monument photo / SVG pin), never tofu.
    expect(find.byType(PlaceThumb), findsOneWidget);
  });

  testWidgets('wizard header uses vector progress plane', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: PlanningWizardScaffold(
          currentStep: 1,
          title: 'Para onde você quer viajar?',
          body: const SizedBox.shrink(),
          onBack: () {},
          onNext: () {},
        ),
      ),
    );
    expect(find.byType(FormProgressPlaneIcon), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
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
    expect(find.byType(PlanningCourseSheet), findsOneWidget);
  });

  testWidgets('Onde dates render short dd/MM without truncation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Scaffold(
          body: DestinationCardWidget(
            index: 0,
            destination: const PlanningDestination(
              providerPlaceId: 'ChIJu46S-ZZhLxMROG5lkwZ3D7k',
              name: 'Roma',
              arrivalDate: '2026-11-26',
              arrivalTime: '09:00',
              departureDate: '2026-11-30',
              departureTime: '18:00',
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('26/11 - 9:00'), findsOneWidget);
    expect(find.text('30/11 - 18:00'), findsOneWidget);
    expect(find.textContaining('novembro'), findsNothing);
  });

  testWidgets('delete sheet asks realmente excluir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => PlanningCourseSheet.show(
                  context,
                  title: 'Deseja realmente excluir?',
                  body: 'Este destino será removido do roteiro.',
                  confirmLabel: 'Excluir',
                ),
                child: const Text('open-delete'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-delete'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja realmente excluir?'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
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
