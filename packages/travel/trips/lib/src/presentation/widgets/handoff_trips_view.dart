import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/repositories/trips_repository.dart';
import '../bloc/trips_cubit.dart';
import 'trip_itinerary_view.dart';

/// Aba de viagens depois do pagamento.
///
/// Sem id, fica vazia. Com id, abre `GET /trips/:id`.
class HandoffTripsView extends StatefulWidget {
  final TripsRepository tripsRepository;
  final String? tripId;
  final ValueChanged<Uri>? onOpenUrl;

  const HandoffTripsView({
    super.key,
    required this.tripsRepository,
    this.tripId,
    this.onOpenUrl,
  });

  @override
  State<HandoffTripsView> createState() => _HandoffTripsViewState();
}

class _HandoffTripsViewState extends State<HandoffTripsView> {
  late final TripsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TripsCubit(tripsRepository: widget.tripsRepository);
    _cubit.loadTrip(widget.tripId);
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
            return TripItineraryView(
              trip: state.trips.first,
              onOpenUrl: widget.onOpenUrl,
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
