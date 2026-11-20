import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/paid_trip_controls.dart';
import '../../domain/repositories/trips_repository.dart';
import '../substitute/substitute_attraction_page.dart';
import 'alternatives_filter_sheet.dart';

/// Ações da viagem paga. Sem este objeto a tela só mostra o que o GET já trouxe.
class TripControls {
  final TripsRepository repository;
  final Future<void> Function() reloadTrip;
  final SearchHotelsUseCase? searchHotels;
  final GetPlaceDetailsUseCase? getPlaceDetails;
  final SearchPlacesUseCase? searchPlaces;

  const TripControls({
    required this.repository,
    required this.reloadTrip,
    this.searchHotels,
    this.getPlaceDetails,
    this.searchPlaces,
  });

  bool get canSearchHotels =>
      searchHotels != null && getPlaceDetails != null;

  bool get canSearchPlaces => searchPlaces != null;
}

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final message = _messageFrom(error.response?.data);
    if (message != null) return message;
  }
  return 'Não foi possível concluir a ação.';
}

String? _messageFrom(dynamic data) {
  if (data is! Map) return null;
  final direct = data['message'];
  if (direct is String && direct.trim().isNotEmpty) return direct.trim();
  if (direct is List) {
    final parts = direct
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join('\n');
  }
  return _messageFrom(data['data']);
}

Future<void> showAccommodationSheet(
  BuildContext context, {
  required TripControls controls,
  required String tripId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _AccommodationSheet(controls: controls, tripId: tripId);
    },
  );
}

Future<void> confirmDeleteAccommodation(
  BuildContext context, {
  required TripControls controls,
  required String tripId,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Remover hospedagem'),
        content: const Text('A hospedagem deixa de aparecer neste roteiro.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar remoção'),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await controls.repository.deleteAccommodation(tripId);
    await controls.reloadTrip();
  } catch (error) {
    if (!context.mounted) return;
    await _showError(context, error);
  }
}

Future<void> showAlternativesSheet(
  BuildContext context, {
  required TripControls controls,
  required String itemId,
  String? destinationHint,
}) {
  return SubstituteAttractionPage.open(
    context,
    controls: controls,
    itemId: itemId,
    destinationHint: destinationHint,
  );
}

Future<void> showMealRecommendationsSheet(
  BuildContext context, {
  required TripControls controls,
  required String dayId,
  required List<ItineraryItemEntity> items,
  String? initialPeriod,
  ImageProvider Function(String url)? imageProviderBuilder,
}) {
  final mealItems = items
      .where(
        (item) =>
            item.category == ItineraryCategory.cafe ||
            item.category == ItineraryCategory.restaurant ||
            item.category == ItineraryCategory.bar,
      )
      .toList();
  final targets = mealItems.isNotEmpty ? mealItems : items;
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) {
        return MealRecommendationsPage(
          controls: controls,
          dayId: dayId,
          items: targets,
          initialPeriod: initialPeriod,
          imageProviderBuilder: imageProviderBuilder,
        );
      },
    ),
  );
}

Future<void> showDurationEditor(
  BuildContext context, {
  required TripControls controls,
  required String itemId,
  int? currentDuration,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return _DurationDialog(
        controls: controls,
        itemId: itemId,
        currentDuration: currentDuration,
      );
    },
  );
}

Future<void> showVerifiedDetails(
  BuildContext context, {
  required TripControls controls,
  required String itemId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _VerifiedDetailsSheet(controls: controls, itemId: itemId);
    },
  );
}

Future<void> _showError(BuildContext context, Object error) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(apiErrorMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      );
    },
  );
}

class _SheetFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.85;
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(TwoGoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TwoGoTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.md),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccommodationSheet extends StatefulWidget {
  final TripControls controls;
  final String tripId;

  const _AccommodationSheet({required this.controls, required this.tripId});

  @override
  State<_AccommodationSheet> createState() => _AccommodationSheetState();
}

