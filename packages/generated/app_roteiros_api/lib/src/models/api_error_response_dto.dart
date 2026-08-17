class ApiErrorResponseDto {
  final bool success;
  final String? code;
  final dynamic message;
  final int statusCode;
  final String timestamp;
  final String path;

  const ApiErrorResponseDto({
    required this.success,
    this.code,
    required this.message,
    required this.statusCode,
    required this.timestamp,
    required this.path,
  });

  factory ApiErrorResponseDto.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponseDto(
      success: json['success'] as bool? ?? false,
      code: json['code'] as String?,
      message: json['message'],
      statusCode: json['statusCode'] as int? ?? 500,
      timestamp: json['timestamp'] as String? ?? '',
      path: json['path'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'message': message,
      'statusCode': statusCode,
      'timestamp': timestamp,
      'path': path,
    };
  }

  String get formattedMessage {
    if (message is List) {
      return (message as List).join(', ');
    }
    return message?.toString() ?? 'Erro desconhecido';
  }
}
