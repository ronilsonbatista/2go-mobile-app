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
  group('PlanningGenerationPage Responsive Goldens', () {
    late MockStartPlanningGenerationUseCase mockStartUseCase;
    late MockGetPlanningGenerationStatusUseCase mockStatusUseCase;

    final viewports = <String, Size>{
      '360x800': const Size(360, 800),
      '390x844': const Size(390, 844),
      '412x915': const Size(412, 915),
    };

    setUp(() {
      mockStartUseCase = MockStartPlanningGenerationUseCase();
      mockStatusUseCase = MockGetPlanningGenerationStatusUseCase();
    });

    for (final entry in viewports.entries) {
      testWidgets('renders loading state cleanly on ${entry.key}', (
        tester,
      ) async {
        final bloc = PlanningGenerationBloc(
          startGenerationUseCase: mockStartUseCase,
          getStatusUseCase: mockStatusUseCase,
          initialState: const PlanningGenerationState(
            journeyId: 'journey-123',
            status: PlanningGenerationPageStatus.generating,
          ),
        );

        tester.view.physicalSize = entry.value * tester.view.devicePixelRatio;

        await tester.pumpWidget(
          MaterialApp(
            theme: TwoGoTheme.light,
            home: PlanningGenerationPage(journeyId: 'journey-123', bloc: bloc),
          ),
        );

        expect(find.text('Gerando seu roteiro...'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
        addTearDown(tester.view.resetPhysicalSize);
      });
    }
  });
}
