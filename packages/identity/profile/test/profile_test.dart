import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_profile/profile.dart';

void main() {
  group('Profile Package Tests (UserTravelProfile contracts)', () {
    late MockProfileDataSource mockDataSource;
    late ProfileRepositoryImpl profileRepository;
    late ProfileCubit profileCubit;

    setUp(() {
      mockDataSource = MockProfileDataSource();
      profileRepository = ProfileRepositoryImpl(
        remoteDataSource: mockDataSource,
      );
      profileCubit = ProfileCubit(profileRepository: profileRepository);
    });

    tearDown(() {
      profileCubit.dispose();
    });

    test('loadProfile loads traveler profile successfully', () async {
      await profileCubit.loadProfile();

      expect(profileCubit.value.status, ProfileStatus.loaded);
      expect(profileCubit.value.profile, isNotNull);
      expect(profileCubit.value.profile!.favoriteCountries, contains('França'));
      expect(profileCubit.value.profile!.prefersGastronomy, isTrue);
    });

    test('updateProfile saves changes', () async {
      await profileCubit.loadProfile();
      final current = profileCubit.value.profile!;
      final updated = current.copyWith(bio: 'Nova bio atualizada');

      await profileCubit.updateProfile(updated);

      expect(profileCubit.value.status, ProfileStatus.loaded);
      expect(profileCubit.value.profile!.bio, 'Nova bio atualizada');
    });
  });
}
