class PlanningPreviewSummaryDto {
  final List<dynamic> destinations;
  final String? startDate;
  final String? endDate;
  final int totalDays;
  final String? coverImageUrl;

  PlanningPreviewSummaryDto({
    required this.destinations,
    this.startDate,
    this.endDate,
    required this.totalDays,
    this.coverImageUrl,
  });

  factory PlanningPreviewSummaryDto.fromJson(Map<String, dynamic> json) {
    return PlanningPreviewSummaryDto(
      destinations: json['destinations'] as List<dynamic>? ?? [],
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      totalDays: json['totalDays'] as int? ?? 1,
      coverImageUrl: json['coverImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'destinations': destinations,
    'startDate': startDate,
    'endDate': endDate,
    'totalDays': totalDays,
    'coverImageUrl': coverImageUrl,
  };
}

class PlanningPreviewPolicyDto {
  final int visibleDayCount;
  final int autoPaywallDelaySeconds;

  PlanningPreviewPolicyDto({
    required this.visibleDayCount,
    required this.autoPaywallDelaySeconds,
  });

  factory PlanningPreviewPolicyDto.fromJson(Map<String, dynamic> json) {
    return PlanningPreviewPolicyDto(
      visibleDayCount: json['visibleDayCount'] as int? ?? 1,
      autoPaywallDelaySeconds: json['autoPaywallDelaySeconds'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
    'visibleDayCount': visibleDayCount,
    'autoPaywallDelaySeconds': autoPaywallDelaySeconds,
  };
}

class PlanningVisibleActivityDto {
  final String title;
  final String? description;
  final String category;
  final String? period;
  final String? timeLabel;
  final int? duration;
  final double cost;
  final int order;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? providerPlaceId;
  final String? imageUrl;
  final String? reservationUrl;
  final String? ticketUrl;
  final String sourceType;
  final String? sourceId;

  PlanningVisibleActivityDto({
    required this.title,
    this.description,
    required this.category,
    this.period,
    this.timeLabel,
    this.duration,
    required this.cost,
    required this.order,
    this.location,
    this.latitude,
    this.longitude,
    this.providerPlaceId,
    this.imageUrl,
    this.reservationUrl,
    this.ticketUrl,
    required this.sourceType,
    this.sourceId,
  });

  factory PlanningVisibleActivityDto.fromJson(Map<String, dynamic> json) {
    return PlanningVisibleActivityDto(
      title: json['title'] as String? ?? 'Atividade',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'TOURIST_ATTRACTION',
      period: json['period'] as String?,
      timeLabel: json['timeLabel'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      order: json['order'] as int? ?? 1,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      providerPlaceId: json['providerPlaceId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      reservationUrl: json['reservationUrl'] as String?,
      ticketUrl: json['ticketUrl'] as String?,
      sourceType: json['sourceType'] as String? ?? 'AI',
      sourceId: json['sourceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'period': period,
    'timeLabel': timeLabel,
    'duration': duration,
    'cost': cost,
    'order': order,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'providerPlaceId': providerPlaceId,
    'imageUrl': imageUrl,
    'reservationUrl': reservationUrl,
    'ticketUrl': ticketUrl,
    'sourceType': sourceType,
    'sourceId': sourceId,
  };
}

class PlanningVisibleDayDto {
  final int dayNumber;
  final String? date;
  final String destination;
  final String title;
  final String? description;
  final List<PlanningVisibleActivityDto> activities;

  PlanningVisibleDayDto({
    required this.dayNumber,
    this.date,
    required this.destination,
    required this.title,
    this.description,
    required this.activities,
  });

  factory PlanningVisibleDayDto.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['activities'] as List<dynamic>? ?? [];
    return PlanningVisibleDayDto(
      dayNumber: json['dayNumber'] as int? ?? 1,
      date: json['date'] as String?,
      destination: json['destination'] as String? ?? 'Destino',
      title: json['title'] as String? ?? 'Dia 1',
      description: json['description'] as String?,
      activities: rawActivities
          .map(
            (a) =>
                PlanningVisibleActivityDto.fromJson(a as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'date': date,
    'destination': destination,
    'title': title,
    'description': description,
    'activities': activities.map((a) => a.toJson()).toList(),
  };
}

class PlanningLockedDayDto {
  final int dayNumber;
  final String? date;
  final String destination;
  final String title;
  final bool locked;

  PlanningLockedDayDto({
    required this.dayNumber,
    this.date,
    required this.destination,
    required this.title,
    required this.locked,
  });

  factory PlanningLockedDayDto.fromJson(Map<String, dynamic> json) {
    return PlanningLockedDayDto(
      dayNumber: json['dayNumber'] as int? ?? 2,
      date: json['date'] as String?,
      destination: json['destination'] as String? ?? 'Destino',
      title: json['title'] as String? ?? 'Dia 2',
      locked: json['locked'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'date': date,
    'destination': destination,
    'title': title,
    'locked': locked,
  };
}

class PlanningUnlockOfferDto {
  final String? productId;
  final String code;
  final String name;

  /// Legacy alias; prefer [amount] (Core duration list price).
  final double price;

  /// Canonical list price from Core duration tiers.
  final double amount;

  final String currency;

  /// Trip length Core used for the tier.
  final int days;

  /// `UP_TO_7` | `FROM_8_TO_12` | `FROM_13`
  final String tier;

  final bool available;

  PlanningUnlockOfferDto({
    this.productId,
    required this.code,
    required this.name,
    required this.price,
    required this.amount,
    required this.currency,
    required this.days,
    required this.tier,
    required this.available,
  });

  factory PlanningUnlockOfferDto.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0;
    return PlanningUnlockOfferDto(
      productId: json['productId'] as String?,
      code: json['code'] as String? ?? 'ITINERARY_FULL_ACCESS',
      name: json['name'] as String? ?? 'Acesso Completo ao Roteiro',
      price: (json['price'] as num?)?.toDouble() ?? amount,
      amount: amount,
      currency: json['currency'] as String? ?? 'BRL',
      days: (json['days'] as num?)?.toInt() ?? 0,
      tier: json['tier'] as String? ?? '',
      available: json['available'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'code': code,
    'name': name,
    'price': price,
    'amount': amount,
    'currency': currency,
    'days': days,
    'tier': tier,
    'available': available,
  };
}

class PlanningPreviewResponseDto {
  final String id;
  final String status;
  final PlanningPreviewSummaryDto summary;
  final PlanningPreviewPolicyDto previewPolicy;
  final List<PlanningVisibleDayDto> visibleDays;
  final List<PlanningLockedDayDto> lockedDays;
  final PlanningUnlockOfferDto unlockOffer;

  PlanningPreviewResponseDto({
    required this.id,
    required this.status,
    required this.summary,
    required this.previewPolicy,
    required this.visibleDays,
    required this.lockedDays,
    required this.unlockOffer,
  });

  factory PlanningPreviewResponseDto.fromJson(Map<String, dynamic> json) {
    return PlanningPreviewResponseDto(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PREVIEW_READY',
      summary: PlanningPreviewSummaryDto.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? {},
      ),
      previewPolicy: PlanningPreviewPolicyDto.fromJson(
        (json['previewPolicy'] as Map<String, dynamic>?) ?? {},
      ),
      visibleDays: (json['visibleDays'] as List<dynamic>? ?? [])
          .map((d) => PlanningVisibleDayDto.fromJson(d as Map<String, dynamic>))
          .toList(),
      lockedDays: (json['lockedDays'] as List<dynamic>? ?? [])
          .map((d) => PlanningLockedDayDto.fromJson(d as Map<String, dynamic>))
          .toList(),
      unlockOffer: PlanningUnlockOfferDto.fromJson(
        (json['unlockOffer'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'summary': summary.toJson(),
    'previewPolicy': previewPolicy.toJson(),
    'visibleDays': visibleDays.map((d) => d.toJson()).toList(),
    'lockedDays': lockedDays.map((d) => d.toJson()).toList(),
    'unlockOffer': unlockOffer.toJson(),
  };
}
