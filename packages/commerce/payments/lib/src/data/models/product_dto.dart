import '../../domain/entities/product_entity.dart';

class ProductDto {
  final String id;
  final String name;
  final String? description;
  final String type;
  final double price;
  final String currency;
  final bool active;

  const ProductDto({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.currency = 'BRL',
    this.active = true,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'ITINERARY_FULL_ACCESS',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'currency': currency,
      'active': active,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      type: _mapType(type),
      price: price,
      currency: currency,
      active: active,
    );
  }

  static ProductType _mapType(String t) {
    switch (t.toUpperCase()) {
      case 'AI_CREDITS':
        return ProductType.aiCredits;
      case 'PREMIUM_TEMPLATE':
        return ProductType.premiumTemplate;
      case 'ITINERARY_FULL_ACCESS':
      default:
        return ProductType.itineraryFullAccess;
    }
  }
}
