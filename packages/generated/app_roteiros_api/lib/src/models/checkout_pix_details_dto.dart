class CheckoutPixDetailsDto {
  final String? copyPaste;
  final String? qrCodeBase64;
  final DateTime? expiresAt;
  final String? ticketUrl;

  const CheckoutPixDetailsDto({
    this.copyPaste,
    this.qrCodeBase64,
    this.expiresAt,
    this.ticketUrl,
  });

  factory CheckoutPixDetailsDto.fromJson(Map<String, dynamic> json) {
    return CheckoutPixDetailsDto(
      copyPaste: json['copyPaste'] as String?,
      qrCodeBase64: json['qrCodeBase64'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      ticketUrl: json['ticketUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'copyPaste': copyPaste,
      'qrCodeBase64': qrCodeBase64,
      'expiresAt': expiresAt?.toIso8601String(),
      'ticketUrl': ticketUrl,
    };
  }
}
