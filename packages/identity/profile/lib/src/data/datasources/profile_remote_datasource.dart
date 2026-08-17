import '../models/user_travel_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<UserTravelProfileDto> getProfile();
  Future<UserTravelProfileDto> updateProfile(UserTravelProfileDto dto);
  Future<void> deleteProfile();
}
