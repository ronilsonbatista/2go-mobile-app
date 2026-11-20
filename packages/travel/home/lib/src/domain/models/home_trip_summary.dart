import 'package:equatable/equatable.dart';

import 'home_tip.dart';
import 'home_trip_day.dart';
import 'home_trip_destination_label.dart';

/// Paid next-trip projection from `GET /home/trip` (`data.trip`).
///
/// Destination names and day labels come from Core — never hardcode cities.
class HomeTripSummary extends Equatable {
  const HomeTripSummary({
    required this.id,
    required this.destinationNames,
    this.title,
    this.coverImageUrl,
    this.startDate,
    this.endDate,
    this.arrivalDateTime,
    this.days = const [],
    this.tips = const [],
    this.premiumUnlocked = true,
    this.status,
    this.destinationKeys = const [],
  });

  final String id;
  final String? title;

  /// Ordered display names from `destinations[].name`.
  final List<String> destinationNames;

  /// Normalized keys for `GET /home/tips?destinationKey=`.
  final List<String> destinationKeys;

  final String? coverImageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? arrivalDateTime;
  final List<HomeTripDay> days;

  /// Tips already aggregated by Core (≤3 per destination).
  final List<HomeTip> tips;
  final bool premiumUnlocked;
  final String? status;

  String get destinationLabel =>
      HomeTripDestinationLabel.format(destinationNames);

  List<String> get stackedDestinationLines =>
      HomeTripDestinationLabel.stackedLines(destinationNames);

  String? get dateRangePrimary {
    final start = startDate ?? arrivalDateTime;
    if (start == null) return null;
    return HomeTripDestinationLabel.formatDayMonth(start);
  }

  String? get dateRangeSecondary {
    if (endDate == null) return null;
    return 'até ${HomeTripDestinationLabel.formatDayMonth(endDate!)}';
  }

  String get dateRangeInline {
    final start = dateRangePrimary;
    final end = dateRangeSecondary;
    if (start == null && end == null) return '';
    if (start != null && end != null) return '$start $end';
    return start ?? end ?? '';
  }

  /// Countdown prefers arrival datetime, else start date.
  DateTime? get countdownTarget => arrivalDateTime ?? startDate;

  @override
  List<Object?> get props => [
        id,
        title,
        destinationNames,
        destinationKeys,
        coverImageUrl,
        startDate,
        endDate,
        arrivalDateTime,
        days,
        tips,
        premiumUnlocked,
        status,
      ];
}
