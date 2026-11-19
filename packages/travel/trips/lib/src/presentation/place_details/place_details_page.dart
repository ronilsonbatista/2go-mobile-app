import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/place_details_view_data.dart';
import 'place_details_tokens.dart';
import 'widgets/place_duration_stepper.dart';
import 'widgets/place_map_preview.dart';
import 'widgets/place_photo_carousel.dart';
import 'widgets/place_reviews_section.dart';

/// Full-screen Detalhes (restaurant pick / attraction pick / itinerary edit).
class PlaceDetailsPage extends StatefulWidget {
  final PlaceDetailsViewData data;
  final ValueChanged<Uri>? onOpenUrl;
  final ValueChanged<int>? onDurationChanged;
  final Future<void> Function(int minutes)? onSaveDuration;
  final VoidCallback? onSelect;
  final VoidCallback? onSubstitute;
  final VoidCallback? onDelete;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const PlaceDetailsPage({
    super.key,
    required this.data,
    this.onOpenUrl,
    this.onDurationChanged,
    this.onSaveDuration,
    this.onSelect,
    this.onSubstitute,
    this.onDelete,
    this.imageProviderBuilder,
  });

  static Future<T?> open<T>(
    BuildContext context, {
    required PlaceDetailsViewData data,
    ValueChanged<Uri>? onOpenUrl,
    ValueChanged<int>? onDurationChanged,
    Future<void> Function(int minutes)? onSaveDuration,
    VoidCallback? onSelect,
    VoidCallback? onSubstitute,
    VoidCallback? onDelete,
    ImageProvider Function(String url)? imageProviderBuilder,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => PlaceDetailsPage(
          data: data,
          onOpenUrl: onOpenUrl,
          onDurationChanged: onDurationChanged,
          onSaveDuration: onSaveDuration,
          onSelect: onSelect,
          onSubstitute: onSubstitute,
          onDelete: onDelete,
          imageProviderBuilder: imageProviderBuilder,
        ),
      ),
    );
  }

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  late int _duration;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _duration = widget.data.durationMinutes ?? 50;
  }

  Future<void> _persistDuration(int minutes) async {
    setState(() {
      _duration = minutes;
      _saving = true;
    });
    widget.onDurationChanged?.call(minutes);
    try {
      await widget.onSaveDuration?.call(minutes);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openUri(String? raw) {
    if (raw == null || raw.isEmpty || widget.onOpenUrl == null) return;
    final uri = Uri.tryParse(raw);
    if (uri != null) widget.onOpenUrl!(uri);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final edit = data.mode == PlaceDetailsMode.edit && !data.isMealSlot;

    return Scaffold(
      backgroundColor: PlaceDetailsTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PlaceDetailsTokens.pageGutter,
                  8,
                  PlaceDetailsTokens.pageGutter,
                  24,
                ),
                children: [
                  PlacePhotoCarousel(
                    photoUrls: data.photoUrls,
                    imageProviderBuilder: widget.imageProviderBuilder,
                  ),
                  const SizedBox(height: PlaceDetailsTokens.sectionGap),
                  _TitleRow(name: data.displayName, rating: data.rating),
                  if (data.cuisineTags != null &&
                      data.cuisineTags!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _MetaRow(
                      icon: Icons.restaurant_outlined,
                      iconColor: PlaceDetailsTokens.muted,
                      text: data.cuisineTags!,
                      textColor: PlaceDetailsTokens.muted,
                    ),
                  ],
                  if (data.openingHoursText != null &&
                      data.openingHoursText!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _MetaRow(
                      icon: Icons.alarm,
                      iconColor: PlaceDetailsTokens.clockRed,
                      text: data.openingHoursText!,
                      textColor: PlaceDetailsTokens.hoursGreen,
                    ),
                  ],
                  if (data.description != null &&
                      data.description!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      data.description!,
                      style: TwoGoTypography.bodyMedium.copyWith(
                        color: PlaceDetailsTokens.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _PriceLinkRow(
                    priceLevelDisplay: data.priceLevelDisplay,
                    linkLabel: data.externalLinkLabel,
                    onLinkTap: () => _openUri(data.externalLinkUri),
                  ),
                  const SizedBox(height: PlaceDetailsTokens.sectionGap),
                  PlaceMapPreview(
                    address: data.address,
                    latitude: data.latitude,
                    longitude: data.longitude,
                    onOpenMaps: () => _openUri(data.mapsUri),
                    imageProviderBuilder: widget.imageProviderBuilder,
                  ),
                  if (data.reviews.isNotEmpty) ...[
                    const SizedBox(height: PlaceDetailsTokens.sectionGap),
                    PlaceReviewsSection(
                      reviews: data.reviews,
                      onMoreReviews: data.mapsUri == null
                          ? null
                          : () => _openUri(data.mapsUri),
                      imageProviderBuilder: widget.imageProviderBuilder,
                    ),
                  ],
                  if (edit) ...[
                    const SizedBox(height: PlaceDetailsTokens.sectionGap),
                    PlaceDurationStepper(
                      minutes: _duration,
                      recommendedMinutes: data.recommendedDurationMinutes,
                      onChanged: _saving ? null : _persistDuration,
                    ),
                  ],
                  const SizedBox(height: 88),
                ],
              ),
            ),
            _Footer(
              mode: data.mode,
              selectLabel: data.selectCtaLabel,
              substituteLabel: data.substituteCtaLabel,
              onSelect: widget.onSelect,
              onSubstitute: widget.onSubstitute,
              onDelete: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PlaceDetailsTokens.pageGutter - 4,
        4,
        PlaceDetailsTokens.pageGutter,
        4,
      ),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: PlaceDetailsTokens.chipSurface,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const SizedBox(
                    width: PlaceDetailsTokens.backCircle,
                    height: PlaceDetailsTokens.backCircle,
                    child: Icon(Icons.chevron_left, size: 28),
                  ),
                ),
              ),
            ),
            Text(
              'Detalhes',
              style: TwoGoTypography.titleMedium.copyWith(
                color: PlaceDetailsTokens.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String name;
  final double? rating;

  const _TitleRow({required this.name, this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: TwoGoTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: PlaceDetailsTokens.ink,
            ),
          ),
        ),
        if (rating != null) ...[
          const SizedBox(width: 8),
          const Icon(Icons.star_rounded, color: PlaceDetailsTokens.star, size: 20),
          const SizedBox(width: 4),
          Text(
            rating!.toStringAsFixed(rating! % 1 == 0 ? 1 : 1),
            style: TwoGoTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  const _MetaRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TwoGoTypography.bodyMedium.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

class _PriceLinkRow extends StatelessWidget {
  final String? priceLevelDisplay;
  final String? linkLabel;
  final VoidCallback? onLinkTap;

  const _PriceLinkRow({
    this.priceLevelDisplay,
    this.linkLabel,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice =
        priceLevelDisplay != null && priceLevelDisplay!.trim().isNotEmpty;
    final hasLink = linkLabel != null;

    if (!hasPrice && !hasLink) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasPrice) ...[
          Text(
            'Preço',
            style: TwoGoTypography.bodyMedium.copyWith(
              color: PlaceDetailsTokens.muted,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            priceLevelDisplay!,
            style: TwoGoTypography.titleMedium.copyWith(
              color: PlaceDetailsTokens.priceBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const Spacer(),
        if (hasLink)
          InkWell(
            onTap: onLinkTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  linkLabel!,
                  style: TwoGoTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PlaceDetailsTokens.ink,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.north_east,
                  size: 16,
                  color: PlaceDetailsTokens.lime,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final PlaceDetailsMode mode;
  final String selectLabel;
  final String substituteLabel;
  final VoidCallback? onSelect;
  final VoidCallback? onSubstitute;
  final VoidCallback? onDelete;

  const _Footer({
    required this.mode,
    required this.selectLabel,
    required this.substituteLabel,
    this.onSelect,
    this.onSubstitute,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        PlaceDetailsTokens.pageGutter,
        12,
        PlaceDetailsTokens.pageGutter,
        12 + MediaQuery.paddingOf(context).bottom.clamp(0, 12),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: PlaceDetailsTokens.cardBorder)),
      ),
      child: mode == PlaceDetailsMode.pick
          ? TwoGoButton(
              text: selectLabel,
              onPressed: onSelect,
              fullWidth: true,
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: onSubstitute,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PlaceDetailsTokens.ink,
                      side: const BorderSide(color: PlaceDetailsTokens.ink),
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      substituteLabel,
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
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PlaceDetailsTokens.deleteInk,
                      backgroundColor: PlaceDetailsTokens.deleteFill,
                      side: const BorderSide(
                        color: PlaceDetailsTokens.deleteBorder,
                      ),
                      minimumSize: const Size.fromHeight(52),
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
    );
  }
}
