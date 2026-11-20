import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Bottom sheet: Nome + E-mail → Enviar roteiro (Core invite uses email only).
class TripShareInviteSheet extends StatefulWidget {
  const TripShareInviteSheet({
    super.key,
    required this.onSubmit,
    this.initialName = '',
    this.initialEmail = '',
  });

  final Future<void> Function({required String name, required String email})
      onSubmit;
  final String initialName;
  final String initialEmail;

  static Future<bool?> show(
    BuildContext context, {
    required Future<void> Function({
      required String name,
      required String email,
    }) onSubmit,
  }) {
    return TwoGoBottomSheet.show<bool>(
      context,
      title: 'Compartilhar roteiro',
      child: TripShareInviteSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<TripShareInviteSheet> createState() => _TripShareInviteSheetState();
}

class _TripShareInviteSheetState extends State<TripShareInviteSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _nameError;
  String? _emailError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _nameController.addListener(_onChanged);
    _emailController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_nameError != null || _emailError != null) {
      setState(() {
        _nameError = null;
        _emailError = null;
      });
    } else {
      setState(() {});
    }
  }

  bool get _canSubmit {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    return name.isNotEmpty && email.isNotEmpty && !_submitting;
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    String? nameError;
    String? emailError;
    if (name.isEmpty) nameError = TwoGoErrorFeedback.requiredField;
    if (email.isEmpty) {
      emailError = TwoGoErrorFeedback.requiredField;
    } else if (!_looksLikeEmail(email)) {
      emailError = TwoGoErrorFeedback.invalidField;
    }
    if (nameError != null || emailError != null) {
      setState(() {
        _nameError = nameError;
        _emailError = emailError;
      });
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(name: name, email: email);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // Caller presents TwoGoErrorFeedback; keep sheet open for retry.
      if (mounted) setState(() => _submitting = false);
    }
  }

  static bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TwoGoTextField(
          label: 'Nome:',
          controller: _nameController,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: TwoGoSpacing.md),
        TwoGoTextField(
          label: 'E-mail:',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_canSubmit) _submit();
          },
        ),
        const SizedBox(height: TwoGoSpacing.lg),
        TwoGoButton(
          text: 'Enviar roteiro',
          loading: _submitting,
          onPressed: _canSubmit ? _submit : null,
        ),
      ],
    );
  }
}
