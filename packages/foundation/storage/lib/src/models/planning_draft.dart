class PlanningDraft {
  final String? activeJourneyId;
  final int currentStep;
  final List<Map<String, dynamic>>? destinations;
  final Map<String, dynamic>? travelers;
  final List<String>? interests;
  final Map<String, dynamic>? activityWindow;
  final String? budgetLevel;
  final String? travelStyle;
  final int answersVersion;
  final DateTime? lastSyncedAt;
  final bool isDirty;

  const PlanningDraft({
    this.activeJourneyId,
    this.currentStep = 1,
    this.destinations,
    this.travelers,
    this.interests,
    this.activityWindow,
    this.budgetLevel,
    this.travelStyle,
    this.answersVersion = 1,
    this.lastSyncedAt,
    this.isDirty = false,
  });

  PlanningDraft copyWith({
    String? activeJourneyId,
    int? currentStep,
    List<Map<String, dynamic>>? destinations,
    Map<String, dynamic>? travelers,
    List<String>? interests,
    Map<String, dynamic>? activityWindow,
    String? budgetLevel,
    String? travelStyle,
    int? answersVersion,
    DateTime? lastSyncedAt,
    bool? isDirty,
  }) {
    return PlanningDraft(
      activeJourneyId: activeJourneyId ?? this.activeJourneyId,
      currentStep: currentStep ?? this.currentStep,
      destinations: destinations ?? this.destinations,
      travelers: travelers ?? this.travelers,
      interests: interests ?? this.interests,
      activityWindow: activityWindow ?? this.activityWindow,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      travelStyle: travelStyle ?? this.travelStyle,
      answersVersion: answersVersion ?? this.answersVersion,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  Map<String, dynamic> toJson() => {
    if (activeJourneyId != null) 'activeJourneyId': activeJourneyId,
    'currentStep': currentStep,
    if (destinations != null) 'destinations': destinations,
    if (travelers != null) 'travelers': travelers,
    if (interests != null) 'interests': interests,
    if (activityWindow != null) 'activityWindow': activityWindow,
    if (budgetLevel != null) 'budgetLevel': budgetLevel,
    if (travelStyle != null) 'travelStyle': travelStyle,
    'answersVersion': answersVersion,
    if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt!.toIso8601String(),
    'isDirty': isDirty,
  };

  factory PlanningDraft.fromJson(Map<String, dynamic> json) {
    return PlanningDraft(
      activeJourneyId: json['activeJourneyId'] as String?,
      currentStep: json['currentStep'] as int? ?? 1,
      destinations: (json['destinations'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      travelers: json['travelers'] != null
          ? Map<String, dynamic>.from(json['travelers'] as Map)
          : null,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      activityWindow: json['activityWindow'] != null
          ? Map<String, dynamic>.from(json['activityWindow'] as Map)
          : null,
      budgetLevel: json['budgetLevel'] as String?,
      travelStyle: json['travelStyle'] as String?,
      answersVersion: json['answersVersion'] as int? ?? 1,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'] as String)
          : null,
      isDirty: json['isDirty'] as bool? ?? false,
    );
  }
}
