import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_activity_window.dart';
import '../../../domain/models/planning_budget_option.dart';
import '../../../domain/models/planning_destination.dart';
import '../../../domain/models/planning_interest.dart';
import '../../../domain/models/planning_travelers.dart';
import '../form_course_tokens.dart';
import 'form_course_icons.dart';
import 'place_thumb.dart';

/// Course Revisao 6/6 — layout aligned to design PDF/ref (a050f580).
///
/// Spacing / radius notes vs prior sim (799f3fba):
/// - Card radius 12 (was 16) to match course grey cards
/// - Label→card gap 8; section gutter 16; side-by-side card gutter 12
/// - Viajantes / Estilo equal-height stretched cards
/// - Destino thumb via [PlaceThumb] (photo or Core SVG pin — never [?])
/// - Interests rows: 12px vertical padding
class ReviewStepContent extends StatelessWidget {
  final List<PlanningDestination> destinations;
  final PlanningTravelers travelers;
  final List<PlanningInterest> interests;
  /// Kept for wizard wiring; course Revisao screenshots omit horário row.
  final PlanningActivityWindow activityWindow;
  final String? budgetLevel;
  final ValueChanged<int> onEditSection;

  const ReviewStepContent({
    super.key,
    required this.destinations,
    required this.travelers,
    required this.interests,
    required this.activityWindow,
    required this.budgetLevel,
    required this.onEditSection,
  });

  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  String _emoji(PlanningInterest interest) {
    switch (interest) {
      case PlanningInterest.art:
        return '🖼️';
      case PlanningInterest.gastronomy:
        return '🍲';
      case PlanningInterest.sports:
        return '⚽';
      case PlanningInterest.architecture:
        return '🏯';
      case PlanningInterest.outdoor:
        return '🚴';
      case PlanningInterest.music:
        return '🎸';
      case PlanningInterest.geekCulture:
        return '👾';
      case PlanningInterest.localHistory:
        return '🏺';
      case PlanningInterest.nature:
        return '🌳';
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day} de ${_months[dt.month - 1]}';
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '';
    final parts = time.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? parts[1] : '00';
    return m == '00' ? '$h:00' : '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final budget = PlanningBudgetOption.fromRaw(budgetLevel);
    final showEditHint = destinations.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FormCourseTokens.pageGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            destinations.length > 1 ? 'Destinos' : 'Destino',
          ),
          const SizedBox(height: FormCourseTokens.labelToCardGap),
          _SummaryCard(
            onTap: () => onEditSection(1),
            child: Column(
              children: [
                for (var i = 0; i < destinations.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: FormCourseTokens.background,
                    ),
                  _DestinationSummary(
                    destination: destinations[i],
                    formatDate: _formatDate,
                    formatTime: _formatTime,
                    showEditHint: showEditHint && i == 0,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: FormCourseTokens.sectionGap),
          // Labels row + equal-height cards (design: Viajantes | Estilo).
          Row(
            children: [
              Expanded(
                child: _SectionLabel('Viajantes'),
              ),
              const SizedBox(width: FormCourseTokens.cardGutter),
              Expanded(
                child: _SectionLabel('Estilo de viagem'),
              ),
            ],
          ),
          const SizedBox(height: FormCourseTokens.labelToCardGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SummaryCard(
                    onTap: () => onEditSection(2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (travelers.adults > 0)
                          Text(
                            '${travelers.adults} adulto${travelers.adults == 1 ? '' : 's'}',
                            style: TwoGoTypography.titleMedium.copyWith(
                              color: FormCourseTokens.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (travelers.children > 0) ...[
                          const SizedBox(height: TwoGoSpacing.xxs),
                          Text(
                            '${travelers.children} criança${travelers.children == 1 ? '' : 's'}',
                            style: TwoGoTypography.titleMedium.copyWith(
                              color: FormCourseTokens.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (travelers.elders > 0) ...[
                          const SizedBox(height: TwoGoSpacing.xxs),
                          Text(
                            '${travelers.elders} idoso${travelers.elders == 1 ? '' : 's'}',
                            style: TwoGoTypography.titleMedium.copyWith(
                              color: FormCourseTokens.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: FormCourseTokens.cardGutter),
                Expanded(
                  child: _SummaryCard(
                    onTap: () => onEditSection(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (budget != null) ...[
                          FormEstiloDollarGlyph(count: budget.symbol.length),
                          const SizedBox(height: TwoGoSpacing.xxs),
                          Text(
                            budget.label,
                            style: TwoGoTypography.bodyMedium.copyWith(
                              color: FormCourseTokens.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else
                          Text(
                            '—',
                            style: TwoGoTypography.bodyMedium.copyWith(
                              color: FormCourseTokens.label,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FormCourseTokens.sectionGap),
          const _SectionLabel('Principais interesses'),
          const SizedBox(height: FormCourseTokens.labelToCardGap),
          _SummaryCard(
            onTap: () => onEditSection(3),
            child: Column(
              children: [
                for (var i = 0; i < interests.length; i++) ...[
                  if (i > 0)
                    const SizedBox(height: FormCourseTokens.interestRowGap),
                  Row(
                    children: [
                      Text(
                        _emoji(interests[i]),
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: TwoGoSpacing.md),
                      Expanded(
                        child: Text(
                          interests[i].label,
                          style: TwoGoTypography.titleMedium.copyWith(
                            color: FormCourseTokens.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (interests.isEmpty)
                  Text(
                    'Nenhum interesse selecionado',
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: FormCourseTokens.label,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TwoGoTypography.labelMedium.copyWith(
        color: FormCourseTokens.label,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FormCourseTokens.summaryCard,
      borderRadius: BorderRadius.circular(FormCourseTokens.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FormCourseTokens.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(FormCourseTokens.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

class _DestinationSummary extends StatelessWidget {
  const _DestinationSummary({
    required this.destination,
    required this.formatDate,
    required this.formatTime,
    required this.showEditHint,
  });

  final PlanningDestination destination;
  final String Function(String) formatDate;
  final String Function(String) formatTime;
  final bool showEditHint;

  @override
  Widget build(BuildContext context) {
    final country = destination.country?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo when Core/Home supplied a raster URL; SVG pin otherwise.
            // Never show broken Material tofu as the Destino thumb.
            PlaceThumb(
              iconUrl: destination.coverImage,
              size: FormCourseTokens.destinoThumbSize,
              borderRadius: FormCourseTokens.thumbRadius,
            ),
            const SizedBox(width: TwoGoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name.isEmpty ? 'Destino' : destination.name,
                    style: TwoGoTypography.titleLarge.copyWith(
                      color: FormCourseTokens.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (country != null && country.isNotEmpty)
                    Text(
                      country,
                      style: TwoGoTypography.bodyMedium.copyWith(
                        color: FormCourseTokens.label,
                      ),
                    ),
                  if (showEditHint) ...[
                    const SizedBox(height: TwoGoSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TwoGoSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FormCourseTokens.ink,
                        borderRadius:
                            BorderRadius.circular(TwoGoRadius.full),
                      ),
                      child: Text(
                        '💡 Toque para editar',
                        style: TwoGoTypography.labelSmall.copyWith(
                          color: FormCourseTokens.surface,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        const Divider(
          height: 1,
          thickness: 1,
          color: FormCourseTokens.background,
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chegada',
                    style: TwoGoTypography.labelMedium.copyWith(
                      color: FormCourseTokens.label,
                    ),
                  ),
                  Text(
                    formatDate(destination.arrivalDate),
                    style: TwoGoTypography.titleMedium.copyWith(
                      color: FormCourseTokens.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    formatTime(destination.arrivalTime),
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: FormCourseTokens.label,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partida',
                    style: TwoGoTypography.labelMedium.copyWith(
                      color: FormCourseTokens.label,
                    ),
                  ),
                  Text(
                    formatDate(destination.departureDate),
                    style: TwoGoTypography.titleMedium.copyWith(
                      color: FormCourseTokens.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    formatTime(destination.departureTime),
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: FormCourseTokens.label,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
