import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twogo_design_system/design_system.dart';

/// Dados pessoais block — shown for 1ª compra and invite (Caso 2).
class CheckoutPersonalDataSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController cpfController;
  final ValueChanged<String>? onChanged;

  const CheckoutPersonalDataSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.cpfController,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados pessoais',
          style: TwoGoTypography.titleMedium.copyWith(
            color: TwoGoColors.contentPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoTextField(
          label: 'Nome completo:',
          controller: nameController,
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoTextField(
          label: 'Telefone:',
          hint: '(00) 9 1234 5678',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          inputFormatters: [_PhoneInputFormatter()],
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoTextField(
          label: 'CPF:',
          controller: cpfController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
            _CpfInputFormatter(),
          ],
        ),
      ],
    );
  }
}

/// Soft phone mask approximating `(00) 9 1234 5678`.
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 3) buffer.write(' ');
      if (i == 7) buffer.write(' ');
      buffer.write(capped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(capped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
