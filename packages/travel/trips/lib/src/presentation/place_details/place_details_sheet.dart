import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/place_details_view_data.dart';
import '../widgets/trip_control_sheets.dart';
import 'place_details_page.dart';
import 'place_details_tokens.dart';
import 'widgets/place_duration_stepper.dart';

/// Bottom-sheet Detalhes for meal slots (Modal) and placed items (Modal-2).
class PlaceDetailsSheet extends StatefulWidget {
  final PlaceDetailsViewData data;
  final ValueChanged<Uri>? onOpenUrl;
  final Future<void> Function(int minutes)? onSaveDuration;
  final VoidCallback? onShowSuggestions;
  final VoidCallback? onShowDetails;
  final VoidCallback? onSubstitute;
  final VoidCallback? onDelete;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const PlaceDetailsSheet({
    super.key,
    required this.data,
    this.onOpenUrl,
    this.onSaveDuration,
    this.onShowSuggestions,
    this.onShowDetails,
    this.onSubstitute,
    this.onDelete,
    this.imageProviderBuilder,
  });

  static Future<void> show(
    BuildContext context, {
    required PlaceDetailsViewData data,
    ValueChanged<Uri>? onOpenUrl,
    Future<void> Function(int minutes)? onSaveDuration,
    VoidCallback? onShowSuggestions,
    VoidCallback? onShowDetails,
    VoidCallback? onSubstitute,
    VoidCallback? onDelete,
    ImageProvider Function(String url)? imageProviderBuilder,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: PlaceDetailsTokens.sheetScrim,
      builder: (ctx) {
        return PlaceDetailsSheet(
          data: data,
          onOpenUrl: onOpenUrl,
          onSaveDuration: onSaveDuration,
          onShowSuggestions: onShowSuggestions,
          onShowDetails: onShowDetails,
          onSubstitute: onSubstitute,
          onDelete: onDelete,
          imageProviderBuilder: imageProviderBuilder,
        );
      },
    );
  }

  @override
  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<PlaceDetailsSheet> {
  late int _duration;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _duration = widget.data.durationMinutes ??
        (widget.data.isMealSlot ? 90 : 50);
  }

