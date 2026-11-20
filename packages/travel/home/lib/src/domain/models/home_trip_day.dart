import 'package:equatable/equatable.dart';

/// Day structure from `GET /home/trip` (`days[]`) — no pin body leakage.
class HomeTripDay extends Equatable {
  const HomeTripDay({
    required this.id,
    required this.dayNumber,
    this.date,
    this.destination,
    this.title,
    this.itemCount = 0,
  });

  final String id;
  final int dayNumber;
  final DateTime? date;

  /// Destination label for the day when Core resolves it.
  final String? destination;
  final String? title;
  final int itemCount;

  String get chipLabel {
    final dest = destination?.trim();
    if (dest != null && dest.isNotEmpty) {
      return 'Dia $dayNumber · $dest';
    }
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return 'Dia $dayNumber · $t';
    return 'Dia $dayNumber';
  }

  @override
  List<Object?> get props =>
      [id, dayNumber, date, destination, title, itemCount];
}
