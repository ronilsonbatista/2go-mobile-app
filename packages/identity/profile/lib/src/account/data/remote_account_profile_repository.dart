import 'package:dio/dio.dart';
import 'package:twogo_networking/twogo_networking.dart';

import '../domain/account_profile.dart';
import '../domain/account_profile_repository.dart';
import 'account_profile_parser.dart';

/// Wires existing Core endpoints only:
/// - `GET /users/me`
/// - `POST /media/upload/avatar`
class RemoteAccountProfileRepository implements AccountProfileRepository {
  RemoteAccountProfileRepository({
    required Dio dio,
    AccountProfileParser parser = const AccountProfileParser(),
  })  : _dio = dio,
        _parser = parser;

  final Dio _dio;
  final AccountProfileParser _parser;

  static const String mePath = '/users/me';
  static const String avatarUploadPath = '/media/upload/avatar';

  @override
  Future<AccountProfile> fetchMe({String? fallbackEmail}) async {
    try {
      final response = await _dio.get<dynamic>(mePath);
      return _parser.parse(response.data, fallbackEmail: fallbackEmail);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  @override
  Future<String> uploadAvatar({
    required List<int> bytes,
    required String filename,
    String? contentType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: contentType != null
              ? DioMediaType.parse(contentType)
              : null,
        ),
      });
      final response = await _dio.post<dynamic>(
        avatarUploadPath,
        data: formData,
      );
      final url = _extractUrl(response.data);
      if (url == null || url.isEmpty) {
        throw StateError('Avatar upload response missing url');
      }
      return url;
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  String? _extractUrl(dynamic payload) {
    if (payload == null) return null;
    if (payload is String) return payload;
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final direct = map['url'];
      if (direct is String && direct.trim().isNotEmpty) return direct.trim();
      final data = map['data'];
      if (data is Map) {
        final nested = data['url'];
        if (nested is String && nested.trim().isNotEmpty) {
          return nested.trim();
        }
      }
    }
    return null;
  }
}