  Future<void> _changeDuration(int minutes) async {
    setState(() {
      _duration = minutes;
      _saving = true;
    });
    try {
      await widget.onSaveDuration?.call(minutes);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final meal = data.isMealSlot;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalhes',
                    style: TwoGoTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PlaceDetailsTokens.ink,
                    ),
                  ),
                ),
                Material(
                  color: PlaceDetailsTokens.chipSurface,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(Icons.close, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetSummaryCard(
              data: data,
              imageProviderBuilder: widget.imageProviderBuilder,
            ),
            const SizedBox(height: 16),
            PlaceDurationStepper(
              minutes: _duration,
              recommendedMinutes: data.recommendedDurationMinutes ?? _duration,
              onChanged: _saving ? null : _changeDuration,
            ),
            const SizedBox(height: 20),
            TwoGoButton(
              text: meal ? 'Mostrar sugestões' : 'Mostrar detalhes',
              onPressed: meal
                  ? widget.onShowSuggestions
                  : () {
                      Navigator.of(context).maybePop();
                      widget.onShowDetails?.call();
                    },
              fullWidth: true,
            ),
            if (!meal) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton(
                      onPressed: widget.onSubstitute,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PlaceDetailsTokens.ink,
                        side: const BorderSide(color: PlaceDetailsTokens.ink),
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        data.substituteCtaLabel,
                        style: TwoGoTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: widget.onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PlaceDetailsTokens.deleteInk,
                        backgroundColor: PlaceDetailsTokens.deleteFill,
                        side: const BorderSide(
                          color: PlaceDetailsTokens.deleteBorder,
                        ),
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'Excluir',
                        style: TwoGoTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PlaceDetailsTokens.deleteInk,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetSummaryCard extends StatelessWidget {
  final PlaceDetailsViewData data;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const _SheetSummaryCard({
    required this.data,
    this.imageProviderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final meal = data.isMealSlot;
    final thumb = data.imageUrl ??
        (data.photoUrls.isNotEmpty ? data.photoUrls.first : null);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlaceDetailsTokens.cardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: meal || thumb == null
                  ? Container(
                      color: PlaceDetailsTokens.chipSurface,
                      alignment: Alignment.center,
                      child: Icon(
                        _mealIcon(data),
                        color: PlaceDetailsTokens.muted,
                      ),
                    )
                  : Image(
                      image: imageProviderBuilder != null
                          ? imageProviderBuilder!(thumb)
                          : NetworkImage(thumb),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: PlaceDetailsTokens.chipSurface,
                        alignment: Alignment.center,
                        child: const Icon(Icons.place_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: meal
                ? Text(
                    data.displayName,
                    style: TwoGoTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.timeLabel != null &&
                          data.timeLabel!.trim().isNotEmpty)
                        Text(
                          data.timeLabel!,
                          style: TwoGoTypography.bodySmall.copyWith(
                            color: PlaceDetailsTokens.muted,
                          ),
                        ),
                      Text(
                        data.displayName,
                        style: TwoGoTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (data.rating != null) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: PlaceDetailsTokens.star,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data.rating!.toStringAsFixed(1),
                              style: TwoGoTypography.labelLarge,
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (data.priceLevelDisplay != null)
                            Text(
                              data.priceLevelDisplay!,
                              style: TwoGoTypography.labelLarge.copyWith(
                                color: PlaceDetailsTokens.priceBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  IconData _mealIcon(PlaceDetailsViewData data) {
    final title = data.displayName.toLowerCase();
    if (title.contains('café') || title.contains('cafe') || title.contains('manhã')) {
      return Icons.local_cafe_outlined;
    }
    if (title.contains('jantar')) return Icons.nightlife_outlined;
    return Icons.restaurant_outlined;
  }
}

/// Opens meal-slot or placed-item sheet; full page from "Mostrar detalhes".
Future<void> showPlaceDetailsFlow(
  BuildContext context, {
  required ItineraryItemEntity item,
  required TripControls controls,
  ValueChanged<Uri>? onOpenUrl,
  ImageProvider Function(String url)? imageProviderBuilder,
}) async {
  final verified = await controls.repository.getVerifiedDetails(item.id);
  if (!context.mounted) return;

  final data = PlaceDetailsViewData.merge(
    item: item,
    verified: verified,
    mode: PlaceDetailsMode.edit,
  );

  Future<void> saveDuration(int minutes) async {
    await controls.repository.updateItemDuration(item.id, minutes);
    await controls.reloadTrip();
  }

  Future<void> openFull() async {
    if (!context.mounted) return;
    final fresh = PlaceDetailsViewData.merge(
      item: item,
      verified: verified,
      mode: PlaceDetailsMode.edit,
    );
    await PlaceDetailsPage.open<void>(
      context,
      data: fresh,
      onOpenUrl: onOpenUrl,
      onSaveDuration: saveDuration,
      imageProviderBuilder: imageProviderBuilder,
      onSubstitute: () async {
        await Navigator.of(context).maybePop();
        if (!context.mounted) return;
        await showAlternativesSheet(
          context,
          controls: controls,
          itemId: item.id,
        );
      },
      onDelete: () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir atividade'),
            content: const Text(
              'Remover este ponto do roteiro? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
        if (ok != true || !context.mounted) return;
        try {
          await controls.repository.deleteItineraryItem(item.id);
          await controls.reloadTrip();
          if (context.mounted) await Navigator.of(context).maybePop();
        } catch (error) {
          if (!context.mounted) return;
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
      },
    );
  }

  await PlaceDetailsSheet.show(
    context,
    data: data,
    onOpenUrl: onOpenUrl,
    onSaveDuration: saveDuration,
    imageProviderBuilder: imageProviderBuilder,
    onShowSuggestions: () async {
      await Navigator.of(context).maybePop();
      if (!context.mounted) return;
      await showMealRecommendationsSheet(
        context,
        controls: controls,
        dayId: item.tripDayId,
        items: [item],
      );
    },
    onShowDetails: openFull,
    onSubstitute: () async {
      await Navigator.of(context).maybePop();
      if (!context.mounted) return;
      await showAlternativesSheet(
        context,
        controls: controls,
        itemId: item.id,
      );
    },
    onDelete: () async {
      await Navigator.of(context).maybePop();
      if (!context.mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Excluir atividade'),
          content: const Text(
            'Remover este ponto do roteiro? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      try {
        await controls.repository.deleteItineraryItem(item.id);
        await controls.reloadTrip();
      } catch (error) {
        if (!context.mounted) return;
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
    },
  );
}
