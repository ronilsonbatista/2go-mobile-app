class GenerationStatusResponseDto {
  final String id;
  final String status;
  final String? generationStartedAt;
  final String? generationCompletedAt;
  final String? generationFailedAt;
  final String? generationErrorCode;

  const GenerationStatusResponseDto({
    required this.id,
    required this.status,
    this.generationStartedAt,
    this.generationCompletedAt,
    this.generationFailedAt,
    this.generationErrorCode,
  });

  factory GenerationStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return GenerationStatusResponseDto(
      id: json['id'] as String,
      status: json['status'] as String,
      generationStartedAt: json['generationStartedAt'] as String?,
      generationCompletedAt: json['generationCompletedAt'] as String?,
      generationFailedAt: json['generationFailedAt'] as String?,
      generationErrorCode: json['generationErrorCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      if (generationStartedAt != null)
        'generationStartedAt': generationStartedAt,
      if (generationCompletedAt != null)
        'generationCompletedAt': generationCompletedAt,
      if (generationFailedAt != null) 'generationFailedAt': generationFailedAt,
      if (generationErrorCode != null)
        'generationErrorCode': generationErrorCode,
    };
  }
}
