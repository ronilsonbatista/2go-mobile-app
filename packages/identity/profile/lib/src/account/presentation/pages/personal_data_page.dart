import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../profile_tokens.dart';
import '../account_profile_cubit.dart';
import '../widgets/profile_back_button.dart';

/// Dados pessoais — layout from design. Prefills name/email from
/// `GET /users/me`. Salvar applies local state only (Core has no PATCH).
class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _cpf;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AccountProfileCubit>().state.profile;
    _name = TextEditingController(text: profile.displayName ?? '');
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phone ?? '');
    _cpf = TextEditingController(text: profile.cpf ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _cpf.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = TwoGoErrorFeedback.requiredField);
      return;
    }
    setState(() => _nameError = null);
    context.read<AccountProfileCubit>().applyPersonalDataLocally(
          displayName: name,
          phone: _phone.text,
          cpf: _cpf.text,
        );
    TwoGoSnackbar.show(
      context,
      message: 'Dados salvos neste aparelho.',
      variant: TwoGoSnackbarVariant.success,
    );
    (widget.onBack ?? () => Navigator.of(context).maybePop())();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: profileAppBar(
        title: 'Dados pessoais',
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  ProfileTokens.pageGutter,
                  TwoGoSpacing.md,
                  ProfileTokens.pageGutter,
                  TwoGoSpacing.md,
                ),
                child: Container(
                  padding: const EdgeInsets.all(TwoGoSpacing.md),
                  decoration: BoxDecoration(
                    color: TwoGoColors.surfacePrimary,
                    borderRadius:
                        BorderRadius.circular(ProfileTokens.cardRadius),
                    border: Border.all(color: TwoGoColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TwoGoTextField(
                        label: 'Nome completo',
                        controller: _name,
                        errorText: _nameError,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: ProfileTokens.fieldGap),
                      TwoGoTextField(
                        label: 'E-mail',
                        controller: _email,
                        enabled: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: ProfileTokens.fieldGap),
                      TwoGoTextField(
                        label: 'Telefone',
                        controller: _phone,
                        hint: '(00) 9 1234 5678',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: const [_PhoneInputFormatter()],
                      ),
                      const SizedBox(height: ProfileTokens.fieldGap),
                      TwoGoTextField(
                        label: 'CPF',
                        controller: _cpf,
                        enabled: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          const _CpfInputFormatter(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ProfileTokens.pageGutter,
                0,
                ProfileTokens.pageGutter,
                TwoGoSpacing.lg,
              ),
              child: TwoGoButton(text: 'Salvar', onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  const _PhoneInputFormatter();

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
  const _CpfInputFormatter();

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
