import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../profile_tokens.dart';
import '../account_profile_cubit.dart';
import '../widgets/profile_back_button.dart';

/// Crop / Salvar screen for alterar foto.
///
/// Salvar uploads a local image via Core `POST /media/upload/avatar`.
/// Network URLs (edit existing photo) dismiss without inventing a new API.
class ChangePhotoPage extends StatefulWidget {
  const ChangePhotoPage({
    super.key,
    required this.imagePath,
    this.onBack,
    this.onSaved,
  });

  /// Local file path or http(s) URL.
  final String imagePath;
  final VoidCallback? onBack;
  final VoidCallback? onSaved;

  @override
  State<ChangePhotoPage> createState() => _ChangePhotoPageState();
}

class _ChangePhotoPageState extends State<ChangePhotoPage> {
  final TransformationController _transform = TransformationController();
  bool _saving = false;

  bool get _isNetwork =>
      widget.imagePath.startsWith('http://') ||
      widget.imagePath.startsWith('https://');

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  ImageProvider get _provider {
    if (_isNetwork) return NetworkImage(widget.imagePath);
    return FileImage(File(widget.imagePath));
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      if (_isNetwork) {
        // Already on Core CDN — no PATCH/delete/reupload endpoint for crop-only.
        (widget.onSaved ??
            widget.onBack ??
            () => Navigator.of(context).maybePop())();
        return;
      }

      final cubit = context.read<AccountProfileCubit>();
      final navigator = Navigator.of(context);
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final name = widget.imagePath.split('/').last;
      final lower = name.toLowerCase();
      final contentType = lower.endsWith('.png')
          ? 'image/png'
          : lower.endsWith('.webp')
              ? 'image/webp'
              : 'image/jpeg';

      final ok = await cubit.uploadAvatarBytes(
            bytes: bytes,
            filename: name.isEmpty ? 'avatar.jpg' : name,
            contentType: contentType,
          );

      if (!mounted) return;
      if (ok) {
        TwoGoSnackbar.show(
          context,
          message: 'Foto atualizada.',
          variant: TwoGoSnackbarVariant.success,
        );
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else if (widget.onBack != null) {
          widget.onBack!();
        } else {
          await navigator.maybePop();
        }
      } else {
        final failure = cubit.state.failure;
        if (failure != null) {
          TwoGoErrorFeedback.present(context, failure);
        }
      }
    } catch (_) {
      if (mounted) {
        TwoGoSnackbar.show(
          context,
          message: 'Não foi possível salvar a foto.',
          variant: TwoGoSnackbarVariant.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: profileAppBar(
        title: 'Alterar foto',
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ProfileTokens.pageGutter,
          ),
          child: Column(
            children: [
              const SizedBox(height: TwoGoSpacing.md),
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ProfileTokens.cropRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: TwoGoColors.neutral200,
                        child: InteractiveViewer(
                          transformationController: _transform,
                          minScale: 1,
                          maxScale: 4,
                          child: Image(
                            image: _provider,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                      const IgnorePointer(
                        child: CustomPaint(
                          painter: _DashedCircleCropPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TwoGoSpacing.xl),
              TwoGoButton(
                text: 'Salvar',
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: TwoGoSpacing.sm),
              TextButton(
                onPressed: _saving
                    ? null
                    : (widget.onBack ??
                        () => Navigator.of(context).maybePop()),
                child: Text(
                  'Cancelar',
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

class _DashedCircleCropPainter extends CustomPainter {
  const _DashedCircleCropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final radius = size.width * 0.32;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dash = 8.0;
    const gap = 6.0;
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
