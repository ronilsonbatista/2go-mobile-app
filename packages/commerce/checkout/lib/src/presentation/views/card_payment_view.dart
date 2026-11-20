import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/checkout_currency_format.dart';
import '../../domain/checkout_saved_card.dart';

/// Cartão de crédito screen — new card form and/or saved card + CVV.
class CardPaymentView extends StatefulWidget {
  final double amount;
  final CheckoutSavedCard? savedCard;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback? onBack;
  final void Function({
    required String cardNumber,
    required String holderName,
    required String expiry,
    required String cvv,
    required bool saveCard,
    required bool usingSavedCard,
  }) onPay;

  const CardPaymentView({
    super.key,
    required this.amount,
    this.savedCard,
    this.isSubmitting = false,
    this.errorMessage,
    this.onBack,
    required this.onPay,
  });

  @override
  State<CardPaymentView> createState() => _CardPaymentViewState();
}

class _CardPaymentViewState extends State<CardPaymentView> {
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveCard = false;
  bool _useSavedCard = false;

  @override
  void initState() {
    super.initState();
    _useSavedCard = widget.savedCard != null;
    for (final c in [
      _numberController,
      _nameController,
      _expiryController,
      _cvvController,
    ]) {
      c.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _numberController,
      _nameController,
      _expiryController,
      _cvvController,
    ]) {
      c.removeListener(_onChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canPay {
    if (widget.isSubmitting) return false;
    if (_useSavedCard && widget.savedCard != null) {
      return _expiryController.text.trim().length >= 7 &&
          _cvvController.text.trim().length >= 3;
    }
    final numberDigits =
        _numberController.text.replaceAll(RegExp(r'\D'), '');
    return numberDigits.length >= 13 &&
        _nameController.text.trim().length >= 3 &&
        _expiryController.text.trim().length >= 7 &&
        _cvvController.text.trim().length >= 3;
  }

  void _submit() {
    if (!_canPay) return;
    widget.onPay(
      cardNumber: _numberController.text,
      holderName: _nameController.text,
      expiry: _expiryController.text,
      cvv: _cvvController.text,
      saveCard: _saveCard,
      usingSavedCard: _useSavedCard && widget.savedCard != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: TwoGoAppBar(
        title: 'Cartão de crédito',
        onBackPressed: widget.onBack,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                TwoGoSpacing.md,
                TwoGoSpacing.sm,
                TwoGoSpacing.md,
                TwoGoSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.savedCard != null) ...[
                    _SavedCardOption(
                      card: widget.savedCard!,
                      selected: _useSavedCard,
                      onTap: () => setState(() => _useSavedCard = true),
                    ),
                    const SizedBox(height: TwoGoSpacing.xs),
                    _NewCardOption(
                      selected: !_useSavedCard,
                      onTap: () => setState(() => _useSavedCard = false),
                    ),
                    const SizedBox(height: TwoGoSpacing.md),
                  ],
                  if (_useSavedCard && widget.savedCard != null)
                    _SavedCardFields(
                      expiryController: _expiryController,
                      cvvController: _cvvController,
                    )
                  else
                    _NewCardFields(
                      numberController: _numberController,
                      nameController: _nameController,
                      expiryController: _expiryController,
                      cvvController: _cvvController,
                      saveCard: _saveCard,
                      onSaveChanged: (v) => setState(() => _saveCard = v),
                    ),
                  if (widget.errorMessage != null) ...[
                    const SizedBox(height: TwoGoSpacing.sm),
                    TwoGoInlineFeedback(
                      message: widget.errorMessage!,
                      variant: TwoGoInlineFeedbackVariant.error,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TwoGoSpacing.md,
                TwoGoSpacing.sm,
                TwoGoSpacing.md,
                TwoGoSpacing.md,
              ),
              child: TwoGoButton(
                text: 'Pagar ${formatCheckoutCurrency(widget.amount)}',
                loading: widget.isSubmitting,
                onPressed: _canPay ? _submit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedCardOption extends StatelessWidget {
  const _SavedCardOption({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final CheckoutSavedCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _RadioRow(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          const _MastercardMark(),
          const SizedBox(width: TwoGoSpacing.sm),
          Text(
            card.maskedLabel,
            style: TwoGoTypography.bodyLarge.copyWith(
              color: TwoGoColors.contentPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewCardOption extends StatelessWidget {
  const _NewCardOption({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _RadioRow(
      selected: selected,
      onTap: onTap,
      child: Text(
        'Novo cartão',
        style: TwoGoTypography.bodyLarge.copyWith(
          color: TwoGoColors.contentPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwoGoColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(TwoGoRadius.large),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TwoGoRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(TwoGoSpacing.md),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? TwoGoColors.brandLime
                    : TwoGoColors.contentSecondary,
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedCardFields extends StatelessWidget {
  const _SavedCardFields({
    required this.expiryController,
    required this.cvvController,
  });

  final TextEditingController expiryController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TwoGoTextField(
            label: 'Validade',
            hint: 'MM / AAAA',
            controller: expiryController,
            keyboardType: TextInputType.number,
            inputFormatters: [_ExpiryInputFormatter()],
          ),
        ),
        const SizedBox(width: TwoGoSpacing.sm),
        Expanded(
          child: TwoGoTextField(
            label: 'CVV',
            controller: cvvController,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ),
        ),
      ],
    );
  }
}

class _NewCardFields extends StatelessWidget {
  const _NewCardFields({
    required this.numberController,
    required this.nameController,
    required this.expiryController,
    required this.cvvController,
    required this.saveCard,
    required this.onSaveChanged,
  });

  final TextEditingController numberController;
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final bool saveCard;
  final ValueChanged<bool> onSaveChanged;

  @override
  Widget build(BuildContext context) {
    final digits = numberController.text.replaceAll(RegExp(r'\D'), '');
    final showBrand = digits.length >= 2;

    return Container(
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      decoration: BoxDecoration(
        color: TwoGoColors.surfacePrimary,
        borderRadius: BorderRadius.circular(TwoGoRadius.large),
        border: Border.all(color: TwoGoColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados do cartão',
            style: TwoGoTypography.titleMedium.copyWith(
              color: TwoGoColors.contentPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.md),
          TwoGoTextField(
            label: 'Número do cartão',
            controller: numberController,
            keyboardType: TextInputType.number,
            inputFormatters: [_CardNumberInputFormatter()],
            suffix: showBrand ? const _MastercardMark() : null,
          ),
          const SizedBox(height: TwoGoSpacing.sm),
          TwoGoTextField(
            label: 'Nome no cartão',
            controller: nameController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: TwoGoSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TwoGoTextField(
                  label: 'Validade',
                  hint: 'MM / AAAA',
                  controller: expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_ExpiryInputFormatter()],
                ),
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: TwoGoTextField(
                  label: 'CVV',
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.md),
          TwoGoCheckbox(
            value: saveCard,
            onChanged: (v) => onSaveChanged(v ?? false),
            label: 'Salvar dados do cartão',
          ),
        ],
      ),
    );
  }
}

class _MastercardMark extends StatelessWidget {
  const _MastercardMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(capped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 6 ? digits.substring(0, 6) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(capped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
