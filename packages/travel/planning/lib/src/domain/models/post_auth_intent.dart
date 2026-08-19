enum PostAuthIntentType { normalLogin, claimGuestJourney, resumeCheckout }

class PostAuthIntent {
  final PostAuthIntentType type;
  final String? journeyId;
  final String? productId;
  final String? tripId;
  final DateTime createdAt;

  const PostAuthIntent({
    required this.type,
    this.journeyId,
    this.productId,
    this.tripId,
    required this.createdAt,
  });

  static PostAuthIntent get normal => PostAuthIntent(
    type: PostAuthIntentType.normalLogin,
    createdAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'journeyId': journeyId,
    'productId': productId,
    'tripId': tripId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PostAuthIntent.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'normalLogin';
    final type = PostAuthIntentType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => PostAuthIntentType.normalLogin,
    );
    return PostAuthIntent(
      type: type,
      journeyId: json['journeyId'] as String?,
      productId: json['productId'] as String?,
      tripId: json['tripId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
