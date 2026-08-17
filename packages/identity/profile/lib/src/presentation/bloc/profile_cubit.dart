import 'package:flutter/foundation.dart';
import '../../domain/entities/user_travel_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final UserTravelProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({required this.status, this.profile, this.errorMessage});

  factory ProfileState.initial() =>
      const ProfileState(status: ProfileStatus.initial);
  factory ProfileState.loading() =>
      const ProfileState(status: ProfileStatus.loading);
  factory ProfileState.loaded(UserTravelProfileEntity profile) =>
      ProfileState(status: ProfileStatus.loaded, profile: profile);
  factory ProfileState.error(String message) =>
      ProfileState(status: ProfileStatus.error, errorMessage: message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          profile == other.profile &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^ profile.hashCode ^ errorMessage.hashCode;
}

class ProfileCubit extends ValueNotifier<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(ProfileState.initial());

  Future<void> loadProfile() async {
    value = ProfileState.loading();
    try {
      final profile = await _profileRepository.getProfile();
      value = ProfileState.loaded(profile);
    } catch (e) {
      value = ProfileState.error(e.toString());
    }
  }

  Future<void> updateProfile(UserTravelProfileEntity updated) async {
    value = ProfileState.loading();
    try {
      final result = await _profileRepository.updateProfile(updated);
      value = ProfileState.loaded(result);
    } catch (e) {
      value = ProfileState.error(e.toString());
    }
  }
}
