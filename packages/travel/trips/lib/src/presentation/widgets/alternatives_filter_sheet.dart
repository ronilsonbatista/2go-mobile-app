import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/paid_trip_controls.dart';

/// Paid-trip "Filtrar por" sheet (design Filtros_7e2e).
Future<AlternativesFilter?> showAlternativesFilterSheet(
  BuildContext context, {
  required AlternativesFilter initial,
  required AlternativesFacets facets,
}) {
  return showModalBottomSheet<AlternativesFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: TwoGoColors.surfacePrimary,
    shape: const RoundedRectangleBorder(borderRadius: TwoGoRadius.sheetTop),
    builder: (context) {
      return _AlternativesFilterSheet(initial: initial, facets: facets);
    },
  );
}

class _AlternativesFilterSheet extends StatefulWidget {
  final AlternativesFilter initial;
  final AlternativesFacets facets;

  const _AlternativesFilterSheet({
    required this.initial,
    required this.facets,
  });

  @override
  State<_AlternativesFilterSheet> createState() =>
      _AlternativesFilterSheetState();
}

class _AlternativesFilterSheetState extends State<_AlternativesFilterSheet> {
  late String? _category;
  late String? _duration;
  late String? _location;
  late bool _free;
  late bool _paid;
  late bool _accessible;
  late bool _goodForRainyDays;
  late bool _goodForKids;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _category = initial.category;
    _duration = initial.duration;
    _location = initial.location;
    _free = initial.free;
    _paid = initial.paid;
    _accessible = initial.accessible;
    _goodForRainyDays = initial.goodForRainyDays;
    _goodForKids = initial.goodForKids;
  }

  AlternativesFilter get _current => AlternativesFilter(
        category: _category,
        duration: _duration,
        location: _location,
        free: _free,
        paid: _paid,
        accessible: _accessible,
        goodForRainyDays: _goodForRainyDays,
        goodForKids: _goodForKids,
        q: widget.initial.q,
      );

  void _clear() {
    setState(() {
      _category = null;
      _duration = null;
      _location = null;
      _free = false;
      _paid = false;
      _accessible = false;
      _goodForRainyDays = false;
      _goodForKids = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.92;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TwoGoSpacing.lg,
                TwoGoSpacing.md,
                TwoGoSpacing.sm,
                TwoGoSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filtrar por',
                      style: TwoGoTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('alternatives-filter-close'),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: TwoGoColors.neutral100,
                    ),
                    icon: const Icon(Icons.close, color: TwoGoColors.neutral900),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: TwoGoSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DropdownField(
                      label: 'Categoria',
                      value: _category,
                      options: widget.facets.categories,
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    const SizedBox(height: TwoGoSpacing.md),
                    _DropdownField(
                      label: 'Duração',
                      value: _duration,
                      options: widget.facets.durations,
                      onChanged: (value) => setState(() => _duration = value),
                    ),
                    const SizedBox(height: TwoGoSpacing.md),
                    _DropdownField(
                      label: 'Localização',
                      value: _location,
                      options: widget.facets.locations,
                      onChanged: (value) => setState(() => _location = value),
                    ),
                    const SizedBox(height: TwoGoSpacing.lg),
                    Text(
                      'Valor',
                      style: TwoGoTypography.labelMedium.copyWith(
                        color: TwoGoColors.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: TwoGoSpacing.sm),
                    Row(
                      children: [
                        TwoGoCheckbox(
                          key: const Key('filter-free'),
                          value: _free,
                          label: 'Grátis',
                          onChanged: (v) => setState(() => _free = v ?? false),
                        ),
                        const SizedBox(width: TwoGoSpacing.lg),
                        TwoGoCheckbox(
                          key: const Key('filter-paid'),
                          value: _paid,
                          label: 'Pago',
                          onChanged: (v) => setState(() => _paid = v ?? false),
                        ),
                      ],
                    ),
                    const SizedBox(height: TwoGoSpacing.lg),
                    Text(
                      'Características',
                      style: TwoGoTypography.labelMedium.copyWith(
                        color: TwoGoColors.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: TwoGoSpacing.sm),
                    TwoGoCheckbox(
                      key: const Key('filter-accessible'),
                      value: _accessible,
                      label: 'Acessível ♿',
                      onChanged: (v) =>
                          setState(() => _accessible = v ?? false),
                    ),
                    TwoGoCheckbox(
                      key: const Key('filter-rainy'),
                      value: _goodForRainyDays,
                      label: 'Ideal para dias de chuva ☔',
                      onChanged: (v) =>
                          setState(() => _goodForRainyDays = v ?? false),
                    ),
                    TwoGoCheckbox(
                      key: const Key('filter-kids'),
                      value: _goodForKids,
                      label: 'Bom para crianças 🧸',
                      onChanged: (v) =>
                          setState(() => _goodForKids = v ?? false),
                    ),
                    const SizedBox(height: TwoGoSpacing.xl),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: TwoGoColors.borderDefault),
            Padding(
              padding: EdgeInsets.fromLTRB(
                TwoGoSpacing.lg,
                TwoGoSpacing.md,
                TwoGoSpacing.lg,
                TwoGoSpacing.md + bottom,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const Key('filter-clear'),
                        onPressed: _clear,
                        child: Text(
                          'Limpar filtros',
                          style: TwoGoTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: TwoGoColors.contentPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TwoGoSpacing.sm),
                  SizedBox(
                    width: 128,
                    child: TwoGoButton(
                      key: const Key('filter-apply'),
                      text: 'Aplicar',
                      fullWidth: true,
                      onPressed: () => Navigator.pop(context, _current),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<AlternativesFacetOption> options;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedLabel = () {
      if (value == null || value!.isEmpty) return 'Todos';
      for (final option in options) {
        if (option.value == value) return option.label;
      }
      return value!;
    }();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TwoGoTypography.labelMedium.copyWith(
            color: TwoGoColors.contentSecondary,
          ),
        ),
        const SizedBox(height: TwoGoSpacing.xs),
        Material(
          color: TwoGoColors.surfaceSecondary,
          borderRadius: TwoGoRadius.borderMedium,
          child: InkWell(
            borderRadius: TwoGoRadius.borderMedium,
            onTap: () => _openPicker(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: TwoGoSpacing.md,
                vertical: TwoGoSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: TwoGoRadius.borderMedium,
                border: Border.all(color: TwoGoColors.borderDefault),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedLabel,
                      style: TwoGoTypography.bodyMedium.copyWith(
                        color: TwoGoColors.contentPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: TwoGoColors.contentSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final chosen = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: TwoGoColors.surfacePrimary,
      shape: const RoundedRectangleBorder(borderRadius: TwoGoRadius.sheetTop),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Todos'),
                trailing: value == null || value!.isEmpty
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, ''),
              ),
              for (final option in options)
                ListTile(
                  title: Text(option.label),
                  subtitle: option.count == null
                      ? null
                      : Text('${option.count}'),
                  trailing: value == option.value
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, option.value),
                ),
            ],
          ),
        );
      },
    );
    if (chosen == null) return;
    onChanged(chosen.isEmpty ? null : chosen);
  }
}
