import 'package:twogo_core/twogo_core.dart';

class MissingGuestJourneyCredentialFailure extends AppFailure {
  const MissingGuestJourneyCredentialFailure()
    : super(
        message: 'Credencial da jornada anônima não encontrada no dispositivo',
        code: 'MISSING_GUEST_JOURNEY_CREDENTIAL',
        statusCode: 401,
      );
}

class GuestJourneyNotFoundFailure extends AppFailure {
  const GuestJourneyNotFoundFailure()
    : super(
        message: 'Jornada de planejamento não encontrada',
        code: 'PLANNING_JOURNEY_NOT_FOUND',
        statusCode: 404,
      );
}

class GuestJourneyExpiredFailure extends AppFailure {
  const GuestJourneyExpiredFailure()
    : super(
        message: 'Sessão da jornada de planejamento expirou',
        code: 'PLANNING_JOURNEY_EXPIRED',
        statusCode: 401,
      );
}

class GuestJourneyLockedFailure extends AppFailure {
  const GuestJourneyLockedFailure()
    : super(
        message: 'Jornada de planejamento congelada para edições',
        code: 'PLANNING_JOURNEY_LOCKED',
        statusCode: 400,
      );
}

class PlanningIncompleteFailure extends AppFailure {
  const PlanningIncompleteFailure(String message)
    : super(message: message, code: 'PLANNING_INCOMPLETE', statusCode: 400);
}

class InvalidPlanningDataFailure extends AppFailure {
  const InvalidPlanningDataFailure(String message)
    : super(message: message, code: 'PLANNING_INVALID_DATA', statusCode: 400);
}

class UnknownPlanningFailure extends AppFailure {
  const UnknownPlanningFailure(String message)
    : super(message: message, code: 'PLANNING_UNKNOWN_ERROR', statusCode: 500);
}
