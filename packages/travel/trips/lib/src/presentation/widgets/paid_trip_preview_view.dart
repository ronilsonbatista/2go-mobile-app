import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_planning/twogo_planning.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/entities/trip_accommodation.dart';
import '../../domain/entities/trip_day_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/place_details_view_data.dart';
import '../../domain/trip_to_planning_preview.dart';
import '../insert/insert_activity_page.dart';
import '../place_details/lodging_details_sheet.dart';
import '../place_details/place_details_sheet.dart';
import 'accommodation/add_accommodation_flow.dart';
import 'trip_control_sheets.dart';
import 'trip_itinerary_view.dart';

/// Paid / owned trip itinerary using the Day-1 **preview** layout
/// (hero + countdown + day chips + timeline) — not the dense Viagens list.
///
/// All days are unlocked. Home day chips open via [initialDayNumber].
class PaidTripPreviewView extends StatefulWidget {
  final TripEntity trip;
  final ValueChanged<Uri>? onOpenUrl;
  final TripControls? controls;
  final VoidCallback? onShare;
  final int? initialDayNumber;
  final VoidCallback? onClose;
  final DateTime Function()? now;
  final ImageProvider Function(String url)? coverImageProviderBuilder;
  final Future<List<PreviewCoverCatalogEntry>> Function()? loadCoverCatalog;

  const PaidTripPreviewView({
    super.key,
    required this.trip,
    this.onOpenUrl,
    this.controls,
    this.onShare,
    this.initialDayNumber,
    this.onClose,
    this.now,
    this.coverImageProviderBuilder,
    this.loadCoverCatalog,
  });

  @override
  State<PaidTripPreviewView> createState() => _PaidTripPreviewViewState();
}

class _PaidTripPreviewViewState extends State<PaidTripPreviewView> {
  late int _selectedDay;
  late PlanningPreview _preview;
  ImageProvider? _resolvedHeroImage;
  ImageProvider? _resolvedHeroFallback;
  String? _heroResolutionKey;

