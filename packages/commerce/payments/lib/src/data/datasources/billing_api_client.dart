import 'package:dio/dio.dart';
import 'package:app_roteiros_api/app_roteiros_api.dart';

class BillingApiClient {
  final Dio _dio;

  BillingApiClient(this._dio);

  Future<CheckoutSummaryResponseDto> getCheckoutSummary(String tripId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/trips/$tripId/checkout-summary',
    );
    return CheckoutSummaryResponseDto.fromJson(response.data ?? {});
  }

  Future<CheckoutQuoteResponseDto> getCheckoutQuote(
    String tripId,
    CheckoutQuoteDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/trips/$tripId/checkout-quote',
      data: dto.toJson(),
    );
    return CheckoutQuoteResponseDto.fromJson(response.data ?? {});
  }
}
