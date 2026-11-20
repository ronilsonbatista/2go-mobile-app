import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import 'package:twogo_trips/trips.dart';

class TripsPage extends StatelessWidget {
  final TripsRepository tripsRepository;
  final String? tripId;
  final SearchHotelsUseCase? searchHotels;
  final GetPlaceDetailsUseCase? getPlaceDetails;
  final ValueChanged<TripEntity>? onShare;
  final bool showInviteAcceptedToast;

  const TripsPage({
    super.key,
    required this.tripsRepository,
    this.tripId,
    this.searchHotels,
    this.getPlaceDetails,
    this.onShare,
    this.showInviteAcceptedToast = false,
  });

  @override
  Widget build(BuildContext context) {
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
      body: HandoffTripsView(
        tripsRepository: tripsRepository,
        tripId: tripId,
        searchHotels: searchHotels,
        getPlaceDetails: getPlaceDetails,
        onShare: onShare,
        showInviteAcceptedToast: showInviteAcceptedToast,
      ),
    );
  }
}
