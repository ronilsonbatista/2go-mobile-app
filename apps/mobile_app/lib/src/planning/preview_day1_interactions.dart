import 'package:flutter/material.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_trips/trips.dart';

import '../di/app_dependencies.dart';

/// Day-1 preview bridges: Home cover catalog + lodging/detalhes (#18/#19/#TG-178).
class PreviewDay1Interactions {
  PreviewDay1Interactions(this.dependencies);

  final AppDependencies dependencies;

  Future<List<PreviewCoverCatalogEntry>> loadCoverCatalog() async {
    final destinations =
        await dependencies.homeContentRepository.fetchDestinations();
    final fromHome = destinations
        .map(
          (d) => PreviewCoverCatalogEntry(
            name: d.name,
            providerPlaceId: d.providerPlaceId,
            imageUrl: d.resolvedHeroUrl ?? d.resolvedCardUrl,
            assetPath: d.hasLocalHero ? d.heroAssetPath : null,
            assetPackage: d.hasLocalHero
                ? LocalHomeContentRepository.assetPackage
                : null,
          ),
        )
        .toList(growable: true);

    // Remote Home may return image URLs without packaged assets. Merge local
    // destination heroes so Lisboa/Roma/… still resolve when CDN URLs fail.
    try {
      final local = await LocalHomeContentRepository().fetchDestinations();
      for (final d in local) {
        if (!d.hasLocalHero) continue;
        final existingIndex = fromHome.indexWhere(
          (e) =>
              _sameDestinationName(e.name, d.name) ||
              (e.providerPlaceId != null &&
                  d.providerPlaceId != null &&
                  e.providerPlaceId == d.providerPlaceId),
        );
        if (existingIndex >= 0) {
          final existing = fromHome[existingIndex];
          if (existing.assetPath == null || existing.assetPath!.isEmpty) {
            fromHome[existingIndex] = PreviewCoverCatalogEntry(
              name: existing.name,
              providerPlaceId: existing.providerPlaceId ?? d.providerPlaceId,
              imageUrl: existing.imageUrl,
              assetPath: d.heroAssetPath,
              assetPackage: LocalHomeContentRepository.assetPackage,
            );
          }
        } else {
          fromHome.add(
            PreviewCoverCatalogEntry(
              name: d.name,
              providerPlaceId: d.providerPlaceId,
              imageUrl: d.resolvedHeroUrl ?? d.resolvedCardUrl,
              assetPath: d.heroAssetPath,
              assetPackage: LocalHomeContentRepository.assetPackage,
            ),
          );
        }
      }
    } catch (_) {
      // Local merge is best-effort; DestinationThumbCatalog still covers names.
    }

    return List<PreviewCoverCatalogEntry>.unmodifiable(fromHome);
  }

