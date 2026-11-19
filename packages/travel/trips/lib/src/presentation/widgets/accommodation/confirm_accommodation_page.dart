import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../../domain/paid_trip_controls.dart';
import '../trip_control_sheets.dart';
import 'accommodation_candidate.dart';

/// Design: map pin + name + address + Selecionar hospedagem / Alterar.
class ConfirmAccommodationPage extends StatefulWidget {
  final TripControls controls;
  final String tripId;
  final AccommodationCandidate candidate;
  final VoidCallback onChange;

  const ConfirmAccommodationPage({
    super.key,
    required this.controls,
    required this.tripId,
    required this.candidate,
    required this.onChange,
  });

  @override
  State<ConfirmAccommodationPage> createState() =>
      _ConfirmAccommodationPageState();
}

class _ConfirmAccommodationPageState extends State<ConfirmAccommodationPage> {
  var _saving = false;
  String? _error;

  Future<void> _select() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final c = widget.candidate;
      if (widget.tripId != 'debug-preview') {
        await widget.controls.repository.saveAccommodation(
          widget.tripId,
          AccommodationDraft(
            name: c.name,
            address: c.address,
            neighborhood: c.neighborhood,
            zipCode: c.zipCode,
            latitude: c.latitude,
            longitude: c.longitude,
            providerPlaceId: c.providerPlaceId,
          ),
        );
        if (!mounted) return;
        await widget.controls.reloadTrip();
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
    final c = widget.candidate;
    return Scaffold(
      backgroundColor: TwoGoColors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: TwoGoColors.surfacePrimary,
        elevation: 0,
        centerTitle: true,
        leading: _CircleBack(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Adicionar hospedagem',
          style: TwoGoTypography.titleMedium.copyWith(
            color: TwoGoColors.contentPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TwoGoSpacing.sm),
              _MapPreview(
                latitude: c.latitude,
                longitude: c.longitude,
              ),
              const SizedBox(height: TwoGoSpacing.lg),
              const Text('🏨', style: TextStyle(fontSize: 28)),
              const SizedBox(height: TwoGoSpacing.sm),
              Text(
                c.name,
                style: TwoGoTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (c.address != null && c.address!.trim().isNotEmpty) ...[
                const SizedBox(height: TwoGoSpacing.xs),
                Text(
                  c.address!,
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: TwoGoSpacing.md),
                Text(
                  _error!,
                  style: TwoGoTypography.bodySmall.copyWith(
                    color: TwoGoColors.error,
                  ),
                ),
              ],
              const Spacer(),
              TwoGoButton(
                text: 'Selecionar hospedagem',
                loading: _saving,
                onPressed: _saving ? null : _select,
              ),
              const SizedBox(height: TwoGoSpacing.sm),
              TextButton(
                onPressed: _saving ? null : widget.onChange,
                child: Text(
                  'Alterar hospedagem',
                  style: TwoGoTypography.titleMedium.copyWith(
                    color: TwoGoColors.contentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: TwoGoSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  final VoidCallback onPressed;

  const _CircleBack({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: TwoGoSpacing.sm),
      child: Center(
        child: Material(
          color: TwoGoColors.surfacePrimary,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.chevron_left, color: TwoGoColors.contentPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const _MapPreview({this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    final hasPin = latitude != null && longitude != null;
    final mapUrl = hasPin
        ? 'https://staticmap.openstreetmap.de/staticmap.php'
            '?center=$latitude,$longitude&zoom=15&size=640x360'
            '&markers=$latitude,$longitude,red-pushpin'
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: TwoGoColors.surfaceSecondary,
              child: mapUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: TwoGoColors.contentSecondary,
                      ),
                    )
                  : Image.network(
                      mapUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: TwoGoColors.contentSecondary,
                        ),
                      ),
                    ),
            ),
            if (hasPin)
              const Align(
                alignment: Alignment(0, -0.05),
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFFE53935),
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
