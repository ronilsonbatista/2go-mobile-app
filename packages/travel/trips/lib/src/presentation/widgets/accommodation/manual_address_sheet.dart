import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import 'accommodation_candidate.dart';

/// Design: Endereço da hospedagem — CEP, logradouro, número, bairro.
Future<AccommodationCandidate?> showManualAddressSheet(
  BuildContext context,
) {
  return TwoGoBottomSheet.show<AccommodationCandidate>(
    context,
    title: 'Endereço da hospedagem',
    child: const _ManualAddressForm(),
  );
}

class _ManualAddressForm extends StatefulWidget {
  const _ManualAddressForm();

  @override
  State<_ManualAddressForm> createState() => _ManualAddressFormState();
}

class _ManualAddressFormState extends State<_ManualAddressForm> {
  final _zip = TextEditingController();
  final _street = TextEditingController();
  final _number = TextEditingController();
  final _neighborhood = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _zip.dispose();
    _street.dispose();
    _number.dispose();
    _neighborhood.dispose();
    super.dispose();
  }

  void _save() {
    final street = _street.text.trim();
    if (street.isEmpty) {
      setState(() => _error = 'Informe o logradouro.');
      return;
    }
    final number = _number.text.trim();
    final neighborhood = _neighborhood.text.trim();
    final zip = _zip.text.trim();
    final addressParts = <String>[
      if (number.isNotEmpty) '$street, $number' else street,
      if (neighborhood.isNotEmpty) neighborhood,
      if (zip.isNotEmpty) zip,
    ];
    Navigator.of(context).pop(
      AccommodationCandidate(
        name: street,
        address: addressParts.join(' · '),
        neighborhood: neighborhood.isEmpty ? null : neighborhood,
        zipCode: zip.isEmpty ? null : zip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TwoGoSpacing.lg,
        0,
        TwoGoSpacing.lg,
        TwoGoSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            Text(
              _error!,
              style: TwoGoTypography.bodySmall.copyWith(
                color: TwoGoColors.error,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.sm),
          ],
          TwoGoTextField(
            key: const Key('manual-zip'),
            label: 'Código postal',
            controller: _zip,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: TwoGoSpacing.md),
          TwoGoTextField(
            key: const Key('manual-street'),
            label: 'Logradouro',
            controller: _street,
          ),
          const SizedBox(height: TwoGoSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: TwoGoTextField(
                  key: const Key('manual-number'),
                  label: 'Número',
                  controller: _number,
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: TwoGoTextField(
                  key: const Key('manual-neighborhood'),
                  label: 'Bairro',
                  controller: _neighborhood,
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.lg),
          TwoGoButton(
            text: 'Salvar endereço',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
