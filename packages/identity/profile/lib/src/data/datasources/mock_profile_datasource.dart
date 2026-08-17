import '../models/user_travel_profile_dto.dart';
import 'profile_remote_datasource.dart';

class MockProfileDataSource implements ProfileRemoteDataSource {
  UserTravelProfileDto _profile = const UserTravelProfileDto(
    id: 'prof_u49a21b3',
    userId: 'u49a21b3-5e18-4931-8544-a68394848a68',
    bio:
        'Apaixonado por gastronomia, museus e viagens culturais pela Europa e Ásia.',
    preferredStyles: ['CULTURAL', 'COMFORT'],
    budgetLevel: 'MEDIUM',
    favoriteCountries: ['França', 'Itália', 'Japão'],
    favoriteCities: ['Paris', 'Roma', 'Tóquio'],
    preferredLanguages: ['Português', 'Inglês', 'Francês'],
    foodPreferences: ['Sem lactose', 'Cozinha local'],
    travelInterests: ['Museus', 'Gastronomia', 'Fotografia'],
    prefersGastronomy: true,
    prefersMuseums: true,
    prefersNature: false,
    prefersNightlife: false,
    averageTripDuration: 7,
    passportCountry: 'Brasil',
    instagramHandle: '@joao_2go',
  );

  @override
  Future<UserTravelProfileDto> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _profile;
  }

  @override
  Future<UserTravelProfileDto> updateProfile(UserTravelProfileDto dto) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _profile = dto;
    return _profile;
  }

  @override
  Future<void> deleteProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
