import '../../domain/entities/user_travel_profile_entity.dart';

class UserTravelProfileDto {
  final String id;
  final String userId;
  final String? bio;
  final List<String> preferredStyles;
  final String? budgetLevel;
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

  const UserTravelProfileDto({
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

  factory UserTravelProfileDto.fromJson(Map<String, dynamic> json) {
    return UserTravelProfileDto(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      bio: json['bio'] as String?,
      preferredStyles:
          (json['preferredStyles'] as List<dynamic>?)?.cast<String>() ??
          const [],
      budgetLevel: json['budgetLevel'] as String?,
      favoriteCountries:
          (json['favoriteCountries'] as List<dynamic>?)?.cast<String>() ??
          const [],
      favoriteCities:
          (json['favoriteCities'] as List<dynamic>?)?.cast<String>() ??
          const [],
      preferredLanguages:
          (json['preferredLanguages'] as List<dynamic>?)?.cast<String>() ??
          const [],
      foodPreferences:
          (json['foodPreferences'] as List<dynamic>?)?.cast<String>() ??
          const [],
      accessibilityNeeds:
          (json['accessibilityNeeds'] as List<dynamic>?)?.cast<String>() ??
          const [],
      travelInterests:
          (json['travelInterests'] as List<dynamic>?)?.cast<String>() ??
          const [],
      prefersNightlife: json['prefersNightlife'] as bool? ?? false,
      prefersNature: json['prefersNature'] as bool? ?? false,
      prefersGastronomy: json['prefersGastronomy'] as bool? ?? false,
      prefersMuseums: json['prefersMuseums'] as bool? ?? false,
      prefersShopping: json['prefersShopping'] as bool? ?? false,
      prefersRelaxing: json['prefersRelaxing'] as bool? ?? false,
      averageTripDuration: json['averageTripDuration'] as int?,
      passportCountry: json['passportCountry'] as String?,
      instagramHandle: json['instagramHandle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bio': bio,
      'preferredStyles': preferredStyles,
      'budgetLevel': budgetLevel,
      'favoriteCountries': favoriteCountries,
      'favoriteCities': favoriteCities,
      'preferredLanguages': preferredLanguages,
      'foodPreferences': foodPreferences,
      'accessibilityNeeds': accessibilityNeeds,
      'travelInterests': travelInterests,
      'prefersNightlife': prefersNightlife,
      'prefersNature': prefersNature,
      'prefersGastronomy': prefersGastronomy,
      'prefersMuseums': prefersMuseums,
      'prefersShopping': prefersShopping,
      'prefersRelaxing': prefersRelaxing,
      'averageTripDuration': averageTripDuration,
      'passportCountry': passportCountry,
      'instagramHandle': instagramHandle,
    };
  }

  UserTravelProfileEntity toEntity() {
    return UserTravelProfileEntity(
      id: id,
      userId: userId,
      bio: bio,
      preferredStyles: preferredStyles
          .map(
            (s) => TravelStyle.values.firstWhere(
              (e) => e.name.toUpperCase() == s.toUpperCase(),
              orElse: () => TravelStyle.cultural,
            ),
          )
          .toList(),
      budgetLevel: budgetLevel != null
          ? BudgetLevel.values.firstWhere(
              (e) => e.name.toUpperCase() == budgetLevel!.toUpperCase(),
              orElse: () => BudgetLevel.medium,
            )
          : null,
      favoriteCountries: favoriteCountries,
      favoriteCities: favoriteCities,
      preferredLanguages: preferredLanguages,
      foodPreferences: foodPreferences,
      accessibilityNeeds: accessibilityNeeds,
      travelInterests: travelInterests,
      prefersNightlife: prefersNightlife,
      prefersNature: prefersNature,
      prefersGastronomy: prefersGastronomy,
      prefersMuseums: prefersMuseums,
      prefersShopping: prefersShopping,
      prefersRelaxing: prefersRelaxing,
      averageTripDuration: averageTripDuration,
      passportCountry: passportCountry,
      instagramHandle: instagramHandle,
    );
  }
}
