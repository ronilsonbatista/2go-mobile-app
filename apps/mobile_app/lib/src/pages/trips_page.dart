import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_trips/trips.dart';

class TripsPage extends StatelessWidget {
  final TripsRepository tripsRepository;
  final String? tripId;
  final int? initialDayNumber;
  final SearchHotelsUseCase? searchHotels;
  final GetPlaceDetailsUseCase? getPlaceDetails;
  final SearchPlacesUseCase? searchPlaces;
  final ValueChanged<TripEntity>? onShare;
  final bool showInviteAcceptedToast;
  final Future<List<PreviewCoverCatalogEntry>> Function()? loadCoverCatalog;

  const TripsPage({
    super.key,
    required this.tripsRepository,
    this.tripId,
    this.initialDayNumber,
    this.searchHotels,
    this.getPlaceDetails,
    this.searchPlaces,
    this.onShare,
    this.showInviteAcceptedToast = false,
    this.loadCoverCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrip = tripId != null && tripId!.trim().isNotEmpty;
    final body = HandoffTripsView(
      tripsRepository: tripsRepository,
      tripId: tripId,
      initialDayNumber: initialDayNumber,
      searchHotels: searchHotels,
      getPlaceDetails: getPlaceDetails,
      searchPlaces: searchPlaces,
      onShare: onShare,
      showInviteAcceptedToast: showInviteAcceptedToast,
      loadCoverCatalog: loadCoverCatalog,
      onClose: () => context.go('/app/home'),
    );

    // Paid trip uses preview chrome (hero close/Salvar) — no dense "Viagens" bar.
    if (hasTrip) {
      return body;
    }

    return Scaffold(
      appBar: TwoGoAppBar(
        title: 'Viagens',
        showBackButton: false,
        leading: TwoGoIconButton(
          icon: TwoGoIcons.close,
          tooltip: 'Fechar',
          onPressed: () => context.go('/app/home'),
        ),
      ),
      body: body,
    );
  }
}
