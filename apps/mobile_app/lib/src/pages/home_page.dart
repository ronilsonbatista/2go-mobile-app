import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_session/twogo_session.dart';

/// Guest / empty Home — Figma Checkpoint 1.
/// Authenticated variants (next trip, multi-destination) come in a later block.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final isAuthenticated =
            session.status == SessionStatus.authenticated;
        final greetingName = _greetingName(session);

        return Scaffold(
          backgroundColor: TwoGoColors.backgroundPrimary,
          body: SafeArea(
            child: TwoGoCenteredContent(
              maxWidth: 390,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        TwoGoSpacing.lg,
                        TwoGoSpacing.md,
                        TwoGoSpacing.lg,
                        0,
                      ),
                      child: _HomeHeader(
                        greeting: isAuthenticated
                            ? 'Olá, $greetingName'
                            : 'Olá',
                        showAvatar: true,
                        onAvatarTap: () {
                          if (isAuthenticated) {
                            context.go('/app/profile');
                          } else {
                            context.go('/auth');
                          }
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TwoGoSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: TwoGoSpacing.xl),
                          const _HeroIllustrationSlot(),
                          const SizedBox(height: TwoGoSpacing.xl),
                          _CreateItineraryButton(
                            onPressed: () => context.go('/planning/wizard'),
                          ),
                          const SizedBox(height: TwoGoSpacing.md),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                // Secondary action from Figma — trips tab when available.
                                context.go('/app/trips');
                              },
                              child: Text(
                                'Explorar roteiros',
                                style: TwoGoTypography.labelLarge.copyWith(
                                  color: TwoGoColors.contentPrimary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: TwoGoSpacing.xxl),
                          Text(
                            'Destinos em alta',
                            style: TwoGoTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: TwoGoColors.contentPrimary,
                            ),
                          ),
                          const SizedBox(height: TwoGoSpacing.md),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: TwoGoSpacing.lg,
                        ),
                        children: const [
                          _DestinationChip(
                            label: 'Lisboa',
                            // ASSET_REQUIRED: destination photo from Figma export
                          ),
                          SizedBox(width: TwoGoSpacing.sm),
                          _DestinationChip(
                            label: 'Rio de Janeiro',
                            // ASSET_REQUIRED: destination photo from Figma export
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: TwoGoSpacing.xxl),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _greetingName(SessionState session) {
    final raw = session.userId;
    if (raw == null || raw.isEmpty) return 'viajante';
    if (raw.contains('@')) {
      return raw.split('@').first;
    }
    return raw;
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.showAvatar,
    required this.onAvatarTap,
  });

  final String greeting;
  final bool showAvatar;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            greeting,
            style: TwoGoTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: TwoGoColors.contentPrimary,
            ),
          ),
        ),
        if (showAvatar)
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: TwoGoColors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              // ASSET_REQUIRED: profile avatar photo
              child: const Icon(
                TwoGoIcons.profileOutlined,
                size: 22,
                color: TwoGoColors.contentSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroIllustrationSlot extends StatelessWidget {
  const _HeroIllustrationSlot();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TwoGoColors.surfaceSecondary,
          borderRadius: TwoGoRadius.borderLarge,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(TwoGoSpacing.lg),
            child: Text(
              'ASSET_REQUIRED\nHero illustration (suitcase)',
              textAlign: TextAlign.center,
              style: TwoGoTypography.labelMedium.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma Home CTA is solid black — uses DS neutrals (not brand lime).
class _CreateItineraryButton extends StatelessWidget {
  const _CreateItineraryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: TwoGoSizing.buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: TwoGoColors.neutral900,
          foregroundColor: TwoGoColors.neutral0,
          disabledBackgroundColor: TwoGoColors.actionPrimaryDisabled,
          shape: const RoundedRectangleBorder(
            borderRadius: TwoGoRadius.borderLarge,
          ),
          textStyle: TwoGoTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Criar meu roteiro'),
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: TwoGoColors.surfaceSecondary,
                borderRadius: TwoGoRadius.borderMedium,
              ),
              child: Center(
                child: Text(
                  'ASSET',
                  style: TwoGoTypography.labelSmall.copyWith(
                    color: TwoGoColors.contentDisabled,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            label,
            style: TwoGoTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: TwoGoColors.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
