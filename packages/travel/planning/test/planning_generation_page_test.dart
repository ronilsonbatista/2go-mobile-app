import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_planning/twogo_planning.dart';

class MockStartPlanningGenerationUseCase
    implements StartPlanningGenerationUseCase {
  Result<PlanningGenerationStatus>? response;

  @override
  Future<Result<PlanningGenerationStatus>> call(String journeyId) async {
    return response ??
        Result.success(
          PlanningGenerationStatus(
            journeyId: journeyId,
            status: GuestJourneyStatus.generating,
          ),
        );
  }
}

class MockGetPlanningGenerationStatusUseCase
    implements GetPlanningGenerationStatusUseCase {
  Result<PlanningGenerationStatus>? response;

  @override
  Future<Result<PlanningGenerationStatus>> call(String journeyId) async {
    return response ??
        Result.success(
          PlanningGenerationStatus(
            journeyId: journeyId,
            status: GuestJourneyStatus.generating,
          ),
        );
  }
}

void main() {
  group('PlanningGenerationPage', () {
    late MockStartPlanningGenerationUseCase mockStartUseCase;
    late MockGetPlanningGenerationStatusUseCase mockStatusUseCase;

    setUp(() {
      mockStartUseCase = MockStartPlanningGenerationUseCase();
      mockStatusUseCase = MockGetPlanningGenerationStatusUseCase();
    });

    testWidgets('renders loading state indicator and title', (tester) async {
      mockStartUseCase.response = Result.success(
        const PlanningGenerationStatus(
          journeyId: 'journey-123',
          status: GuestJourneyStatus.generating,
        ),
      );

      final bloc = PlanningGenerationBloc(
        startGenerationUseCase: mockStartUseCase,
        getStatusUseCase: mockStatusUseCase,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: PlanningGenerationPage(journeyId: 'journey-123', bloc: bloc),
        ),
      );

      await tester.pump();

      expect(find.text('Gerando seu roteiro...'), findsOneWidget);
      expect(find.byType(TwoGoLoadingIndicator), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('triggers onPreviewReady callback when preview is ready', (
      tester,
    ) async {
      String? readyJourneyId;

      mockStartUseCase.response = Result.success(
        const PlanningGenerationStatus(
          journeyId: 'journey-123',
          status: GuestJourneyStatus.previewReady,
        ),
      );

      final bloc = PlanningGenerationBloc(
        startGenerationUseCase: mockStartUseCase,
        getStatusUseCase: mockStatusUseCase,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: PlanningGenerationPage(
            journeyId: 'journey-123',
            bloc: bloc,
            onPreviewReady: (id) => readyJourneyId = id,
          ),
        ),
      );

      await tester.pump();

      expect(readyJourneyId, equals('journey-123'));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renders failure state and triggers retry', (tester) async {
      final bloc = PlanningGenerationBloc(
        startGenerationUseCase: mockStartUseCase,
        getStatusUseCase: mockStatusUseCase,
        initialState: const PlanningGenerationState(
          journeyId: 'journey-123',
          status: PlanningGenerationPageStatus.failed,
          errorMessage: 'Erro ao gerar via IA',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: PlanningGenerationPage(journeyId: 'journey-123', bloc: bloc),
        ),
      );

      expect(
        find.text('Não foi possível gerar seu roteiro agora'),
        findsOneWidget,
      );
      expect(find.text('Erro ao gerar via IA'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
