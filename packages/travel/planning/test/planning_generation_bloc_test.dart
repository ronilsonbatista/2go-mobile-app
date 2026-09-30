import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

class MockStartPlanningGenerationUseCase
    implements StartPlanningGenerationUseCase {
  Result<PlanningGenerationStatus>? response;
  int calls = 0;

  @override
  Future<Result<PlanningGenerationStatus>> call(String journeyId) async {
    calls++;
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
  int calls = 0;

  @override
  Future<Result<PlanningGenerationStatus>> call(String journeyId) async {
    calls++;
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

    test(
      'unknown poll status does not become failed or post generate again',
      () async {
        mockStartUseCase.response = Result.success(
          const PlanningGenerationStatus(
            journeyId: 'journey-123',
            status: GuestJourneyStatus.generating,
          ),
        );
        mockStatusUseCase.response = Result.success(
          const PlanningGenerationStatus(
            journeyId: 'journey-123',
            status: GuestJourneyStatus.unknown,
          ),
        );

        final bloc = PlanningGenerationBloc(
          startGenerationUseCase: mockStartUseCase,
          getStatusUseCase: mockStatusUseCase,
        );

        bloc.add(const StartGenerationEvent('journey-123'));
        await bloc.stream.firstWhere(
          (s) => s.status == PlanningGenerationPageStatus.generating,
        );
        expect(mockStartUseCase.calls, 1);
        expect(
          GuestJourneyStatus.fromRaw('QUEUED'),
          GuestJourneyStatus.unknown,
        );
        expect(GuestJourneyStatus.fromRaw('FAILED'), GuestJourneyStatus.failed);

        bloc.add(const CheckGenerationStatusEvent('journey-123'));
        await bloc.stream.firstWhere(
          (s) => s.generationStatus?.status == GuestJourneyStatus.unknown,
        );

        expect(bloc.state.status, PlanningGenerationPageStatus.generating);
        expect(bloc.state.status, isNot(PlanningGenerationPageStatus.failed));
        expect(mockStartUseCase.calls, 1);
        expect(bloc.isPolling, isTrue);
        await bloc.close();
      },
    );

    test('network error on GET does not post generate again', () async {
      mockStartUseCase.response = Result.success(
        const PlanningGenerationStatus(
          journeyId: 'journey-123',
          status: GuestJourneyStatus.generating,
        ),
      );
      mockStatusUseCase.response = Result.failure(
        const UnknownPlanningFailure('Sem rede'),
      );

      final bloc = PlanningGenerationBloc(
        startGenerationUseCase: mockStartUseCase,
        getStatusUseCase: mockStatusUseCase,
      );

      bloc.add(const StartGenerationEvent('journey-123'));
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningGenerationPageStatus.generating,
      );

      bloc.add(const CheckGenerationStatusEvent('journey-123'));
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningGenerationPageStatus.temporaryNetworkFailure,
      );

      expect(mockStartUseCase.calls, 1);
      expect(mockStatusUseCase.calls, 1);
      expect(bloc.isPolling, isTrue);
      await bloc.close();
    });

    test('poll timer backs off from 2 seconds', () async {
      mockStartUseCase.response = Result.success(
        const PlanningGenerationStatus(
          journeyId: 'journey-123',
          status: GuestJourneyStatus.generating,
        ),
      );
      mockStatusUseCase.response = Result.success(
        const PlanningGenerationStatus(
          journeyId: 'journey-123',
          status: GuestJourneyStatus.generating,
        ),
      );

      final bloc = PlanningGenerationBloc(
        startGenerationUseCase: mockStartUseCase,
        getStatusUseCase: mockStatusUseCase,
      );

      bloc.add(const StartGenerationEvent('journey-123'));
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningGenerationPageStatus.generating,
      );

      expect(bloc.scheduledPollDelay, const Duration(seconds: 2));
      expect(mockStatusUseCase.calls, 0);
      expect(mockStartUseCase.calls, 1);

      const expectedDelays = <Duration>[
        Duration(seconds: 4),
        Duration(seconds: 8),
        Duration(seconds: 16),
        Duration(seconds: 30),
        Duration(seconds: 30),
      ];

      for (final delay in expectedDelays) {
        bloc.add(const CheckGenerationStatusEvent('journey-123'));
        await bloc.stream.firstWhere(
          (s) => s.generationStatus?.status == GuestJourneyStatus.generating,
        );
        expect(bloc.scheduledPollDelay, delay);
      }

      expect(mockStatusUseCase.calls, expectedDelays.length);
      expect(mockStartUseCase.calls, 1);
      await bloc.close();
    });
  });
}
