class ClaimJourneyResult {
  final String journeyId;
  final String tripId;
  final String status;
  final String nextAction;

  const ClaimJourneyResult({
    required this.journeyId,
    required this.tripId,
    required this.status,
    required this.nextAction,
  });
}
