import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import 'package:twogo_planning/twogo_planning.dart';

import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trips_repository.dart';
import '../bloc/trips_cubit.dart';
import 'paid_trip_preview_view.dart';
import 'trip_control_sheets.dart';

/// Aba de viagens depois do pagamento.
///
/// Sem id, fica vazia. Com id, abre `GET /trips/:id`.
class HandoffTripsView extends StatefulWidget {
  final TripsRepository tripsRepository;
  final String? tripId;
  final int? initialDayNumber;
  final ValueChanged<Uri>? onOpenUrl;
  final SearchHotelsUseCase? searchHotels;
  final GetPlaceDetailsUseCase? getPlaceDetails;
  final SearchPlacesUseCase? searchPlaces;
  final ValueChanged<TripEntity>? onShare;
  final VoidCallback? onClose;
  final bool showInviteAcceptedToast;
  final Future<List<PreviewCoverCatalogEntry>> Function()? loadCoverCatalog;

  const HandoffTripsView({
    super.key,
    required this.tripsRepository,
    this.tripId,
    this.initialDayNumber,
    this.onOpenUrl,
    this.searchHotels,
    this.getPlaceDetails,
    this.searchPlaces,
    this.onShare,
    this.onClose,
    this.showInviteAcceptedToast = false,
    this.loadCoverCatalog,
  });

  @override
  State<HandoffTripsView> createState() => _HandoffTripsViewState();
}

class _HandoffTripsViewState extends State<HandoffTripsView> {
  late final TripsCubit _cubit;
  bool _inviteToastShown = false;

  @override
  void initState() {
    super.initState();
    _cubit = TripsCubit(tripsRepository: widget.tripsRepository);
    _cubit.loadTrip(widget.tripId);
  }

  void _maybeShowInviteToast() {
    if (!widget.showInviteAcceptedToast || _inviteToastShown) return;
    _inviteToastShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      TwoGoSnackbar.show(
        context,
        message: 'Convite aceito',
        variant: TwoGoSnackbarVariant.success,
      );
    });
  }

  @override
  void didUpdateWidget(covariant HandoffTripsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripId != widget.tripId) {
      _cubit.loadTrip(widget.tripId);
    }
  }

  @override
  void dispose() {
    _cubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TripsState>(
      valueListenable: _cubit,
      builder: (context, state, _) {
        switch (state.status) {
          case TripsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case TripsStatus.error:
            return const _TripsMessage(
              title: 'Não foi possível carregar a viagem',
              body: 'Tente abrir o roteiro de novo a partir do pagamento.',
            );
          case TripsStatus.initial:
          case TripsStatus.loaded:
            if (state.trips.isEmpty) {
              return const _TripsMessage(
                title: 'Minhas Viagens',
                body:
                    'Seus roteiros e itinerários detalhados aparecerão nesta aba.',
              );
            }
            final trip = state.trips.first;
            _maybeShowInviteToast();
            return PaidTripPreviewView(
              trip: trip,
              initialDayNumber: widget.initialDayNumber,
              onOpenUrl: widget.onOpenUrl,
              onClose: widget.onClose,
              loadCoverCatalog: widget.loadCoverCatalog,
              onShare: widget.onShare == null
                  ? null
                  : () => widget.onShare!(trip),
              controls: TripControls(
                repository: widget.tripsRepository,
                reloadTrip: () => _cubit.loadTrip(widget.tripId),
                searchHotels: widget.searchHotels,
                getPlaceDetails: widget.getPlaceDetails,
                searchPlaces: widget.searchPlaces,
              ),
            );
        }
      },
    );
  }
}

class _TripsMessage extends StatelessWidget {
  final String title;
  final String body;

  const _TripsMessage({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TwoGoCenteredContent(
        maxWidth: 390,
        child: Padding(
          padding: const EdgeInsets.all(TwoGoSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TwoGoTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.xs),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
