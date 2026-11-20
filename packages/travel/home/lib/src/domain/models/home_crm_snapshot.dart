import 'package:equatable/equatable.dart';

import 'home_tip.dart';
import 'home_trip_summary.dart';

/// Authenticated paid-trip Home CRM from `GET /home/trip`.
///
/// When [trip] is null → app stays on discovery Home (`GET /home/destinations`).
class HomeCrmSnapshot extends Equatable {
  const HomeCrmSnapshot({
    this.trip,
    this.tips = const [],
  });

  static const empty = HomeCrmSnapshot();

  /// Next paid unlocked trip, or null.
  final HomeTripSummary? trip;

  /// Tips for the trip (from aggregate or `GET /home/tips`). Already ≤3/dest.
  final List<HomeTip> tips;

  bool get hasPaidTrip => trip != null;

  /// Convenience: single-item list for PageView when a trip exists.
  List<HomeTripSummary> get upcomingTrips =>
      trip == null ? const [] : [trip!];

  bool get hasUpcoming => hasPaidTrip;

  @override
  List<Object?> get props => [trip, tips];
}
