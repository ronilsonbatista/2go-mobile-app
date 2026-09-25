import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_config/twogo_config.dart';
import 'package:twogo_networking/twogo_networking.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_places/places.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_session/twogo_session.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_trips/trips.dart';

/// Composition root — wires Core clients for the selected flavor.
class AppDependencies {
  AppDependencies._({
    required this.environment,
    required this.apiConfig,
    required this.tokenStorage,
    required this.sessionCubit,
    required this.authRepository,
    required this.planningRepository,
    required this.draftStorage,
    required this.credentialStorage,
    required this.intentStorage,
    required this.paymentsRepository,
    required this.tripsRepository,
    required this.searchPlacesUseCase,
    required this.cardTokenizer,
    required this.createPlanningJourneyUseCase,
    required this.restorePlanningJourneyUseCase,
    required this.savePlanningProgressUseCase,
    required this.finalizePlanningJourneyUseCase,
    required this.startPlanningGenerationUseCase,
    required this.getPlanningGenerationStatusUseCase,
    required this.getPlanningPreviewUseCase,
    required this.claimPlanningJourneyUseCase,
  });

  final String environment;
  final ApiConfig apiConfig;
  final TokenStorage tokenStorage;
  final SessionCubit sessionCubit;
  final AuthRepository authRepository;
  final PlanningRepository planningRepository;
  final PlanningDraftStorage draftStorage;
  final GuestJourneyCredentialStorage credentialStorage;
  final PostAuthIntentStorage intentStorage;
  final PaymentsRepository paymentsRepository;
  final TripsRepository tripsRepository;
  final SearchPlacesUseCase searchPlacesUseCase;
  final CardTokenizer cardTokenizer;

  final CreatePlanningJourneyUseCase createPlanningJourneyUseCase;
  final RestorePlanningJourneyUseCase restorePlanningJourneyUseCase;
  final SavePlanningProgressUseCase savePlanningProgressUseCase;
  final FinalizePlanningJourneyUseCase finalizePlanningJourneyUseCase;
  final StartPlanningGenerationUseCase startPlanningGenerationUseCase;
  final GetPlanningGenerationStatusUseCase getPlanningGenerationStatusUseCase;
  final GetPlanningPreviewUseCase getPlanningPreviewUseCase;
  final ClaimPlanningJourneyUseCase claimPlanningJourneyUseCase;

  static Future<AppDependencies> create({required String environment}) async {
    final apiConfig = ApiConfig(environment: _mapEnvironment(environment));
    final tokenStorage = SecureTokenStorageImpl();
    final sessionCubit = SessionCubit(tokenStorage: tokenStorage);
    await sessionCubit.restoreSession();

    late final AuthApiClient authApiClient;
    late final Dio dio;

    final refreshCoordinator = RefreshCoordinator(
      tokenStorage: tokenStorage,
      refreshFunction: (refreshToken) async {
        final response = await authApiClient.refresh(
          RefreshTokenDto(refreshToken: refreshToken),
        );
        return AuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        );
      },
    );

    dio = DioClientFactory.create(
      config: apiConfig,
      tokenStorage: tokenStorage,
      refreshCoordinator: refreshCoordinator,
    );

    authApiClient = AuthApiClient(dio);
    final planningApiClient = PlanningApiClient(dio);
    final placesApiClient = PlacesApiClient(dio);
    final billingApiClient = BillingApiClient(dio);

    final authRepository = AuthRepositoryImpl(
      apiClient: authApiClient,
      tokenStorage: tokenStorage,
    );

    final credentialStorage = GuestJourneyCredentialStorageImpl();
    final draftStorage = PersistentPlanningDraftStorage();
    final intentStorage = PersistentPostAuthIntentStorage();

    final planningRepository = PlanningRepositoryImpl(
      apiClient: planningApiClient,
      credentialStorage: credentialStorage,
    );

    final placesRepository = PlacesRepositoryImpl(apiClient: placesApiClient);
    final searchPlacesUseCase = SearchPlacesUseCase(
      repository: placesRepository,
    );

    final paymentsRepository = PaymentsRepositoryImpl(
      remoteDataSource: PaymentsRemoteDataSourceImpl(
        billingApiClient: billingApiClient,
      ),
    );

    // Trips UI is post-P0; keep mock datasource until trip screens are wired.
    final tripsRepository = TripsRepositoryImpl(
      remoteDataSource: MockTripsDataSource(),
    );

    return AppDependencies._(
      environment: environment,
      apiConfig: apiConfig,
      tokenStorage: tokenStorage,
      sessionCubit: sessionCubit,
      authRepository: authRepository,
      planningRepository: planningRepository,
      draftStorage: draftStorage,
      credentialStorage: credentialStorage,
      intentStorage: intentStorage,
      paymentsRepository: paymentsRepository,
      tripsRepository: tripsRepository,
      searchPlacesUseCase: searchPlacesUseCase,
      cardTokenizer: NativeCardTokenizer(),
      createPlanningJourneyUseCase: CreatePlanningJourneyUseCase(
        repository: planningRepository,
        credentialStorage: credentialStorage,
        draftStorage: draftStorage,
      ),
      restorePlanningJourneyUseCase: RestorePlanningJourneyUseCase(
        repository: planningRepository,
        credentialStorage: credentialStorage,
        draftStorage: draftStorage,
      ),
      savePlanningProgressUseCase: SavePlanningProgressUseCase(
        repository: planningRepository,
        draftStorage: draftStorage,
      ),
      finalizePlanningJourneyUseCase: FinalizePlanningJourneyUseCase(
        repository: planningRepository,
        draftStorage: draftStorage,
      ),
      startPlanningGenerationUseCase: StartPlanningGenerationUseCase(
        repository: planningRepository,
      ),
      getPlanningGenerationStatusUseCase: GetPlanningGenerationStatusUseCase(
        repository: planningRepository,
      ),
      getPlanningPreviewUseCase: GetPlanningPreviewUseCase(planningRepository),
      claimPlanningJourneyUseCase: ClaimPlanningJourneyUseCase(
        planningRepository,
      ),
    );
  }

  PlanningWizardBloc createPlanningWizardBloc() {
    return PlanningWizardBloc(
      createUseCase: createPlanningJourneyUseCase,
      restoreUseCase: restorePlanningJourneyUseCase,
      saveUseCase: savePlanningProgressUseCase,
      finalizeUseCase: finalizePlanningJourneyUseCase,
      draftStorage: draftStorage,
    )..add(const InitializeWizardEvent());
  }

  PlanningGenerationBloc createPlanningGenerationBloc() {
    return PlanningGenerationBloc(
      startGenerationUseCase: startPlanningGenerationUseCase,
      getStatusUseCase: getPlanningGenerationStatusUseCase,
    );
  }

  PlanningPreviewBloc createPlanningPreviewBloc() {
    return PlanningPreviewBloc(
      getPreviewUseCase: getPlanningPreviewUseCase,
    );
  }

  PlanningClaimBloc createPlanningClaimBloc() {
    return PlanningClaimBloc(
      claimUseCase: claimPlanningJourneyUseCase,
      credentialStorage: credentialStorage,
      draftStorage: draftStorage,
      intentStorage: intentStorage,
    );
  }

  static Environment _mapEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'staging':
        return Environment.staging;
      case 'production':
      case 'prod':
        return Environment.production;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }
}
