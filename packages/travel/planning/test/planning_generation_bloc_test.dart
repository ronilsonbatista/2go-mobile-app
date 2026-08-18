import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
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
  group('PlanningGenerationBloc', () {
    late MockStartPlanningGenerationUseCase mockStartUseCase;
    late MockGetPlanningGenerationStatusUseCase mockStatusUseCase;

    setUp(() {
      mockStartUseCase = MockStartPlanningGenerationUseCase();
      mockStatusUseCase = MockGetPlanningGenerationStatusUseCase();
    });

    test('starts generation and emits generating state', () async {
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

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PlanningGenerationState>().having(
            (s) => s.status,
            'status',
            PlanningGenerationPageStatus.starting,
          ),
          isA<PlanningGenerationState>().having(
            (s) => s.status,
            'status',
            PlanningGenerationPageStatus.generating,
          ),
        ]),
      );

      bloc.add(const StartGenerationEvent('journey-123'));
      await expectation;
      await bloc.close();
    });

    test(
      'transitions to previewReady when status becomes previewReady',
      () async {
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

        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<PlanningGenerationState>().having(
              (s) => s.status,
              'status',
              PlanningGenerationPageStatus.starting,
            ),
            isA<PlanningGenerationState>().having(
              (s) => s.status,
              'status',
              PlanningGenerationPageStatus.previewReady,
            ),
          ]),
        );

        bloc.add(const StartGenerationEvent('journey-123'));
        await expectation;
        await bloc.close();
      },
    );

    test(
      'emits temporaryNetworkFailure on start generation network error',
      () async {
        mockStartUseCase.response = Result.failure(
          const UnknownPlanningFailure('Rede indisponível'),
        );

        final bloc = PlanningGenerationBloc(
          startGenerationUseCase: mockStartUseCase,
          getStatusUseCase: mockStatusUseCase,
        );

        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<PlanningGenerationState>().having(
              (s) => s.status,
              'status',
              PlanningGenerationPageStatus.starting,
            ),
            isA<PlanningGenerationState>().having(
              (s) => s.status,
              'status',
              PlanningGenerationPageStatus.temporaryNetworkFailure,
            ),
          ]),
        );

        bloc.add(const StartGenerationEvent('journey-123'));
        await expectation;
        await bloc.close();
      },
    );
  });
}
