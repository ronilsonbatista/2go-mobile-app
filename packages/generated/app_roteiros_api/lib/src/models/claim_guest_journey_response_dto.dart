class ClaimGuestJourneyResponseDto {
  final String journeyId;
  final String tripId;
  final String status;
  final String nextAction;

  const ClaimGuestJourneyResponseDto({
    required this.journeyId,
    required this.tripId,
    required this.status,
    required this.nextAction,
  });

  factory ClaimGuestJourneyResponseDto.fromJson(Map<String, dynamic> json) {
    return ClaimGuestJourneyResponseDto(
      journeyId: json['journeyId'] as String,
      tripId: json['tripId'] as String,
      status: json['status'] as String,
      nextAction: json['nextAction'] as String? ?? 'CHECKOUT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journeyId': journeyId,
      'tripId': tripId,
      'status': status,
      'nextAction': nextAction,
    };
  }
}
