import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';

/// Shared course confirm / delete sheet (Revisão Continuar + Onde delete).
///
/// [fullBleed] = true → edge-to-edge bottom sheet (Deseja continuar?).
/// [fullBleed] = false → inset card with page gutters (delete destino).
class PlanningCourseSheet extends StatelessWidget {
  const PlanningCourseSheet({
    super.key,
    required this.title,
    this.body,
    this.confirmLabel = 'Continuar',
    this.cancelLabel = 'Cancelar',
    this.fullBleed = false,
  });

  final String title;
  final String? body;
  final String confirmLabel;
  final String cancelLabel;
  final bool fullBleed;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? body,
    String confirmLabel = 'Continuar',
    String cancelLabel = 'Cancelar',
    bool fullBleed = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => PlanningCourseSheet(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        fullBleed: fullBleed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final sheet = Material(
      color: FormCourseTokens.surface,
      borderRadius: fullBleed
          ? const BorderRadius.vertical(
              top: Radius.circular(FormCourseTokens.sheetRadius),
            )
          : BorderRadius.circular(FormCourseTokens.sheetRadius),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          FormCourseTokens.pageGutter,
          FormCourseTokens.sheetTopPadding,
          FormCourseTokens.sheetCloseInset,
          fullBleed
              ? FormCourseTokens.pageGutter + bottomInset
              : FormCourseTokens.pageGutter,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(
                  TwoGoIcons.close,
                  color: FormCourseTokens.ink,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: FormCourseTokens.pageGutter -
                    FormCourseTokens.sheetCloseInset,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TwoGoTypography.headlineSmall.copyWith(
                  color: FormCourseTokens.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (body != null && body!.isNotEmpty) ...[
              const SizedBox(height: TwoGoSpacing.md),
              Padding(
                padding: const EdgeInsets.only(
                  right: FormCourseTokens.pageGutter -
                      FormCourseTokens.sheetCloseInset,
                ),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: FormCourseTokens.label,
                  ),
                ),
              ),
            ],
            const SizedBox(height: TwoGoSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: FormCourseTokens.lime,
                  foregroundColor: FormCourseTokens.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TwoGoRadius.full),
                  ),
                  textStyle: TwoGoTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(confirmLabel),
              ),
            ),
            const SizedBox(height: TwoGoSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelLabel,
                style: TwoGoTypography.titleMedium.copyWith(
                  color: FormCourseTokens.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (fullBleed) {
      return sheet;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        FormCourseTokens.pageGutter,
        0,
        FormCourseTokens.pageGutter,
        FormCourseTokens.pageGutter + bottomInset,
      ),
      child: sheet,
    );
  }
}
