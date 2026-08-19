import 'package:equatable/equatable.dart';
import 'package:twogo_core/twogo_core.dart';
import '../../../domain/models/planning_preview.dart';

abstract class PlanningPreviewState extends Equatable {
  const PlanningPreviewState();

  @override
  List<Object?> get props => [];
}

class PlanningPreviewInitialState extends PlanningPreviewState {
  const PlanningPreviewInitialState();
}

class PlanningPreviewLoadingState extends PlanningPreviewState {
  const PlanningPreviewLoadingState();
}

class PlanningPreviewLoadedState extends PlanningPreviewState {
  final PlanningPreview preview;
  final int selectedDayNumber;
  final bool isPaywallOpen;
  final String? paywallSource;
  final bool hasAutoOpenedPaywall;

  const PlanningPreviewLoadedState({
    required this.preview,
    required this.selectedDayNumber,
    this.isPaywallOpen = false,
    this.paywallSource,
    this.hasAutoOpenedPaywall = false,
  });

  PlanningPreviewLoadedState copyWith({
    PlanningPreview? preview,
    int? selectedDayNumber,
    bool? isPaywallOpen,
    String? paywallSource,
    bool? hasAutoOpenedPaywall,
  }) {
    return PlanningPreviewLoadedState(
      preview: preview ?? this.preview,
      selectedDayNumber: selectedDayNumber ?? this.selectedDayNumber,
      isPaywallOpen: isPaywallOpen ?? this.isPaywallOpen,
      paywallSource: paywallSource ?? this.paywallSource,
      hasAutoOpenedPaywall: hasAutoOpenedPaywall ?? this.hasAutoOpenedPaywall,
    );
  }

  @override
  List<Object?> get props => [
        preview,
        selectedDayNumber,
        isPaywallOpen,
        paywallSource,
        hasAutoOpenedPaywall,
      ];
}

class PlanningPreviewErrorState extends PlanningPreviewState {
  final AppFailure failure;

  const PlanningPreviewErrorState({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class PlanningPreviewUnlockRequestedState extends PlanningPreviewState {
  final String journeyId;
  final String? productId;
  final String productCode;
  final double price;
  final String currency;

  const PlanningPreviewUnlockRequestedState({
    required this.journeyId,
    this.productId,
    required this.productCode,
    required this.price,
    required this.currency,
  });

  @override
  List<Object?> get props => [
        journeyId,
        productId,
        productCode,
        price,
        currency,
      ];
}
