import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Modal "Adicionar cupom" matching design frames.
Future<String?> showCheckoutCouponSheet(BuildContext context) {
  return TwoGoBottomSheet.show<String>(
    context,
    title: 'Adicionar cupom',
    child: const _CouponSheetBody(),
  );
}

class _CouponSheetBody extends StatefulWidget {
  const _CouponSheetBody();

  @override
  State<_CouponSheetBody> createState() => _CouponSheetBodyState();
}

class _CouponSheetBodyState extends State<_CouponSheetBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TwoGoTextField(
          label: 'Código do cupom',
          controller: _controller,
          prefixIcon: Icons.card_giftcard_outlined,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _apply(),
          autofocus: true,
        ),
        const SizedBox(height: TwoGoSpacing.lg),
        TwoGoButton(
          text: 'Aplicar',
          onPressed: _apply,
        ),
      ],
    );
  }
}
