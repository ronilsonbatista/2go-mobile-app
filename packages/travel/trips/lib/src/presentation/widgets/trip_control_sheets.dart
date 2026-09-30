import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/paid_trip_controls.dart';
import '../../domain/repositories/trips_repository.dart';

/// Ações da viagem paga. Sem este objeto a tela só mostra o que o GET já trouxe.
class TripControls {
  final TripsRepository repository;
  final Future<void> Function() reloadTrip;

  const TripControls({required this.repository, required this.reloadTrip});
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
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _AlternativesSheet(controls: controls, itemId: itemId);
    },
  );
}

Future<void> showMealRecommendationsSheet(
  BuildContext context, {
  required TripControls controls,
  required String dayId,
  required List<ItineraryItemEntity> items,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _MealSheet(controls: controls, dayId: dayId, items: items);
    },
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
  var _loading = true;
  String? _error;
  String? _pendingTitle;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await widget.controls.repository.getItemAlternatives(
        widget.itemId,
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

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return _SheetFrame(
      title: 'Alternativas',
      child: _loading
          ? const Text('Carregando')
          : ListView(
              children: [
                if (result != null && result.quota.label != null)
                  Text(
                    result.quota.label!,
                    style: TwoGoTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (result != null && !result.quota.canSubstitute)
                  Padding(
                    padding: const EdgeInsets.only(top: TwoGoSpacing.xs),
                    child: Text(
                      result.quota.exhausted
                          ? 'Cota de trocas esgotada'
                          : 'Cota de trocas indisponível',
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: TwoGoSpacing.sm),
                  Text(_error!),
                ],
                if (result != null && result.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: TwoGoSpacing.md),
                    child: Text('Nenhuma alternativa nesta resposta.'),
                  ),
                if (result != null)
                  ...result.items.map((alternative) {
                    final body = alternative.toSubstituteBody();
                    final enabled =
                        result.quota.canSubstitute &&
                        body != null &&
                        _pendingTitle == null;
                    return Padding(
                      padding: const EdgeInsets.only(top: TwoGoSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._alternativeLines(alternative),
                          if (enabled)
                            TextButton(
                              onPressed: () => _substitute(alternative),
                              child: const Text('Usar esta'),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

class _MealSheet extends StatefulWidget {
  final TripControls controls;
  final String dayId;
  final List<ItineraryItemEntity> items;

  const _MealSheet({
    required this.controls,
    required this.dayId,
    required this.items,
  });

  @override
  State<_MealSheet> createState() => _MealSheetState();
}

class _MealSheetState extends State<_MealSheet> {
  MealRecommendationsResult? _result;
  var _loading = true;
  String? _error;
  String? _period;
  late String? _targetId;
  var _pinning = false;

  @override
  void initState() {
    super.initState();
    _targetId = widget.items.length == 1 ? widget.items.first.id : null;
    _load(null, initial: true);
  }

  List<String> get _periods {
    final periods = <String>[];
    for (final item in widget.items) {
      final period = item.period?.trim();
      if (period == null || period.isEmpty || periods.contains(period)) {
        continue;
      }
      periods.add(period);
    }
    return periods;
  }

  Future<void> _load(String? period, {bool initial = false}) async {
    if (initial) {
      _period = period;
    } else {
      setState(() {
        _loading = true;
        _error = null;
        _period = period;
      });
    }
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

  Future<void> _pin(MealRecommendation meal) async {
    final body = meal.toPinBody();
    final targetId = _targetId;
    if (body == null || targetId == null) return;
    setState(() => _pinning = true);
    try {
      await widget.controls.repository.pinMeal(targetId, body);
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pinning = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return _SheetFrame(
      title: 'Sugestões de refeição',
      child: ListView(
        children: [
          if (_periods.isNotEmpty)
            Wrap(
              spacing: TwoGoSpacing.xs,
              children: [
                for (final period in _periods)
                  FilterChip(
                    label: Text(period),
                    selected: _period == period,
                    onSelected: (selected) {
                      _load(selected ? period : null);
                    },
                  ),
              ],
            ),
          if (widget.items.length > 1) ...[
            const SizedBox(height: TwoGoSpacing.sm),
            const Text('Fixar no item'),
            RadioGroup<String>(
              groupValue: _targetId,
              onChanged: (value) => setState(() => _targetId = value),
              child: Column(
                children: [
                  for (final item in widget.items)
                    RadioListTile<String>(
                      value: item.id,
                      title: Text(item.title),
                    ),
                ],
              ),
            ),
          ],
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: TwoGoSpacing.md),
              child: Text('Carregando'),
            )
          else if (result != null) ...[
            if (result.destination != null) Text(result.destination!),
            if (result.period != null) Text(result.period!),
            if (result.recommendations.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: TwoGoSpacing.md),
                child: Text('Nenhuma sugestão nesta resposta.'),
              ),
            for (final meal in result.recommendations)
              Padding(
                padding: const EdgeInsets.only(top: TwoGoSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._mealLines(meal),
                    if (meal.toPinBody() != null &&
                        _targetId != null &&
                        !_pinning)
                      TextButton(
                        onPressed: () => _pin(meal),
                        child: const Text('Fixar'),
                      ),
                  ],
                ),
              ),
          ],
          if (_error != null) ...[
            const SizedBox(height: TwoGoSpacing.sm),
            Text(_error!),
          ],
        ],
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

List<Widget> _alternativeLines(ItemAlternative alternative) {
  final lines = <Widget>[];
  void add(String? text) {
    if (text == null || text.isEmpty) return;
    lines.add(Text(text));
  }

  add(alternative.title);
  add(alternative.description);
  add(alternative.category);
  add(alternative.location);
  if (alternative.cost != null && alternative.currency != null) {
    add('${alternative.currency} ${alternative.cost}');
  }
  add(alternative.duration == null ? null : '${alternative.duration} min');
  add(_ticketStatusLabel(alternative.ticketStatus));
  add(alternative.rating == null ? null : 'Avaliação: ${alternative.rating}');
  add(alternative.source);
  if (alternative.googleMapsUri != null) {
    lines.add(SelectableText(alternative.googleMapsUri!));
  }
  return lines;
}

List<Widget> _mealLines(MealRecommendation meal) {
  final lines = <Widget>[];
  void add(String? text) {
    if (text == null || text.isEmpty) return;
    lines.add(Text(text));
  }

  add(meal.name);
  add(meal.cuisineType);
  add(meal.priceRange);
  add(meal.priceLevel == null ? null : 'Nível de preço: ${meal.priceLevel}');
  add(meal.recommendedDish);
  add(meal.address);
  add(meal.description);
  add(meal.rating == null ? null : 'Avaliação: ${meal.rating}');
  add(
    meal.userRatingsTotal == null
        ? null
        : 'Avaliações: ${meal.userRatingsTotal}',
  );
  add(meal.source);
  if (meal.googleMapsUri != null) {
    lines.add(SelectableText(meal.googleMapsUri!));
  }
  return lines;
}

String? _ticketStatusLabel(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  switch (value.toUpperCase()) {
    case 'FREE':
      return 'Gratuito';
    case 'TICKET_REQUIRED':
      return 'Ingresso necessário';
    case 'UNKNOWN':
      return 'Ingresso não informado';
    default:
      return value;
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
