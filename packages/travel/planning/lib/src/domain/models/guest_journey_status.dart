enum GuestJourneyStatus {
  collecting,
  readyToGenerate,
  generating,
  previewReady,
  authRequired,
  claimed,
  checkoutPending,
  paid,
  expired,
  failed;

  static GuestJourneyStatus fromRaw(String raw) {
    switch (raw.toUpperCase()) {
      case 'COLLECTING':
        return GuestJourneyStatus.collecting;
      case 'READY_TO_GENERATE':
        return GuestJourneyStatus.readyToGenerate;
      case 'GENERATING':
        return GuestJourneyStatus.generating;
      case 'PREVIEW_READY':
        return GuestJourneyStatus.previewReady;
      case 'AUTH_REQUIRED':
        return GuestJourneyStatus.authRequired;
      case 'CLAIMED':
        return GuestJourneyStatus.claimed;
      case 'CHECKOUT_PENDING':
        return GuestJourneyStatus.checkoutPending;
      case 'PAID':
        return GuestJourneyStatus.paid;
      case 'EXPIRED':
        return GuestJourneyStatus.expired;
      case 'FAILED':
      default:
        return GuestJourneyStatus.failed;
    }
  }

  String toRaw() {
    switch (this) {
      case GuestJourneyStatus.collecting:
        return 'COLLECTING';
      case GuestJourneyStatus.readyToGenerate:
        return 'READY_TO_GENERATE';
      case GuestJourneyStatus.generating:
        return 'GENERATING';
      case GuestJourneyStatus.previewReady:
        return 'PREVIEW_READY';
      case GuestJourneyStatus.authRequired:
        return 'AUTH_REQUIRED';
      case GuestJourneyStatus.claimed:
        return 'CLAIMED';
      case GuestJourneyStatus.checkoutPending:
        return 'CHECKOUT_PENDING';
      case GuestJourneyStatus.paid:
        return 'PAID';
      case GuestJourneyStatus.expired:
        return 'EXPIRED';
      case GuestJourneyStatus.failed:
        return 'FAILED';
    }
  }
}
