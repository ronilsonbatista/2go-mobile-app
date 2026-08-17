enum ProductType { itineraryFullAccess, aiCredits, premiumTemplate }

class ProductEntity {
  final String id;
  final String name;
  final String? description;
  final ProductType type;
  final double price;
  final String currency;
  final bool active;

  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.currency = 'BRL',
    this.active = true,
  });
}
