import '../entities/user_travel_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserTravelProfileEntity> getProfile();
  Future<UserTravelProfileEntity> updateProfile(
    UserTravelProfileEntity profile,
  );
  Future<void> deleteProfile();
}
