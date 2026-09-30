import '../../domain/entities/trip_accommodation.dart';

class TripAccommodationDto {
  final String id;
  final String? name;
  final String? address;
  final String? neighborhood;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final String? providerPlaceId;
  final String? checkInDateTime;
  final String? checkOutDateTime;
  final String? checkInDate;
  final String? checkInTime;
  final String? checkOutDate;
  final String? checkOutTime;

  const TripAccommodationDto({
    required this.id,
    this.name,
    this.address,
    this.neighborhood,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.providerPlaceId,
    this.checkInDateTime,
    this.checkOutDateTime,
    this.checkInDate,
    this.checkInTime,
    this.checkOutDate,
    this.checkOutTime,
  });

  factory TripAccommodationDto.fromJson(Map<String, dynamic> json) {
    return TripAccommodationDto(
      id: json['id'] as String? ?? '',
      name: _text(json['name']),
      address: _text(json['address']),
      neighborhood: _text(json['neighborhood']),
      zipCode: _text(json['zipCode']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      providerPlaceId: _text(json['providerPlaceId']),
      checkInDateTime: _text(json['checkInDateTime']),
      checkOutDateTime: _text(json['checkOutDateTime']),
      checkInDate: _text(json['checkInDate']),
      checkInTime: _text(json['checkInTime']),
      checkOutDate: _text(json['checkOutDate']),
      checkOutTime: _text(json['checkOutTime']),
    );
  }

  TripAccommodation toEntity() {
    return TripAccommodation(
      id: id,
      name: name,
      address: address,
      neighborhood: neighborhood,
      zipCode: zipCode,
      latitude: latitude,
      longitude: longitude,
      providerPlaceId: providerPlaceId,
      checkInDateTime: _date(checkInDateTime),
      checkOutDateTime: _date(checkOutDateTime),
      checkInDate: _date(checkInDate),
      checkInTime: checkInTime,
      checkOutDate: _date(checkOutDate),
      checkOutTime: checkOutTime,
    );
  }
}

String? _text(dynamic raw) {
  if (raw is! String) return null;
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

DateTime? _date(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
