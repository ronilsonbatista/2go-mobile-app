import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class ComponentsCatalogView extends StatefulWidget {
  const ComponentsCatalogView({super.key});

  @override
  State<ComponentsCatalogView> createState() => _ComponentsCatalogViewState();
}

class _ComponentsCatalogViewState extends State<ComponentsCatalogView> {
  bool _checkboxVal = false;
  String _otpVal = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      children: [
        // Buttons
        const Text('Buttons', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoButton(text: 'Continuar (Primary)', onPressed: () {}),
        const SizedBox(height: TwoGoSpacing.xs),
        TwoGoButton(
          text: 'Continuar (Loading)',
          loading: true,
          onPressed: () {},
        ),
        const SizedBox(height: TwoGoSpacing.xs),
        TwoGoButton(
          text: 'Reenviar código (Secondary)',
          variant: TwoGoButtonVariant.secondary,
          onPressed: () {},
        ),
        const SizedBox(height: TwoGoSpacing.xs),
        TwoGoButton(
          text: 'Cancelar (Tertiary)',
          variant: TwoGoButtonVariant.tertiary,
          onPressed: () {},
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Inputs
        const Text('Inputs', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoTextField(label: 'Entrar com e-mail', hint: 'seu.email@gmail.com'),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoTextField(
          label: 'Campo com erro',
          hint: '123456',
          errorText: 'Código inválido. Verifique e tente novamente.',
        ),
        const SizedBox(height: TwoGoSpacing.md),
        Text('OTP Input (6 dígitos)', style: TwoGoTypography.titleMedium),
        const SizedBox(height: TwoGoSpacing.xs),
        TwoGoOtpField(
          length: 6,
          value: _otpVal,
          onChanged: (val) => setState(() => _otpVal = val),
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Selection
        const Text('Selection', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoCheckbox(
          value: _checkboxVal,
          label: 'Salvar dados do cartão',
          onChanged: (val) => setState(() => _checkboxVal = val ?? false),
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Cards & Navigation
        const Text('Cards & Navigation', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card de exemplo', style: TwoGoTypography.titleMedium),
              const SizedBox(height: TwoGoSpacing.xxs),
              Text(
                'Superfície simples reutilizável',
                style: TwoGoTypography.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoListTile(
          leading: const Icon(TwoGoIcons.creditCard),
          title: 'Cartão de crédito',
          subtitle: '**** 4408',
          onTap: () {},
        ),
        TwoGoListTile(
          leading: const Icon(TwoGoIcons.pix),
          title: 'PIX',
          onTap: () {},
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Feedback & Overlays
        const Text(
          'Feedback & Overlays',
          style: TwoGoTypography.headlineMedium,
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoButton(
          text: 'Exibir Toast Sucesso',
          variant: TwoGoButtonVariant.secondary,
          onPressed: () {
            TwoGoSnackbar.show(
              context,
              message: 'Código reenviado com sucesso',
              variant: TwoGoSnackbarVariant.success,
            );
          },
        ),
        const SizedBox(height: TwoGoSpacing.xs),
        TwoGoButton(
          text: 'Exibir Toast Erro',
          variant: TwoGoButtonVariant.secondary,
          onPressed: () {
            TwoGoSnackbar.show(
              context,
              message: 'Código inválido',
              variant: TwoGoSnackbarVariant.error,
            );
          },
        ),
        const SizedBox(height: TwoGoSpacing.xs),
        TwoGoButton(
          text: 'Abrir Bottom Sheet',
          variant: TwoGoButtonVariant.secondary,
          onPressed: () {
            TwoGoBottomSheet.show(
              context,
              title: 'Adicionar cupom',
              child: Column(
                children: [
                  TwoGoTextField(label: 'Código do cupom:', hint: 'CUPOM2GO'),
                  const SizedBox(height: TwoGoSpacing.md),
                  TwoGoButton(
                    text: 'Aplicar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Pills & Badges
        const Text('Pills & Badges', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        const Wrap(
          spacing: TwoGoSpacing.xs,
          runSpacing: TwoGoSpacing.xs,
          children: [
            TwoGoPill(
              label: 'Aguarde 60 seg',
              variant: TwoGoPillVariant.neutral,
            ),
            TwoGoPill(
              label: 'Reenviar código',
              variant: TwoGoPillVariant.outlined,
            ),
            TwoGoPill(label: 'Ativo', variant: TwoGoPillVariant.active),
            TwoGoBadge(isDot: true),
            TwoGoBadge(count: 3),
            TwoGoBadge(count: 12, variant: TwoGoBadgeVariant.brand),
          ],
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Bottom Navigation Primitive
        const Text('Bottom Navigation', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoBottomNavigation(
          selectedIndex: 0,
          onSelected: (_) {},
          items: const [
            TwoGoBottomNavigationItem(
              icon: Icon(TwoGoIcons.homeOutlined),
              selectedIcon: Icon(TwoGoIcons.home),
              label: 'Início',
            ),
            TwoGoBottomNavigationItem(
              icon: Icon(TwoGoIcons.travelOutlined),
              selectedIcon: Icon(TwoGoIcons.travel),
              label: 'Viagens',
            ),
            TwoGoBottomNavigationItem(
              icon: Icon(TwoGoIcons.notificationsOutlined),
              selectedIcon: Icon(TwoGoIcons.notifications),
              label: 'Notificações',
              badge: TwoGoBadge(count: 2),
            ),
            TwoGoBottomNavigationItem(
              icon: Icon(TwoGoIcons.profileOutlined),
              selectedIcon: Icon(TwoGoIcons.profile),
              label: 'Perfil',
            ),
          ],
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Inline Feedback
        const Text('Inline Feedback', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        const TwoGoInlineFeedback(
          message: 'Verifique o código e tente novamente!',
          variant: TwoGoInlineFeedbackVariant.error,
        ),
        const SizedBox(height: TwoGoSpacing.xs),
        const TwoGoInlineFeedback(
          message: 'Código validado com sucesso!',
          variant: TwoGoInlineFeedbackVariant.success,
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Indicators & Progress
        const Text(
          'Indicators & Progress',
          style: TwoGoTypography.headlineMedium,
        ),
        const SizedBox(height: TwoGoSpacing.sm),
        const TwoGoProgressBar(progress: 0.33),
        const SizedBox(height: TwoGoSpacing.xs),
        const TwoGoProgressBar(progress: 0.66),
        const SizedBox(height: TwoGoSpacing.sm),
        const Row(
          children: [
            TwoGoLoadingIndicator(),
            SizedBox(width: TwoGoSpacing.md),
            Expanded(child: TwoGoSkeleton(height: 24)),
          ],
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        // Counters
        const Text('Counters', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        TwoGoCounter(
          label: 'Adultos',
          subtitle: '18 anos ou mais',
          value: 2,
          onChanged: (_) {},
        ),
      ],
    );
  }
}