  @override
  void initState() {
    super.initState();
    _preview = tripToPlanningPreview(widget.trip);
    _selectedDay = _resolveInitialDay(
      widget.initialDayNumber,
      _preview,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resolveHeroCover(_preview.summary);
    });
  }

  @override
  void didUpdateWidget(covariant PaidTripPreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip != widget.trip) {
      _preview = tripToPlanningPreview(widget.trip);
      if (findTripDay(widget.trip, _selectedDay) == null) {
        _selectedDay = _resolveInitialDay(widget.initialDayNumber, _preview);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resolveHeroCover(_preview.summary);
      });
    } else if (oldWidget.initialDayNumber != widget.initialDayNumber &&
        widget.initialDayNumber != null) {
      final next = _resolveInitialDay(widget.initialDayNumber, _preview);
      if (next != _selectedDay) {
        _selectedDay = next;
      }
    }
  }

  static int _resolveInitialDay(int? requested, PlanningPreview preview) {
    final days = preview.visibleDays;
    if (days.isEmpty) return requested ?? 1;
    if (requested != null) {
      for (final d in days) {
        if (d.dayNumber == requested) return requested;
      }
    }
    final sorted = [...days]..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return sorted.first.dayNumber;
  }

  Future<void> _resolveHeroCover(PlanningPreviewSummary summary) async {
    final key =
        '${summary.coverImageUrl}|${summary.destinations}|${summary.totalDays}';
    if (_heroResolutionKey == key &&
        (_resolvedHeroImage != null || _resolvedHeroFallback != null)) {
      return;
    }
    _heroResolutionKey = key;

    List<PreviewCoverCatalogEntry> catalog = const [];
    final loader = widget.loadCoverCatalog;
    if (loader != null) {
      try {
        catalog = await loader();
      } catch (_) {
        catalog = const [];
      }
    }

    final resolution = resolvePreviewCover(
      summary: summary,
      catalog: catalog,
    );
    if (!mounted) return;

    ImageProvider? primary;
    ImageProvider? fallback;
    final url = resolution?.networkUrl?.trim();
    final asset = resolution?.toAssetImageProvider();
    if (url != null && url.isNotEmpty) {
      primary =
          widget.coverImageProviderBuilder?.call(url) ?? NetworkImage(url);
      fallback = asset;
    } else {
      primary = asset ?? resolution?.toImageProvider();
      fallback = null;
    }

    if (!mounted) return;
    setState(() {
      _resolvedHeroImage = primary;
      _resolvedHeroFallback = fallback;
    });
  }

  String get _destinationName {
    final d = widget.trip.destination.trim();
    if (d.isNotEmpty) return d;
    final t = widget.trip.title.trim();
    return t.isNotEmpty ? t : 'Sua Viagem';
  }

  void _close() {
    final close = widget.onClose;
    if (close != null) {
      close();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _save() {
    TwoGoSnackbar.show(
      context,
      message: 'Roteiro salvo',
      variant: TwoGoSnackbarVariant.success,
    );
    _close();
  }

  Future<void> _openItemDetails(ItineraryItemEntity item) async {
    final c = widget.controls;
    if (c == null) return;
    await showPlaceDetailsFlow(
      context,
      item: item,
      controls: c,
      onOpenUrl: widget.onOpenUrl,
    );
  }

  Future<void> _openItemMenu(ItineraryItemEntity item) async {
    final c = widget.controls;
    if (c == null) {
      await _openItemDetails(item);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: TwoGoColors.surfacePrimary,
      shape: const RoundedRectangleBorder(borderRadius: TwoGoRadius.sheetTop),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Detalhes'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openItemDetails(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded),
                title: const Text('Substituir'),
                onTap: () {
                  Navigator.pop(ctx);
                  showAlternativesSheet(
                    context,
                    controls: c,
                    itemId: item.id,
                    destinationHint: widget.trip.destination,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Duração'),
                onTap: () {
                  Navigator.pop(ctx);
                  showDurationEditor(
                    context,
                    controls: c,
                    itemId: item.id,
                    currentDuration: item.duration,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: TwoGoColors.error,
                ),
                title: Text(
                  'Excluir',
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.error,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _deleteItem(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteItem(ItineraryItemEntity item) async {
    final c = widget.controls;
    if (c == null) return;
    try {
      await c.repository.deleteItineraryItem(item.id);
      await c.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(apiErrorMessage(error)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openAddOrEditAccommodation() async {
    final c = widget.controls;
    if (c == null) return;
    final trip = widget.trip;
    if (c.canSearchHotels) {
      await showAddAccommodationFlow(
        context,
        controls: c,
        tripId: trip.id,
        searchHotels: c.searchHotels!,
        getPlaceDetails: c.getPlaceDetails!,
        trip: trip,
      );
      return;
    }
    await showAccommodationSheet(
      context,
      controls: c,
      tripId: trip.id,
    );
  }

  Future<void> _openLodgingDetails({
    required TripAccommodation stay,
    required PlaceDetailsKind kind,
  }) async {
    await showLodgingDetailsFlow(
      context,
      stay: stay,
      kind: kind,
      onOpenUrl: widget.onOpenUrl,
      onChangeLodging: widget.controls == null
          ? null
          : _openAddOrEditAccommodation,
    );
  }

  void _openMapForDay(PlanningVisibleDay? day) {
    if (day == null || widget.onOpenUrl == null) return;
    PlanningVisibleActivity? withCoords;
    for (final a in day.activities) {
      if (a.latitude != null && a.longitude != null) {
        withCoords = a;
        break;
      }
    }
    final link = PlanningTimelineItem.mapUrl(
      latitude: withCoords?.latitude,
      longitude: withCoords?.longitude,
    );
    final uri = link == null ? null : Uri.tryParse(link);
    if (uri != null) widget.onOpenUrl!(uri);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _preview.summary;

    final visibleDay = _preview.visibleDays
        .cast<PlanningVisibleDay?>()
        .firstWhere((d) => d?.dayNumber == _selectedDay, orElse: () => null);
    final tripDay = findTripDay(widget.trip, _selectedDay);

    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _PaidHeroHeader(
                  coverImage: _resolvedHeroImage,
                  coverImageFallback: _resolvedHeroFallback,
                  coverImageUrl: summary.resolvedCoverImageUrl,
                  destinationName: _destinationName,
                  coverImageProviderBuilder: widget.coverImageProviderBuilder,
                  onClose: _close,
                  onSave: _save,
                  onShare: widget.onShare,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TwoGoSpacing.md,
                    TwoGoSpacing.sm,
                    TwoGoSpacing.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlanningPreviewCountdown(
                        startDate: summary.startDate,
                        now: widget.now,
                      ),
                      const SizedBox(height: TwoGoSpacing.md),
                      PlanningPreviewDayChips(
                        preview: _preview,
                        selectedDayNumber: _selectedDay,
                        onSelectDay: (day) {
                          setState(() => _selectedDay = day);
                        },
                      ),
                      const SizedBox(height: TwoGoSpacing.md),
                      if (visibleDay != null && tripDay != null)
                        _buildTimeline(visibleDay, tripDay)
                      else
                        Text(
                          'Nenhuma atividade neste dia.',
                          style: TwoGoTypography.bodyMedium.copyWith(
                            color: TwoGoColors.contentSecondary,
                          ),
                        ),
                      if (widget.controls != null && tripDay != null) ...[
                        const SizedBox(height: TwoGoSpacing.lg),
                        _DayEditActions(
                          onReorder: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Arraste as atividades pelo menu em breve. Use Substituir por agora.',
                                ),
                              ),
                            );
                          },
                          onInsert: () {
                            final items = [...tripDay.items]
                              ..sort((a, b) => a.order.compareTo(b.order));
                            InsertActivityPage.open(
                              context,
                              controls: widget.controls!,
                              dayId: tripDay.id,
                              nextOrder: items.isEmpty
                                  ? 1
                                  : items
                                          .map((i) => i.order)
                                          .reduce((a, b) => a > b ? a : b) +
                                      1,
                              destinationHint: widget.trip.destination,
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Center(
              child: _MapFab(
                onPressed: () => _openMapForDay(visibleDay),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(PlanningVisibleDay day, TripDayEntity tripDay) {
    final activities = [...day.activities]
      ..sort((a, b) => a.order.compareTo(b.order));
    final itemById = <String, ItineraryItemEntity>{
      for (final item in tripDay.items) item.id: item,
    };

    final stay = widget.trip.accommodation;
    final children = <Widget>[
      if (stay == null)
        PlanningLodgingTimelineItem(
          onTap: widget.controls == null
              ? null
              : _openAddOrEditAccommodation,
        )
      else
        _LodgingSummaryCard(
          stay: stay,
          onTap: () => _openLodgingDetails(
            stay: stay,
            kind: PlaceDetailsKind.hotel,
          ),
        ),
    ];

    for (var i = 0; i < activities.length; i++) {
      final activity = activities[i];
      final item = activity.sourceId == null
          ? null
          : itemById[activity.sourceId!];

      if (item != null) {
        final transit = TripItineraryView.transitLabel(
          meters: item.transitDistanceMeters,
          minutes: item.transitDurationMinutes,
          mode: item.transitMode,
        );
        if (transit != null && transit.isNotEmpty) {
          children.add(
            PlanningTransitLabel(label: 'Deslocamento: $transit'),
          );
        }
      } else if (i > 0) {
        final prev = activities[i - 1];
        if (!prev.isTransport && !activity.isTransport) {
          final computed =
              PlanningTimelineItem.transitBetween(prev, activity);
          if (computed != null) {
            children.add(PlanningTransitLabel(label: computed));
          }
        }
      }

      final isLast = i == activities.length - 1;
      Widget card = PlanningTimelineItem(
        activity: activity,
        isLast: isLast && activity.isTransport,
        nodeStyle: PlanningTimelineNodeStyle.solid,
        onOpenUrl: widget.onOpenUrl,
        onTap: activity.isTransport || item == null
            ? null
            : () => _openItemDetails(item),
        onRecommendationsTap: activity.isMeal && item != null
            ? () {
                final c = widget.controls;
                if (c == null) return;
                showMealRecommendationsSheet(
                  context,
                  controls: c,
                  dayId: item.tripDayId,
                  items: [item],
                  initialPeriod: item.period ?? item.title,
                );
              }
            : null,
        onMenuTap: item == null ? null : () => _openItemMenu(item),
      );

      if (item != null &&
          widget.controls != null &&
          !activity.isTransport &&
          !activity.isMeal) {
        card = _SwipeDeleteItem(
          itemId: item.id,
          onDelete: () => _deleteItem(item),
          child: card,
        );
      }

      children.add(card);
    }

    if (stay != null) {
      final place = [
        stay.address,
        stay.neighborhood,
        stay.zipCode,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
      final label = place.isNotEmpty
          ? place
          : ((stay.name?.trim().isNotEmpty ?? false)
              ? stay.name!.trim()
              : 'Retorno à hospedagem');
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: TwoGoSpacing.sm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('lodging-end-of-day'),
              onTap: () => _openLodgingDetails(
                stay: stay,
                kind: PlaceDetailsKind.endOfDay,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(TwoGoSpacing.md),
                decoration: BoxDecoration(
                  color: TwoGoColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 20,
                      color: TwoGoColors.contentSecondary,
                    ),
                    const SizedBox(width: TwoGoSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fim do dia',
                            style: TwoGoTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TwoGoSpacing.xxs),
                          Text(
                            label,
                            style: TwoGoTypography.bodySmall.copyWith(
                              color: TwoGoColors.contentSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: TwoGoColors.contentSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _PaidHeroHeader extends StatelessWidget {
  const _PaidHeroHeader({
    required this.destinationName,
    required this.onClose,
    required this.onSave,
    this.coverImage,
    this.coverImageFallback,
    this.coverImageUrl,
    this.coverImageProviderBuilder,
    this.onShare,
  });

  final ImageProvider? coverImage;
  final ImageProvider? coverImageFallback;
  final String? coverImageUrl;
  final String destinationName;
  final VoidCallback onClose;
  final VoidCallback onSave;
  final ImageProvider Function(String url)? coverImageProviderBuilder;
  final VoidCallback? onShare;

  ImageProvider? get _image {
    if (coverImage != null) return coverImage;
    final url = coverImageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return coverImageProviderBuilder?.call(url) ?? NetworkImage(url);
  }

  Widget _coverLayer(ImageProvider image, {ImageProvider? fallback}) {
    return Image(
      image: image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        if (fallback != null) {
          return Image(
            image: fallback,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackBg(),
          );
        }
        return _fallbackBg();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final image = _image;
    return SizedBox(
      height: 220 + topPad,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            _coverLayer(image, fallback: coverImageFallback)
          else if (coverImageFallback != null)
            _coverLayer(coverImageFallback!)
          else
            _fallbackBg(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0x99000000),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: topPad + TwoGoSpacing.xs,
            left: TwoGoSpacing.sm,
            right: TwoGoSpacing.sm,
            child: Row(
              children: [
                _RoundIconButton(
                  icon: Icons.close_rounded,
                  onPressed: onClose,
                ),
                const Spacer(),
                if (onShare != null) ...[
                  _RoundIconButton(
                    icon: Icons.ios_share_rounded,
                    onPressed: onShare,
                  ),
                  const SizedBox(width: TwoGoSpacing.xs),
                ],
                Material(
                  color: TwoGoColors.brandLime,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: onSave,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Text(
                        'Salvar',
                        style: TwoGoTypography.labelLarge.copyWith(
                          color: TwoGoColors.neutral900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: TwoGoSpacing.md,
            bottom: TwoGoSpacing.md,
            right: TwoGoSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Editar roteiro',
                  style: TwoGoTypography.labelMedium.copyWith(
                    color: TwoGoColors.contentInverse.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  destinationName,
                  style: TwoGoTypography.headlineLarge.copyWith(
                    color: TwoGoColors.contentInverse,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackBg() {
    return const ColoredBox(
      color: TwoGoColors.neutral800,
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          size: 64,
          color: TwoGoColors.neutral500,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwoGoColors.neutral0.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: TwoGoColors.neutral900),
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwoGoColors.neutral900,
      borderRadius: BorderRadius.circular(999),
      elevation: 6,
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 18,
                color: TwoGoColors.contentInverse,
              ),
              const SizedBox(width: 8),
              Text(
                'Mapa',
                style: TwoGoTypography.labelLarge.copyWith(
                  color: TwoGoColors.contentInverse,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LodgingSummaryCard extends StatelessWidget {
  const _LodgingSummaryCard({
    required this.stay,
    required this.onTap,
  });

  final TripAccommodation stay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = stay.name?.trim();
    final place = [
      stay.address,
      stay.neighborhood,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('lodging-hotel-card'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(TwoGoSpacing.md),
            decoration: BoxDecoration(
              color: TwoGoColors.neutral100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.apartment_outlined,
                  size: 22,
                  color: TwoGoColors.contentSecondary,
                ),
                const SizedBox(width: TwoGoSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name != null && name.isNotEmpty
                            ? name
                            : 'Hospedagem',
                        style: TwoGoTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (place.isNotEmpty) ...[
                        const SizedBox(height: TwoGoSpacing.xxs),
                        Text(
                          place,
                          style: TwoGoTypography.bodySmall.copyWith(
                            color: TwoGoColors.contentSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: TwoGoColors.contentSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayEditActions extends StatelessWidget {
  final VoidCallback onReorder;
  final VoidCallback onInsert;

  const _DayEditActions({
    required this.onReorder,
    required this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReorder,
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text('Reorganizar roteiro'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TwoGoColors.contentPrimary,
              side: const BorderSide(color: TwoGoColors.neutral300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onInsert,
            icon: const Icon(Icons.place_outlined, size: 18),
            label: const Text('Inserir nova atividade'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TwoGoColors.contentPrimary,
              side: const BorderSide(color: TwoGoColors.neutral300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Swipe left → trash (Excluir.pdf).
class _SwipeDeleteItem extends StatefulWidget {
  final Widget child;
  final String itemId;
  final Future<void> Function() onDelete;

  const _SwipeDeleteItem({
    required this.child,
    required this.itemId,
    required this.onDelete,
  });

  @override
  State<_SwipeDeleteItem> createState() => _SwipeDeleteItemState();
}

class _SwipeDeleteItemState extends State<_SwipeDeleteItem> {
  var _deletedLabel = false;
  var _busy = false;

  Future<void> _confirmAndDelete() async {
    if (_busy) return;
    setState(() {
      _deletedLabel = true;
      _busy = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    try {
      await widget.onDelete();
    } finally {
      if (mounted) {
        setState(() {
          _deletedLabel = false;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('paid-swipe-delete-${widget.itemId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _confirmAndDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE85A5A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _deletedLabel
            ? Text(
                'Excluído',
                style: TwoGoTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              )
            : const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: widget.child,
    );
  }
}
