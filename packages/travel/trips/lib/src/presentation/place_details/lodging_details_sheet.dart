import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/entities/trip_accommodation.dart';
import '../../domain/place_details_view_data.dart';
import 'place_details_tokens.dart';
import 'widgets/place_map_preview.dart';

/// Bottom-sheet Detalhes for lodging: **hotel** (name + address) vs **end**
/// (address only — fim do dia / retorno).
///
/// Designs: `Detalhes_-_Modal_-_hotel` / `Detalhes_-_Modal_-_end`.
class LodgingDetailsSheet extends StatelessWidget {
  final PlaceDetailsViewData data;
  final ValueChanged<Uri>? onOpenUrl;
  final VoidCallback? onChangeLodging;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const LodgingDetailsSheet({
    super.key,
    required this.data,
    this.onOpenUrl,
    this.onChangeLodging,
    this.imageProviderBuilder,
  });

  static Future<void> show(
    BuildContext context, {
    required PlaceDetailsViewData data,
    ValueChanged<Uri>? onOpenUrl,
    VoidCallback? onChangeLodging,
    ImageProvider Function(String url)? imageProviderBuilder,
  }) {
    assert(
      data.kind == PlaceDetailsKind.hotel ||
          data.kind == PlaceDetailsKind.endOfDay,
      'LodgingDetailsSheet expects hotel or endOfDay kind',
    );
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: PlaceDetailsTokens.sheetScrim,
      builder: (ctx) {
        return LodgingDetailsSheet(
          data: data,
          onOpenUrl: onOpenUrl,
          onChangeLodging: onChangeLodging,
          imageProviderBuilder: imageProviderBuilder,
        );
      },
    );
  }

  bool get _showName => data.kind == PlaceDetailsKind.hotel;

  void _openDirections(BuildContext context) {
    final maps = data.mapsUri?.trim();
    if (maps != null && maps.isNotEmpty) {
      final uri = Uri.tryParse(maps);
      if (uri != null) {
        onOpenUrl?.call(uri);
        return;
      }
    }
    if (data.latitude != null && data.longitude != null) {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${data.latitude},${data.longitude}',
      );
      onOpenUrl?.call(uri);
    }
  }

  Future<void> _copyAddress(BuildContext context) async {
    final address = data.address?.trim();
    if (address == null || address.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: address));
    if (!context.mounted) return;
    TwoGoSnackbar.show(
      context,
      message: 'Endereço copiado',
      variant: TwoGoSnackbarVariant.success,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = data.address?.trim();

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
            _LodgingMapBlock(
              data: data,
              imageProviderBuilder: imageProviderBuilder,
              onDirections: () => _openDirections(context),
            ),
            const SizedBox(height: 16),
            _LodgingInfoCard(
              showName: _showName,
              name: data.displayName,
              address: address,
              onCopy: address == null || address.isEmpty
                  ? null
                  : () => _copyAddress(context),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).maybePop();
                onChangeLodging?.call();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: PlaceDetailsTokens.ink,
                side: const BorderSide(color: PlaceDetailsTokens.ink),
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Alterar hospedagem',
                style: TwoGoTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LodgingMapBlock extends StatelessWidget {
  final PlaceDetailsViewData data;
  final ImageProvider Function(String url)? imageProviderBuilder;
  final VoidCallback? onDirections;

  const _LodgingMapBlock({
    required this.data,
    this.imageProviderBuilder,
    this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlaceMapPreview(
          address: null,
          latitude: data.latitude,
          longitude: data.longitude,
          imageProviderBuilder: imageProviderBuilder,
          onOpenMaps: onDirections,
        ),
        if (onDirections != null &&
            (data.latitude != null || (data.mapsUri?.isNotEmpty ?? false)))
          Positioned(
            right: 12,
            bottom: 12,
            child: Material(
              color: PlaceDetailsTokens.ink,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onDirections,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Text(
                    'Obter direções',
                    style: TwoGoTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LodgingInfoCard extends StatelessWidget {
  final bool showName;
  final String name;
  final String? address;
  final VoidCallback? onCopy;

  const _LodgingInfoCard({
    required this.showName,
    required this.name,
    required this.address,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlaceDetailsTokens.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showName && name.trim().isNotEmpty) ...[
                  Text(
                    name,
                    style: TwoGoTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PlaceDetailsTokens.ink,
                    ),
                  ),
                  if (address != null && address!.trim().isNotEmpty)
                    const SizedBox(height: 4),
                ],
                if (address != null && address!.trim().isNotEmpty)
                  Text(
                    address!,
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: PlaceDetailsTokens.muted,
                    ),
                  ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              tooltip: 'Copiar endereço',
              icon: const Icon(
                Icons.copy_rounded,
                size: 20,
                color: PlaceDetailsTokens.muted,
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens hotel or end-of-day lodging Detalhes from trip accommodation.
Future<void> showLodgingDetailsFlow(
  BuildContext context, {
  required TripAccommodation stay,
  required PlaceDetailsKind kind,
  ValueChanged<Uri>? onOpenUrl,
  VoidCallback? onChangeLodging,
  ImageProvider Function(String url)? imageProviderBuilder,
}) {
  assert(
    kind == PlaceDetailsKind.hotel || kind == PlaceDetailsKind.endOfDay,
    'showLodgingDetailsFlow expects hotel or endOfDay',
  );
  final data = PlaceDetailsViewData.fromAccommodation(
    stay: stay,
    kind: kind,
  );
  return LodgingDetailsSheet.show(
    context,
    data: data,
    onOpenUrl: onOpenUrl,
    onChangeLodging: onChangeLodging,
    imageProviderBuilder: imageProviderBuilder,
  );
}
