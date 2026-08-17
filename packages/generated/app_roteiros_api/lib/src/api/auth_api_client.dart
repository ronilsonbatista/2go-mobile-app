import 'package:dio/dio.dart';
import '../models/auth_tokens_response_dto.dart';
import '../models/forgot_password_dto.dart';
import '../models/login_dto.dart';
import '../models/refresh_token_dto.dart';
import '../models/request_otp_dto.dart';
import '../models/reset_password_dto.dart';
import '../models/signup_dto.dart';
import '../models/verify_otp_dto.dart';

class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  Future<Map<String, dynamic>> requestOtp(RequestOtpDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: dto.toJson(),
    );
    return response.data ?? {};
  }

  Future<AuthTokensResponseDto> verifyOtp(VerifyOtpDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: dto.toJson(),
    );
    return AuthTokensResponseDto.fromJson(response.data ?? {});
  }

  Future<Map<String, dynamic>> signup(SignupDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: dto.toJson(),
    );
    return response.data ?? {};
  }

  Future<AuthTokensResponseDto> login(LoginDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: dto.toJson(),
    );
    return AuthTokensResponseDto.fromJson(response.data ?? {});
  }

  Future<AuthTokensResponseDto> refresh(RefreshTokenDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: dto.toJson(),
    );
    return AuthTokensResponseDto.fromJson(response.data ?? {});
  }

  Future<void> logout([RefreshTokenDto? dto]) async {
    await _dio.post<void>('/auth/logout', data: dto?.toJson());
  }

  Future<void> logoutAll() async {
    await _dio.post<void>('/auth/logout-all');
  }

  Future<Map<String, dynamic>> forgotPassword(ForgotPasswordDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/password/forgot',
      data: dto.toJson(),
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> resetPassword(ResetPasswordDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/password/reset',
      data: dto.toJson(),
    );
    return response.data ?? {};
  }
}
