enum TravelStyle {
  economic,
  comfort,
  luxury,
  adventure,
  family,
  romantic,
  party,
  cultural,
}

enum BudgetLevel { low, medium, high, premium }

class UserTravelProfileEntity {
  final String id;
  final String userId;
  final String? bio;
  final List<TravelStyle> preferredStyles;
  final BudgetLevel? budgetLevel;
  final List<String> favoriteCountries;
  final List<String> favoriteCities;
  final List<String> preferredLanguages;
  final List<String> foodPreferences;
  final List<String> accessibilityNeeds;
  final List<String> travelInterests;
  final bool prefersNightlife;
  final bool prefersNature;
  final bool prefersGastronomy;
  final bool prefersMuseums;
  final bool prefersShopping;
  final bool prefersRelaxing;
  final int? averageTripDuration;
  final String? passportCountry;
  final String? instagramHandle;

  const UserTravelProfileEntity({
    required this.id,
    required this.userId,
    this.bio,
    this.preferredStyles = const [],
    this.budgetLevel,
    this.favoriteCountries = const [],
    this.favoriteCities = const [],
    this.preferredLanguages = const [],
    this.foodPreferences = const [],
    this.accessibilityNeeds = const [],
    this.travelInterests = const [],
    this.prefersNightlife = false,
    this.prefersNature = false,
    this.prefersGastronomy = false,
    this.prefersMuseums = false,
    this.prefersShopping = false,
    this.prefersRelaxing = false,
    this.averageTripDuration,
    this.passportCountry,
    this.instagramHandle,
  });

  UserTravelProfileEntity copyWith({
    String? bio,
    List<TravelStyle>? preferredStyles,
    BudgetLevel? budgetLevel,
    List<String>? favoriteCountries,
    List<String>? favoriteCities,
    List<String>? preferredLanguages,
    List<String>? foodPreferences,
    List<String>? accessibilityNeeds,
    List<String>? travelInterests,
    bool? prefersNightlife,
    bool? prefersNature,
    bool? prefersGastronomy,
    bool? prefersMuseums,
    bool? prefersShopping,
    bool? prefersRelaxing,
    int? averageTripDuration,
    String? passportCountry,
    String? instagramHandle,
  }) {
    return UserTravelProfileEntity(
      id: id,
      userId: userId,
      bio: bio ?? this.bio,
      preferredStyles: preferredStyles ?? this.preferredStyles,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      favoriteCountries: favoriteCountries ?? this.favoriteCountries,
      favoriteCities: favoriteCities ?? this.favoriteCities,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      travelInterests: travelInterests ?? this.travelInterests,
      prefersNightlife: prefersNightlife ?? this.prefersNightlife,
      prefersNature: prefersNature ?? this.prefersNature,
      prefersGastronomy: prefersGastronomy ?? this.prefersGastronomy,
      prefersMuseums: prefersMuseums ?? this.prefersMuseums,
      prefersShopping: prefersShopping ?? this.prefersShopping,
      prefersRelaxing: prefersRelaxing ?? this.prefersRelaxing,
      averageTripDuration: averageTripDuration ?? this.averageTripDuration,
      passportCountry: passportCountry ?? this.passportCountry,
      instagramHandle: instagramHandle ?? this.instagramHandle,
    );
  }
}
