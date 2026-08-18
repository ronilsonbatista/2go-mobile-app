class PlanningActivityWindow {
  final String start;
  final String end;

  const PlanningActivityWindow({this.start = '09:00', this.end = '18:30'});

  String get startTime => start;
  String get endTime => end;

  PlanningActivityWindow copyWith({
    String? start,
    String? end,
    String? startTime,
    String? endTime,
  }) {
    return PlanningActivityWindow(
      start: start ?? startTime ?? this.start,
      end: end ?? endTime ?? this.end,
    );
  }

  Map<String, dynamic> toJson() => {'startTime': start, 'endTime': end};

  factory PlanningActivityWindow.fromJson(Map<String, dynamic> json) {
    return PlanningActivityWindow(
      start: (json['startTime'] ?? json['start']) as String? ?? '09:00',
      end: (json['endTime'] ?? json['end']) as String? ?? '18:30',
    );
  }
}