  static bool _sameDestinationName(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  Future<void> openAddLodging(
    BuildContext context, {
    required PlanningPreview preview,
  }) {
    final bias = _biasFromPreview(preview);
    return showAddAccommodationFlow(
      context,
      controls: TripControls(
        repository: dependencies.tripsRepository,
        reloadTrip: () async {},
        searchHotels: dependencies.searchHotelsUseCase,
        getPlaceDetails: dependencies.getPlaceDetailsUseCase,
      ),
      tripId: 'preview-${preview.id}',
      searchHotels: dependencies.searchHotelsUseCase,
      getPlaceDetails: dependencies.getPlaceDetailsUseCase,
      biasLatitude: bias.$1,
      biasLongitude: bias.$2,
      previewOnly: true,
    );
  }

  /// Opens meal-slot sheet, placed-item sheet → full page, matching #18 variants.
  Future<void> openActivityDetails(
    BuildContext context, {
    required PlanningVisibleActivity activity,
    ValueChanged<Uri>? onOpenUrl,
  }) async {
    final data = _viewDataFromActivity(activity);
    if (!context.mounted) return;

    if (data.isMealSlot) {
      await PlaceDetailsSheet.show(
        context,
        data: data,
        onOpenUrl: onOpenUrl,
        onShowSuggestions: () => Navigator.of(context).maybePop(),
      );
      return;
    }

    await PlaceDetailsSheet.show(
      context,
      data: data,
      onOpenUrl: onOpenUrl,
      onShowDetails: () async {
        if (!context.mounted) return;
        await PlaceDetailsPage.open<void>(
          context,
          data: data,
          onOpenUrl: onOpenUrl,
          onSelect: () => Navigator.of(context).maybePop(),
        );
      },
    );
  }

  static PlaceDetailsViewData _viewDataFromActivity(
    PlanningVisibleActivity activity,
  ) {
    final category = _mapCategory(activity.category);
    final mealSlot = _isPreviewMealSlot(activity);
    final kind = mealSlot
        ? PlaceDetailsKind.mealSlot
        : (activity.isMeal
            ? PlaceDetailsKind.restaurant
            : (category == ItineraryCategory.touristAttraction ||
                    category == ItineraryCategory.museum ||
                    category == ItineraryCategory.park ||
                    category == ItineraryCategory.paidActivity ||
                    category == ItineraryCategory.freeActivity
                ? PlaceDetailsKind.attraction
                : PlaceDetailsKind.other));

    final photos = <String>[];
    final image = activity.imageUrl?.trim();
    if (image != null && image.isNotEmpty) photos.add(image);

    final mapsUri = (activity.latitude != null && activity.longitude != null)
        ? PlanningTimelineItem.mapUrl(
            latitude: activity.latitude,
            longitude: activity.longitude,
          )
        : null;

    return PlaceDetailsViewData(
      displayName: activity.title,
      description: activity.description,
      address: activity.location,
      latitude: activity.latitude,
      longitude: activity.longitude,
      mapsUri: mapsUri,
      ticketUri: activity.ticketUrl,
      websiteUri: activity.reservationUrl ?? activity.ticketUrl,
      photoUrls: photos,
      timeLabel: activity.timeLabel,
      period: activity.period,
      durationMinutes: activity.duration,
      recommendedDurationMinutes: activity.duration,
      category: category,
      kind: kind,
      mode: mealSlot ? PlaceDetailsMode.edit : PlaceDetailsMode.pick,
      imageUrl: photos.isNotEmpty ? photos.first : null,
      priceLevelDisplay: activity.cost <= 0
          ? null
          : PlanningTimelineItem.costLabel(activity.cost),
    );
  }

  /// Generic meal period without a concrete place → Modal / Modal-1.
  static bool _isPreviewMealSlot(PlanningVisibleActivity activity) {
    if (!activity.isMeal) return false;
    final hasPlace = activity.providerPlaceId?.trim().isNotEmpty ?? false;
    if (hasPlace) return false;
    final title = activity.title.trim().toLowerCase();
    const slots = {
      'café da manhã',
      'cafe da manha',
      'almoço',
      'almoco',
      'jantar',
      'lanche',
      'pausa',
    };
    if (slots.contains(title)) return true;
    final desc = activity.description?.trim() ?? '';
    return desc.isEmpty && activity.latitude == null && activity.imageUrl == null;
  }

  static ItineraryCategory _mapCategory(String raw) {
    switch (raw.trim().toUpperCase()) {
      case 'MUSEUM':
        return ItineraryCategory.museum;
      case 'RESTAURANT':
        return ItineraryCategory.restaurant;
      case 'CAFE':
        return ItineraryCategory.cafe;
      case 'BAR':
        return ItineraryCategory.bar;
      case 'BEACH':
        return ItineraryCategory.beach;
      case 'PARK':
        return ItineraryCategory.park;
      case 'SHOPPING':
        return ItineraryCategory.shopping;
      case 'EXPERIENCE':
        return ItineraryCategory.experience;
      case 'TRANSPORT':
        return ItineraryCategory.transport;
      case 'EVENT':
        return ItineraryCategory.event;
      case 'NIGHTLIFE':
        return ItineraryCategory.nightlife;
      case 'FREE_ACTIVITY':
        return ItineraryCategory.freeActivity;
      case 'PAID_ACTIVITY':
        return ItineraryCategory.paidActivity;
      case 'TOURIST_ATTRACTION':
      default:
        return ItineraryCategory.touristAttraction;
    }
  }

  static (double?, double?) _biasFromPreview(PlanningPreview preview) {
    for (final day in preview.visibleDays) {
      for (final activity in day.activities) {
        if (activity.latitude != null && activity.longitude != null) {
          return (activity.latitude, activity.longitude);
        }
      }
    }
    return (null, null);
  }
}
