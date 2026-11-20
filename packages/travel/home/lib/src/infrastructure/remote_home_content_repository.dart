import 'package:dio/dio.dart';

import '../domain/models/home_crm_snapshot.dart';
import '../domain/models/home_destination.dart';
import '../domain/models/home_profile.dart';
import '../domain/repositories/home_content_repository.dart';
import 'home_crm_remote.dart';
import 'home_destinations_parser.dart';
import 'home_profile_parser.dart';

/// Remote Home content over Core:
/// - `GET /home/destinations` (public, optional `?limit=1..50`)
/// - `GET /users/me` → nested `user.photoUrl` / `displayName`
/// - CRM: `GET /trips` + tips (see [HomeCrmRemote])
class RemoteHomeContentRepository implements HomeContentRepository {
  RemoteHomeContentRepository({
    required Dio dio,
    this.destinationsLimit = HomeDestinationsParser.defaultLimit,
    HomeDestinationsParser destinationsParser = const HomeDestinationsParser(),
    HomeProfileParser profileParser = const HomeProfileParser(),
    HomeCrmRemote? crmRemote,
  }) : _dio = dio,
       _destinationsParser = destinationsParser,
       _profileParser = profileParser,
       _crmRemote = crmRemote ?? HomeCrmRemote(dio: dio);

  final Dio _dio;
  final int destinationsLimit;
  final HomeDestinationsParser _destinationsParser;
  final HomeProfileParser _profileParser;
  final HomeCrmRemote _crmRemote;

  static const String destinationsPath = '/home/destinations';
  static const String mePath = '/users/me';

  @override
  Future<List<HomeDestination>> fetchDestinations() async {
    final limit = HomeDestinationsParser.clampLimit(destinationsLimit);
    final response = await _dio.get<dynamic>(
      destinationsPath,
      queryParameters: <String, dynamic>{'limit': limit},
      options: Options(
        // Public catalog: never trigger JWT refresh on anonymous 401s.
        extra: const <String, dynamic>{'skipAuthRefresh': true},
      ),
    );
    return _destinationsParser.parse(response.data, limit: limit);
  }

  @override
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  }) async {
    if (!isAuthenticated) {
      return HomeProfile.guest();
    }

    final fallbackName = _displayNameFrom(userId);
    final response = await _dio.get<dynamic>(mePath);
    return _profileParser.parse(
      response.data,
      fallbackDisplayName: fallbackName,
    );
  }

  @override
  Future<HomeCrmSnapshot> fetchCrmSnapshot({
    required bool isAuthenticated,
    String? userId,
  }) {
    return _crmRemote.fetch(isAuthenticated: isAuthenticated);
  }

  String _displayNameFrom(String? userId) {
    if (userId == null || userId.isEmpty) return 'Viajante';
    if (userId.contains('@')) {
      return userId.split('@').first;
    }
    return userId;
  }
}
