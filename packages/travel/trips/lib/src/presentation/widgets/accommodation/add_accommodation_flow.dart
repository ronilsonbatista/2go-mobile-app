import 'package:flutter/material.dart';
import 'package:twogo_places/places.dart';

import '../../../domain/entities/trip_entity.dart';
import '../trip_control_sheets.dart';
import 'add_accommodation_search_page.dart';

/// Opens the Adicionar hospedagem flow (search → details → save).
Future<void> showAddAccommodationFlow(
  BuildContext context, {
  required TripControls controls,
  required String tripId,
  required SearchHotelsUseCase searchHotels,
  required GetPlaceDetailsUseCase getPlaceDetails,
  TripEntity? trip,
  double? biasLatitude,
  double? biasLongitude,
  /// Guest Day-1 preview: search/browse without Core trip save.
  bool previewOnly = false,
}) {
  final bias = _resolveBias(
    trip: trip,
    latitude: biasLatitude,
    longitude: biasLongitude,
  );
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => AddAccommodationSearchPage(
        controls: controls,
        tripId: tripId,
        searchHotels: searchHotels,
        getPlaceDetails: getPlaceDetails,
        biasLatitude: bias.$1,
        biasLongitude: bias.$2,
        previewOnly: previewOnly,
      ),
    ),
  );
}

(double?, double?) _resolveBias({
  TripEntity? trip,
  double? latitude,
  double? longitude,
}) {
  if (latitude != null && longitude != null) {
    return (latitude, longitude);
  }
  final stay = trip?.accommodation;
  if (stay?.latitude != null && stay?.longitude != null) {
    return (stay!.latitude, stay.longitude);
  }
  for (final day in trip?.days ?? const []) {
    for (final item in day.items) {
      if (item.latitude != null && item.longitude != null) {
        return (item.latitude, item.longitude);
      }
    }
  }
  return (null, null);
}
