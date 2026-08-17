import 'package:flutter/foundation.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trips_repository.dart';

enum TripsStatus { initial, loading, loaded, error }

class TripsState {
  final TripsStatus status;
  final List<TripEntity> trips;
  final String? errorMessage;

  const TripsState({
    required this.status,
    this.trips = const [],
    this.errorMessage,
  });

  factory TripsState.initial() => const TripsState(status: TripsStatus.initial);
  factory TripsState.loading() => const TripsState(status: TripsStatus.loading);
  factory TripsState.loaded(List<TripEntity> trips) =>
      TripsState(status: TripsStatus.loaded, trips: trips);
  factory TripsState.error(String message) =>
      TripsState(status: TripsStatus.error, errorMessage: message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripsState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          listEquals(trips, other.trips) &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => status.hashCode ^ trips.hashCode ^ errorMessage.hashCode;
}

class TripsCubit extends ValueNotifier<TripsState> {
  final TripsRepository _tripsRepository;

  TripsCubit({required TripsRepository tripsRepository})
    : _tripsRepository = tripsRepository,
      super(TripsState.initial());

  Future<void> loadMyTrips() async {
    value = TripsState.loading();
    try {
      final trips = await _tripsRepository.getMyTrips();
      value = TripsState.loaded(trips);
    } catch (e) {
      value = TripsState.error(e.toString());
    }
  }

  Future<void> createTrip(String title, String destination) async {
    value = TripsState.loading();
    try {
      await _tripsRepository.createTrip(title: title, destination: destination);
      await loadMyTrips();
    } catch (e) {
      value = TripsState.error(e.toString());
    }
  }
}
