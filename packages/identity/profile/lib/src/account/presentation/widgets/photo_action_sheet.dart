import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../profile_tokens.dart';

enum PhotoSheetAction {
  takePhoto,
  pickGallery,
  removePhoto,
  editCrop,
  takeNewPhoto,
  pickAnotherGallery,
  cancel,
}

/// iOS-style action sheet for alterar foto (empty vs existing photo).
class PhotoActionSheet extends StatelessWidget {
  const PhotoActionSheet({
    super.key,
    required this.hasPhoto,
  });

  final bool hasPhoto;

  static Future<PhotoSheetAction?> show(
    BuildContext context, {
    required bool hasPhoto,
  }) {
    return showModalBottomSheet<PhotoSheetAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: ProfileTokens.sheetBarrier,
      builder: (_) => PhotoActionSheet(hasPhoto: hasPhoto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final actions = hasPhoto
        ? const <(PhotoSheetAction, String)>[
            (PhotoSheetAction.removePhoto, 'Remover foto'),
            (PhotoSheetAction.editCrop, 'Editar recorte'),
            (PhotoSheetAction.takeNewPhoto, 'Tirar nova foto'),
            (PhotoSheetAction.pickAnotherGallery, 'Escolher outra foto na galeria'),
          ]
        : const <(PhotoSheetAction, String)>[
            (PhotoSheetAction.takePhoto, 'Tirar foto'),
            (PhotoSheetAction.pickGallery, 'Escolher na galeria'),
          ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ProfileTokens.pageGutter,
        0,
        ProfileTokens.pageGutter,
        ProfileTokens.pageGutter / 2 + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetCard(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Selecione',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TwoGoColors.contentSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              for (var i = 0; i < actions.length; i++) ...[
                const Divider(height: 1, color: TwoGoColors.neutral200),
                _ActionRow(
                  label: actions[i].$2,
                  onTap: () => Navigator.of(context).pop(actions[i].$1),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _SheetCard(
            children: [
              _ActionRow(
                label: 'Cancelar',
                bold: true,
                onTap: () =>
                    Navigator.of(context).pop(PhotoSheetAction.cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetCard extends StatelessWidget {
  const _SheetCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwoGoColors.neutral100,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.onTap,
    this.bold = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: ProfileTokens.actionBlue,
              fontSize: 18,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
