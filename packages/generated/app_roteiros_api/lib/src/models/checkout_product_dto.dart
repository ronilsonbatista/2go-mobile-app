class CheckoutProductDto {
  final String id;
  final String type;
  final String name;
  final String? description;

  const CheckoutProductDto({
    required this.id,
    required this.type,
    required this.name,
    this.description,
  });

  factory CheckoutProductDto.fromJson(Map<String, dynamic> json) {
    return CheckoutProductDto(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'description': description,
      };
}
