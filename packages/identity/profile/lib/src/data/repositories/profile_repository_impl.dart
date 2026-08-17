import '../../domain/entities/user_travel_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_travel_profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<UserTravelProfileEntity> getProfile() async {
    final dto = await _remoteDataSource.getProfile();
    return dto.toEntity();
  }

  @override
  Future<UserTravelProfileEntity> updateProfile(
    UserTravelProfileEntity profile,
  ) async {
    final dto = UserTravelProfileDto(
      id: profile.id,
      userId: profile.userId,
      bio: profile.bio,
      preferredStyles: profile.preferredStyles
          .map((e) => e.name.toUpperCase())
          .toList(),
      budgetLevel: profile.budgetLevel?.name.toUpperCase(),
      favoriteCountries: profile.favoriteCountries,
      favoriteCities: profile.favoriteCities,
      preferredLanguages: profile.preferredLanguages,
      foodPreferences: profile.foodPreferences,
      accessibilityNeeds: profile.accessibilityNeeds,
      travelInterests: profile.travelInterests,
      prefersNightlife: profile.prefersNightlife,
      prefersNature: profile.prefersNature,
      prefersGastronomy: profile.prefersGastronomy,
      prefersMuseums: profile.prefersMuseums,
      prefersShopping: profile.prefersShopping,
      prefersRelaxing: profile.prefersRelaxing,
      averageTripDuration: profile.averageTripDuration,
      passportCountry: profile.passportCountry,
      instagramHandle: profile.instagramHandle,
    );
    final updated = await _remoteDataSource.updateProfile(dto);
    return updated.toEntity();
  }

  @override
  Future<void> deleteProfile() async {
    await _remoteDataSource.deleteProfile();
  }
}