class _AccommodationSheetState extends State<_AccommodationSheet> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _neighborhood = TextEditingController();
  final _zipCode = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _placeId = TextEditingController();
  final _checkInDateTime = TextEditingController();
  final _checkOutDateTime = TextEditingController();
  final _checkInDate = TextEditingController();
  final _checkInTime = TextEditingController();
  final _checkOutDate = TextEditingController();
  final _checkOutTime = TextEditingController();

  var _loading = true;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _controllers => [
    _name,
    _address,
    _neighborhood,
    _zipCode,
    _latitude,
    _longitude,
    _placeId,
    _checkInDateTime,
    _checkOutDateTime,
    _checkInDate,
    _checkInTime,
    _checkOutDate,
    _checkOutTime,
  ];

  Future<void> _load() async {
    try {
      final stay = await widget.controls.repository.getAccommodation(
        widget.tripId,
      );
      if (!mounted) return;
      _apply(stay);
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  void _apply(AccommodationDraft? stay) {
    _name.text = stay?.name ?? '';
    _address.text = stay?.address ?? '';
    _neighborhood.text = stay?.neighborhood ?? '';
    _zipCode.text = stay?.zipCode ?? '';
    _latitude.text = _coord(stay?.latitude);
    _longitude.text = _coord(stay?.longitude);
    _placeId.text = stay?.providerPlaceId ?? '';
    _checkInDateTime.text = stay?.checkInDateTime ?? '';
    _checkOutDateTime.text = stay?.checkOutDateTime ?? '';
    _checkInDate.text = stay?.checkInDate ?? '';
    _checkInTime.text = stay?.checkInTime ?? '';
    _checkOutDate.text = stay?.checkOutDate ?? '';
    _checkOutTime.text = stay?.checkOutTime ?? '';
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Informe o nome da hospedagem.');
      return;
    }
    final latitude = _coordField(_latitude.text);
    final longitude = _coordField(_longitude.text);
    if (latitude.invalid || longitude.invalid) {
      setState(() => _error = 'Latitude ou longitude inválida.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controls.repository.saveAccommodation(
        widget.tripId,
        AccommodationDraft(
          name: name,
          address: _blank(_address.text),
          neighborhood: _blank(_neighborhood.text),
          zipCode: _blank(_zipCode.text),
          latitude: latitude.value,
          longitude: longitude.value,
          providerPlaceId: _blank(_placeId.text),
          checkInDateTime: _blank(_checkInDateTime.text),
          checkOutDateTime: _blank(_checkOutDateTime.text),
          checkInDate: _blank(_checkInDate.text),
          checkInTime: _blank(_checkInTime.text),
          checkOutDate: _blank(_checkOutDate.text),
          checkOutTime: _blank(_checkOutTime.text),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Hospedagem',
      child: _loading
          ? const Text('Carregando')
          : Column(
              children: [
                if (_error != null) ...[
                  Text(_error!, style: TwoGoTypography.bodySmall),
                  const SizedBox(height: TwoGoSpacing.sm),
                ],
                Expanded(
                  child: ListView(
                    children: [
                      _field('accommodation-name', 'Nome', _name),
                      _field('accommodation-address', 'Endereço', _address),
                      _field(
                        'accommodation-neighborhood',
                        'Bairro',
                        _neighborhood,
                      ),
                      _field('accommodation-zip', 'CEP', _zipCode),
                      _field('accommodation-latitude', 'Latitude', _latitude),
                      _field(
                        'accommodation-longitude',
                        'Longitude',
                        _longitude,
                      ),
                      _field('accommodation-place', 'Place ID', _placeId),
                      _field(
                        'accommodation-check-in',
                        'Check-in',
                        _checkInDateTime,
                      ),
                      _field(
                        'accommodation-check-out',
                        'Check-out',
                        _checkOutDateTime,
                      ),
                      _field(
                        'accommodation-check-in-date',
                        'Data de check-in',
                        _checkInDate,
                      ),
                      _field(
                        'accommodation-check-in-time',
                        'Hora de check-in',
                        _checkInTime,
                      ),
                      _field(
                        'accommodation-check-out-date',
                        'Data de check-out',
                        _checkOutDate,
                      ),
                      _field(
                        'accommodation-check-out-time',
                        'Hora de check-out',
                        _checkOutTime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.md),
                TwoGoButton(
                  text: 'Salvar hospedagem',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }

  Widget _field(String key, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
      child: TwoGoTextField(
        key: Key(key),
        label: label,
        controller: controller,
      ),
    );
  }
}

class _AlternativesSheet extends StatefulWidget {
  final TripControls controls;
  final String itemId;

  const _AlternativesSheet({required this.controls, required this.itemId});

  @override
  State<_AlternativesSheet> createState() => _AlternativesSheetState();
}

class _AlternativesSheetState extends State<_AlternativesSheet> {
  AlternativesResult? _result;
  AlternativesFacets _facets = const AlternativesFacets();
  AlternativesFilter _filter = AlternativesFilter.empty;
  final _search = TextEditingController();
  var _loading = true;
  String? _error;
  String? _pendingTitle;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool keepFacets = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.controls.repository.getItemAlternatives(
        widget.itemId,
        filter: _filter,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        if (!keepFacets ||
            result.facets.categories.isNotEmpty ||
            result.facets.durations.isNotEmpty ||
            result.facets.locations.isNotEmpty) {
          _facets = result.facets;
        }
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  Future<void> _openFilters() async {
    final applied = await showAlternativesFilterSheet(
      context,
      initial: _filter,
      facets: _facets,
    );
    if (applied == null || !mounted) return;
    setState(() {
      _filter = applied.copyWith(q: _search.text.trim());
    });
    await _load(keepFacets: true);
  }

  Future<void> _applySearch(String value) async {
    setState(() {
      _filter = _filter.copyWith(q: value.trim(), clearQ: value.trim().isEmpty);
    });
    await _load(keepFacets: true);
  }

  Future<void> _substitute(ItemAlternative alternative) async {
    final body = alternative.toSubstituteBody();
    if (body == null || _result?.quota.canSubstitute != true) return;
    setState(() => _pendingTitle = alternative.title);
    try {
      await widget.controls.repository.substituteItem(widget.itemId, body);
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingTitle = null;
        _error = apiErrorMessage(error);
      });
    }
  }

  String? _availableLabel(SwapQuota quota) {
    final remaining = quota.remainingSwaps;
    final allowed = quota.allowedSwapsCount;
    if (remaining != null && allowed != null) {
      return 'Alterações disponíveis  $remaining de $allowed';
    }
    return quota.label;
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final height = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TwoGoSpacing.lg,
            TwoGoSpacing.md,
            TwoGoSpacing.lg,
            TwoGoSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Substituir por',
                      style: TwoGoTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: TwoGoColors.neutral100,
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: TwoGoColors.neutral900,
                    ),
                  ),
                ],
              ),
              if (result != null && _availableLabel(result.quota) != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
                  child: Text(
                    _availableLabel(result.quota)!,
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: TwoGoColors.contentSecondary,
                    ),
                  ),
                ),
              if (result != null && !result.quota.canSubstitute)
                Padding(
                  padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
                  child: Text(
                    result.quota.exhausted
                        ? 'Cota de trocas esgotada'
                        : 'Cota de trocas indisponível',
                  ),
                ),
              Text(
                'Atrações recomendadas',
                style: TwoGoTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TwoGoTextField(
                      key: const Key('alternatives-search'),
                      label: 'Ou busque por atividade',
                      controller: _search,
                      prefixIcon: Icons.search,
                      onSubmitted: _applySearch,
                    ),
                  ),
                  const SizedBox(width: TwoGoSpacing.sm),
                  TextButton(
                    key: const Key('alternatives-open-filter'),
                    onPressed: _loading ? null : _openFilters,
                    child: Text(
                      _filter.hasSheetFilters ? 'Filtrar ·' : 'Filtrar',
                      style: TwoGoTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TwoGoColors.contentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (_filter.hasSheetFilters ||
                  (_filter.q != null && _filter.q!.isNotEmpty))
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      _search.clear();
                      setState(() => _filter = AlternativesFilter.empty);
                      _load();
                    },
                    child: const Text('Limpar busca e filtros'),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: TwoGoSpacing.sm),
                Text(_error!),
              ],
              const SizedBox(height: TwoGoSpacing.sm),
              Expanded(
                child: _loading
                    ? const Center(child: Text('Carregando'))
                    : result == null
                    ? const SizedBox.shrink()
                    : result.items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: TwoGoSpacing.md),
                        child: Text('Nenhuma alternativa nesta resposta.'),
                      )
                    : ListView.separated(
                        itemCount: result.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: TwoGoSpacing.md),
                        itemBuilder: (context, index) {
                          final alternative = result.items[index];
                          final body = alternative.toSubstituteBody();
                          final enabled = result.quota.canSubstitute &&
                              body != null &&
                              _pendingTitle == null;
                          return _AlternativeCard(
                            alternative: alternative,
                            enabled: enabled,
                            pending: _pendingTitle == alternative.title,
                            onUse: () => _substitute(alternative),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  final ItemAlternative alternative;
  final bool enabled;
  final bool pending;
  final VoidCallback onUse;

  const _AlternativeCard({
    required this.alternative,
    required this.enabled,
    required this.pending,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final rating = alternative.rating;
    return Material(
      color: TwoGoColors.surfaceSecondary,
      borderRadius: TwoGoRadius.borderLarge,
      child: InkWell(
        borderRadius: TwoGoRadius.borderLarge,
        onTap: enabled ? onUse : null,
        child: Padding(
          padding: const EdgeInsets.all(TwoGoSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alternative.title ?? 'Sem título',
                style: TwoGoTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (rating != null) ...[
                const SizedBox(height: TwoGoSpacing.xxs),
                Text(
                  rating.toStringAsFixed(1),
                  style: TwoGoTypography.bodySmall.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              ],
              if (alternative.location != null) ...[
                const SizedBox(height: TwoGoSpacing.xxs),
                Text(
                  alternative.location!,
                  style: TwoGoTypography.bodySmall.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              ],
              if (pending)
                const Padding(
                  padding: EdgeInsets.only(top: TwoGoSpacing.xs),
                  child: Text('Substituindo…'),
                )
              else if (enabled)
                Padding(
                  padding: const EdgeInsets.only(top: TwoGoSpacing.xs),
                  child: Text(
                    'Usar esta',
                    style: TwoGoTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen meal recommendations (design: Recomendações — restaurante).
class MealRecommendationsPage extends StatefulWidget {
  final TripControls controls;
  final String dayId;
  final List<ItineraryItemEntity> items;
  final String? initialPeriod;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const MealRecommendationsPage({
    super.key,
    required this.controls,
    required this.dayId,
    required this.items,
    this.initialPeriod,
    this.imageProviderBuilder,
  });

  @override
  State<MealRecommendationsPage> createState() =>
      _MealRecommendationsPageState();
}

class _MealRecommendationsPageState extends State<MealRecommendationsPage> {
  MealRecommendationsResult? _result;
  var _loading = true;
  String? _error;
  late String _periodLabel;
  late String? _targetId;
  var _busy = false;
  String? _selectedPlaceId;

  static const _periodOptions = ['Café', 'Almoço', 'Jantar'];

  @override
  void initState() {
    super.initState();
    _periodLabel = _resolveInitialPeriod();
    _targetId = _pickTargetId(_periodLabel);
    final target = widget.items.cast<ItineraryItemEntity?>().firstWhere(
          (item) => item?.id == _targetId,
          orElse: () => widget.items.isEmpty ? null : widget.items.first,
        );
    _selectedPlaceId = target?.providerPlaceId;
    _load(_periodLabel);
  }

  String _resolveInitialPeriod() {
    final fromArg = widget.initialPeriod?.trim();
    if (fromArg != null && fromArg.isNotEmpty) {
      return _normalizePeriod(fromArg);
    }
    if (widget.items.length == 1) {
      return _normalizePeriod(
        widget.items.first.period ?? widget.items.first.title,
      );
    }
    return 'Jantar';
  }

  String _normalizePeriod(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('café') ||
        lower.contains('cafe') ||
        lower.contains('manhã') ||
        lower.contains('manha') ||
        lower.contains('breakfast')) {
      return 'Café';
    }
    if (lower.contains('jantar') ||
        lower.contains('dinner') ||
        lower.contains('noite')) {
      return 'Jantar';
    }
    return 'Almoço';
  }

  String? _pickTargetId(String period) {
    if (widget.items.isEmpty) return null;
    if (widget.items.length == 1) return widget.items.first.id;
    final match = widget.items.where((item) {
      final blob = '${item.period ?? ''} ${item.title}'.toLowerCase();
      switch (period) {
        case 'Café':
          return blob.contains('café') ||
              blob.contains('cafe') ||
              blob.contains('manhã') ||
              blob.contains('manha');
        case 'Jantar':
          return blob.contains('jantar') || blob.contains('noite');
        default:
          return blob.contains('almoço') || blob.contains('almoco');
      }
    });
    return (match.isNotEmpty ? match.first : widget.items.first).id;
  }

  Future<void> _load(String period) async {
    setState(() {
      _loading = true;
      _error = null;
      _periodLabel = period;
      _targetId = _pickTargetId(period);
    });
    try {
      final result = await widget.controls.repository.getMealRecommendations(
        widget.dayId,
        period: period,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  Future<void> _select(MealRecommendation meal) async {
    final body = meal.toPinBody();
    final targetId = _targetId;
    if (body == null || targetId == null) return;
    setState(() => _busy = true);
    try {
      await widget.controls.repository.pinMeal(targetId, body);
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  Future<void> _unselect() async {
    final targetId = _targetId;
    if (targetId == null) return;
    setState(() => _busy = true);
    try {
      await widget.controls.repository.unpinMeal(targetId);
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final asset = MealTypeAssets.resolve(title: _periodLabel);
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: TwoGoColors.backgroundSecondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _periodLabel,
          style: TwoGoTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Map surface deferred — list remains primary select path.
        },
        backgroundColor: TwoGoColors.neutral900,
        foregroundColor: TwoGoColors.neutral0,
        icon: const Icon(Icons.map_outlined, size: 18),
        label: const Text('Mapa'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TwoGoSpacing.lg,
              TwoGoSpacing.sm,
              TwoGoSpacing.lg,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recomendações',
                    style: TwoGoTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final next = await showModalBottomSheet<String>(
                      context: context,
                      builder: (ctx) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final period in _periodOptions)
                                ListTile(
                                  title: Text(period),
                                  trailing: period == _periodLabel
                                      ? const Icon(Icons.check)
                                      : null,
                                  onTap: () => Navigator.pop(ctx, period),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                    if (next != null && next != _periodLabel) {
                      await _load(next);
                    }
                  },
                  child: const Text('Filtrar'),
                ),
              ],
            ),
          ),
          if (_selectedPlaceId != null && !_busy)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
              child: TextButton(
                onPressed: _unselect,
                child: const Text('Remover seleção atual'),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      TwoGoSpacing.lg,
                      TwoGoSpacing.sm,
                      TwoGoSpacing.lg,
                      96,
                    ),
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: TwoGoSpacing.md),
                          child: Text(
                            _error!,
                            style: TwoGoTypography.bodySmall.copyWith(
                              color: TwoGoColors.feedbackError,
                            ),
                          ),
                        ),
                      if (result == null || result.recommendations.isEmpty)
                        const Text('Nenhuma sugestão nesta resposta.')
                      else
                        for (final meal in result.recommendations)
                          _RecommendationCard(
                            meal: meal,
                            asset: asset,
                            selected:
                                meal.providerPlaceId != null &&
                                meal.providerPlaceId == _selectedPlaceId,
                            busy: _busy,
                            imageProviderBuilder: widget.imageProviderBuilder,
                            onSelect: () => _select(meal),
                            onOpenMaps: meal.googleMapsUri == null
                                ? null
                                : () {
                                    // URL open handled by host when needed.
                                  },
                          ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.meal,
    required this.asset,
    required this.selected,
    required this.busy,
    required this.onSelect,
    this.onOpenMaps,
    this.imageProviderBuilder,
  });

  final MealRecommendation meal;
  final MealTypeAsset asset;
  final bool selected;
  final bool busy;
  final VoidCallback onSelect;
  final VoidCallback? onOpenMaps;
  final ImageProvider Function(String url)? imageProviderBuilder;

  @override
  Widget build(BuildContext context) {
    final name = meal.name?.trim() ?? '';
    final price = meal.priceRange?.trim();
    final cuisine = meal.cuisineType?.trim();
    final hours = meal.openingHours?.trim();
    final image = meal.imageUrl?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
      child: Material(
        color: TwoGoColors.neutral0,
        borderRadius: BorderRadius.circular(TwoGoRadius.medium),
        child: InkWell(
          onTap: busy || name.isEmpty ? null : onSelect,
          borderRadius: BorderRadius.circular(TwoGoRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(TwoGoSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(TwoGoRadius.small),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: image != null && image.isNotEmpty
                        ? Image(
                            image: imageProviderBuilder?.call(image) ??
                                NetworkImage(image),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              MealTypeAssets.pathFor(asset),
                              package: MealTypeAssets.package,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            MealTypeAssets.pathFor(asset),
                            package: MealTypeAssets.package,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: TwoGoSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TwoGoTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (onOpenMaps != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: onOpenMaps,
                              icon: const Icon(
                                Icons.north_east_rounded,
                                size: 18,
                              ),
                            ),
                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: TwoGoColors.success,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (meal.rating != null) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF5C518),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              meal.rating!.toStringAsFixed(1),
                              style: TwoGoTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: TwoGoSpacing.sm),
                          ],
                          if (price != null && price.isNotEmpty)
                            Text(
                              price,
                              style: TwoGoTypography.labelSmall.copyWith(
                                color: TwoGoColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      if (cuisine != null && cuisine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.restaurant_outlined,
                              size: 14,
                              color: TwoGoColors.contentSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cuisine,
                                style: TwoGoTypography.labelSmall.copyWith(
                                  color: TwoGoColors.contentSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (hours != null && hours.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: TwoGoColors.feedbackError,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hours,
                                style: TwoGoTypography.labelSmall.copyWith(
                                  color: TwoGoColors.contentSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationDialog extends StatefulWidget {
  final TripControls controls;
  final String itemId;
  final int? currentDuration;

  const _DurationDialog({
    required this.controls,
    required this.itemId,
    required this.currentDuration,
  });

  @override
  State<_DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<_DurationDialog> {
  late final TextEditingController _minutes = TextEditingController(
    text: widget.currentDuration?.toString() ?? '',
  );
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final minutes = int.tryParse(_minutes.text.trim());
    if (minutes == null || minutes < 0) {
      setState(() => _error = 'Informe a duração em minutos.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controls.repository.updateItemDuration(
        widget.itemId,
        minutes,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duração'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('item-duration'),
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutos'),
          ),
          if (_error != null) ...[
            const SizedBox(height: TwoGoSpacing.sm),
            Text(_error!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: const Text('Salvar duração'),
        ),
      ],
    );
  }
}

class _VerifiedDetailsSheet extends StatefulWidget {
  final TripControls controls;
  final String itemId;

  const _VerifiedDetailsSheet({required this.controls, required this.itemId});

  @override
  State<_VerifiedDetailsSheet> createState() => _VerifiedDetailsSheetState();
}

class _VerifiedDetailsSheetState extends State<_VerifiedDetailsSheet> {
  VerifiedPlaceDetails? _details;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final details = await widget.controls.repository.getVerifiedDetails(
        widget.itemId,
      );
      if (!mounted) return;
      setState(() {
        _details = details;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    final lines = <Widget>[];
    if (details != null && details.hasAny) {
      void add(String? text) {
        if (text == null || text.isEmpty) return;
        lines.add(Text(text, style: TwoGoTypography.bodySmall));
      }

      add(details.name == null ? null : 'Nome: ${details.name}');
      add(
        details.formattedAddress == null
            ? null
            : 'Endereço: ${details.formattedAddress}',
      );
      add(details.rating == null ? null : 'Avaliação: ${details.rating}');
      add(
        details.userRatingsTotal == null
            ? null
            : 'Avaliações: ${details.userRatingsTotal}',
      );
      add(details.internationalPhoneNumber);
      add(
        details.priceLevel == null
            ? null
            : 'Nível de preço: ${details.priceLevel}',
      );
      add(details.types?.join(', '));
      if (details.googleMapsUri != null) {
        lines.add(SelectableText(details.googleMapsUri!));
      }
      if (details.websiteUri != null) {
        lines.add(SelectableText(details.websiteUri!));
      }
    }

    return _SheetFrame(
      title: 'Detalhes verificados',
      child: _loading
          ? const Text('Carregando')
          : ListView(
              children: [
                if (_error != null) Text(_error!),
                if (_error == null && lines.isEmpty)
                  const Text('Sem detalhes verificados'),
                ...lines,
              ],
            ),
    );
  }
}

String _coord(double? value) => value == null ? '' : value.toString();

String? _blank(String raw) {
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

({double? value, bool invalid}) _coordField(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return (value: null, invalid: false);
  final parsed = double.tryParse(text.replaceAll(',', '.'));
  if (parsed == null) return (value: null, invalid: true);
  return (value: parsed, invalid: false);
}
