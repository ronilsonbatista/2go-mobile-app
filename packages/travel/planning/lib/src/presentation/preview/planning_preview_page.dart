import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/planning_preview.dart';
import '../../domain/models/preview_cover_resolution.dart';
import 'bloc/planning_preview_bloc.dart';
import 'bloc/planning_preview_event.dart';
import 'bloc/planning_preview_state.dart';
import 'widgets/planning_preview_countdown.dart';
import 'widgets/planning_preview_day_chips.dart';
import 'widgets/planning_preview_upsell_banner.dart';
import 'widgets/planning_timeline_item.dart';
import 'widgets/planning_unlock_sheet.dart';

class PlanningPreviewPage extends StatefulWidget {
  final String journeyId;
  final PlanningPreviewBloc? bloc;
  final void Function(String journeyId, String? productId)? onUnlockRequested;
  final ValueChanged<Uri>? onOpenUrl;
  final VoidCallback? onBack;
  final DateTime Function()? now;

  /// Optional override for hero [Image] (widget tests / offline screenshots).
  final ImageProvider Function(String url)? coverImageProviderBuilder;

  /// When Core summary/dest cover is empty, look up Home/catalog photos.
  final Future<List<PreviewCoverCatalogEntry>> Function()? loadCoverCatalog;

  /// Guest Day-1: open existing Adicionar hospedagem flow (preview-only save).
  final VoidCallback? onAddLodging;

  /// Guest Day-1: open existing Detalhes for an activity / check-in point.
  final ValueChanged<PlanningVisibleActivity>? onActivityTap;

  /// Unlocks Share in the hero header (Edit/PDF stay blocked).
  final VoidCallback? onShare;

  const PlanningPreviewPage({
    super.key,
    required this.journeyId,
    this.bloc,
    this.onUnlockRequested,
    this.onOpenUrl,
    this.onBack,
    this.now,
    this.coverImageProviderBuilder,
    this.loadCoverCatalog,
    this.onAddLodging,
    this.onActivityTap,
    this.onShare,
  });

  @override
  State<PlanningPreviewPage> createState() => _PlanningPreviewPageState();
}

class _PlanningPreviewPageState extends State<PlanningPreviewPage> {
  late final PlanningPreviewBloc _bloc;
  bool _dialogVisible = false;
  ImageProvider? _resolvedHeroImage;
  String? _heroResolutionKey;

  @override
  void initState() {
    super.initState();
    if (widget.bloc != null) {
      _bloc = widget.bloc!;
    } else {
      throw UnimplementedError(
        'PlanningPreviewBloc deve ser injetado via construtor ou BlocProvider',
      );
    }

    _bloc.add(FetchPlanningPreviewEvent(journeyId: widget.journeyId));
  }

  Future<void> _showPaywallDialog(
    BuildContext context,
    PlanningPreviewLoadedState state,
  ) async {
    if (_dialogVisible) return;
    _dialogVisible = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (dialogContext) => PlanningUnlockSheet(
          offer: state.preview.unlockOffer,
          onUnlockRequested: () {
            Navigator.of(dialogContext).pop();
            _bloc.add(const RequestUnlockEvent());
          },
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            _bloc.add(const DismissPaywallEvent());
          },
        ),
      );
    } finally {
      _dialogVisible = false;
      if (mounted) {
        _bloc.add(const DismissPaywallEvent());
      }
    }
  }

  void _openMapForDay(PlanningVisibleDay? day) {
    if (day == null || widget.onOpenUrl == null) return;
    PlanningVisibleActivity? withCoords;
    for (final a in day.activities) {
      if (a.latitude != null && a.longitude != null) {
        withCoords = a;
        break;
      }
    }
    final link = PlanningTimelineItem.mapUrl(
      latitude: withCoords?.latitude,
      longitude: withCoords?.longitude,
    );
    final uri = link == null ? null : Uri.tryParse(link);
    if (uri != null) widget.onOpenUrl!(uri);
  }

  String _destinationName(PlanningPreviewSummary summary) {
    if (summary.destinations.isNotEmpty && summary.destinations[0] is Map) {
      return (summary.destinations[0] as Map)['name']?.toString() ??
          'Sua Viagem';
    }
    return 'Sua Viagem';
  }

  Future<void> _resolveHeroCover(PlanningPreviewSummary summary) async {
    final key =
        '${summary.coverImageUrl}|${summary.destinations}|${summary.totalDays}';
    if (_heroResolutionKey == key && _resolvedHeroImage != null) return;
    _heroResolutionKey = key;

    List<PreviewCoverCatalogEntry> catalog = const [];
    final loader = widget.loadCoverCatalog;
    if (loader != null) {
      try {
        catalog = await loader();
      } catch (_) {
        catalog = const [];
      }
    }

    final resolution = resolvePreviewCover(
      summary: summary,
      catalog: catalog,
    );
    if (!mounted) return;

    ImageProvider? provider;
    final url = resolution?.networkUrl?.trim();
    if (url != null && url.isNotEmpty) {
      provider = widget.coverImageProviderBuilder?.call(url) ??
          NetworkImage(url);
    } else {
      provider = resolution?.toImageProvider();
    }

    if (!mounted) return;
    setState(() => _resolvedHeroImage = provider);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PlanningPreviewBloc, PlanningPreviewState>(
        listener: (context, state) {
          if (state is PlanningPreviewLoadedState) {
            _resolveHeroCover(state.preview.summary);
            if (state.isPaywallOpen) {
              _showPaywallDialog(context, state);
            }
          } else if (state is PlanningPreviewUnlockRequestedState) {
            widget.onUnlockRequested?.call(state.journeyId, state.productId);
          }
        },
        builder: (context, state) {
          if (state is PlanningPreviewLoadingState ||
              state is PlanningPreviewInitialState) {
            return const Scaffold(
              backgroundColor: TwoGoColors.backgroundPrimary,
              body: Center(child: TwoGoLoadingIndicator()),
            );
          }

          if (state is PlanningPreviewErrorState) {
            return Scaffold(
              backgroundColor: TwoGoColors.backgroundPrimary,
              body: TwoGoCenteredContent(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: TwoGoColors.error,
                    ),
                    const SizedBox(height: TwoGoSpacing.md),
                    TwoGoStatusMessage(
                      title: 'Erro ao carregar preview',
                      description:
                          'Não foi possível carregar as informações do seu roteiro.',
                    ),
                    const SizedBox(height: TwoGoSpacing.lg),
                    TwoGoButton(
                      text: 'Tentar Novamente',
                      onPressed: () {
                        _bloc.add(
                          FetchPlanningPreviewEvent(
                            journeyId: widget.journeyId,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PlanningPreviewLoadedState) {
            return _buildLoaded(context, state);
          }

          return const Scaffold(
            backgroundColor: TwoGoColors.backgroundPrimary,
            body: SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PlanningPreviewLoadedState state) {
    final preview = state.preview;
    final summary = preview.summary;
    final selectedDay = state.selectedDayNumber;
    final destinationName = _destinationName(summary);

    final visibleDayMatch = preview.visibleDays
        .cast<PlanningVisibleDay?>()
        .firstWhere((d) => d?.dayNumber == selectedDay, orElse: () => null);

    final lockedDayMatch = preview.lockedDays
        .cast<PlanningLockedDay?>()
        .firstWhere((d) => d?.dayNumber == selectedDay, orElse: () => null);

    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeader(
                  coverImage: _resolvedHeroImage,
                  coverImageUrl: summary.resolvedCoverImageUrl,
                  destinationName: destinationName,
                  onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  coverImageProviderBuilder: widget.coverImageProviderBuilder,
                  onShare: widget.onShare,
                ),
              ),
              // Gutters vs design: keep readable breathing room (not sparse).
              // h-margin 16; hero→countdown 12; countdown→upsell 12;
              // upsell→chips 16; chips→timeline 12.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TwoGoSpacing.md,
                    TwoGoSpacing.sm,
                    TwoGoSpacing.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlanningPreviewCountdown(
                        startDate: summary.startDate,
                        now: widget.now,
                      ),
                      const SizedBox(height: TwoGoSpacing.sm),
                      PlanningPreviewUpsellBanner(
                        offer: preview.unlockOffer,
                        onTap: () {
                          _bloc.add(const OpenPaywallEvent(source: 'BANNER'));
                        },
                      ),
                      const SizedBox(height: TwoGoSpacing.md),
                      PlanningPreviewDayChips(
                        preview: preview,
                        selectedDayNumber: selectedDay,
                        onSelectDay: (day) {
                          _bloc.add(SelectPreviewDayEvent(dayNumber: day));
                        },
                      ),
                      const SizedBox(height: TwoGoSpacing.sm),
                      if (visibleDayMatch != null)
                        _buildTimelineList(visibleDayMatch)
                      else
                        _buildLockedDayCard(lockedDayMatch),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Center(
              child: _MapFab(
                onPressed: () {
                  if (visibleDayMatch != null) {
                    _openMapForDay(visibleDayMatch);
                  } else {
                    _bloc.add(const OpenPaywallEvent(source: 'MAP'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(PlanningVisibleDay day) {
    final activities = [...day.activities]
      ..sort((a, b) => a.order.compareTo(b.order));

    final children = <Widget>[
      PlanningLodgingTimelineItem(
        onTap: widget.onAddLodging ??
            () {
              _bloc.add(const OpenPaywallEvent(source: 'LODGING'));
            },
      ),
    ];

    for (var i = 0; i < activities.length; i++) {
      final activity = activities[i];
      final isLast = i == activities.length - 1;
      children.add(
        PlanningTimelineItem(
          activity: activity,
          isLast: isLast && activity.isTransport,
          nodeStyle: activity.isMeal
              ? PlanningTimelineNodeStyle.solid
              : PlanningTimelineNodeStyle.solid,
          onOpenUrl: widget.onOpenUrl,
          onTap: activity.isTransport || activity.isMeal
              ? null
              : () {
                  final open = widget.onActivityTap;
                  if (open != null) {
                    open(activity);
                  } else {
                    _bloc.add(const OpenPaywallEvent(source: 'ACTIVITY'));
                  }
                },
          onRecommendationsTap: () {
            _bloc.add(const OpenPaywallEvent(source: 'MEAL_RECS'));
          },
          onMenuTap: () {
            _bloc.add(const OpenPaywallEvent(source: 'ITEM_MENU'));
          },
        ),
      );

      if (!activity.isTransport && i < activities.length - 1) {
        final next = activities[i + 1];
        if (!next.isTransport) {
          final transit = PlanningTimelineItem.transitBetween(activity, next);
          if (transit != null) {
            children.add(PlanningTransitLabel(label: transit));
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildLockedDayCard(PlanningLockedDay? lockedDay) {
    final title = lockedDay?.title ?? 'Dia Bloqueado';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: TwoGoColors.neutral900,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: TwoGoColors.brandLime,
              size: 32,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.md),
          Text(
            title,
            style: TwoGoTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.neutral900,
            ),
          ),
          if (lockedDay?.date != null && lockedDay!.date!.trim().isNotEmpty) ...[
            const SizedBox(height: TwoGoSpacing.xs),
            Text(
              PlanningPreviewDayChips.formatDayChipLabel(
                lockedDay.date,
                lockedDay.dayNumber,
              ),
              style: TwoGoTypography.bodySmall.copyWith(
                color: TwoGoColors.neutral600,
              ),
            ),
          ],
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            'Desbloqueie o acesso completo para visualizar as atividades deste dia.',
            textAlign: TextAlign.center,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.neutral700,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
          TwoGoButton(
            text: 'Aproveitar',
            onPressed: () {
              _bloc.add(const OpenPaywallEvent(source: 'LOCKED_DAY'));
            },
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.destinationName,
    required this.onBack,
    this.coverImage,
    this.coverImageUrl,
    this.coverImageProviderBuilder,
    this.onShare,
  });

  final ImageProvider? coverImage;
  final String? coverImageUrl;
  final String destinationName;
  final VoidCallback onBack;
  final ImageProvider Function(String url)? coverImageProviderBuilder;
  final VoidCallback? onShare;

  ImageProvider? get _image {
    if (coverImage != null) return coverImage;
    final url = coverImageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return coverImageProviderBuilder?.call(url) ?? NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final image = _image;
    // Design hero content ~182–220pt below status.
    return SizedBox(
      height: 220 + topPad,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackBg(),
            )
          else
            _fallbackBg(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0x99000000),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: topPad + TwoGoSpacing.xs,
            left: TwoGoSpacing.sm,
            right: TwoGoSpacing.sm,
            child: Row(
              children: [
                _RoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: onBack,
                ),
                const Spacer(),
                // Edit / PDF stay blocked; Share unlocks when [onShare] is set.
                const _RoundIconButton(
                  icon: Icons.edit_outlined,
                  iconColor: Color(0xFFF5C518),
                  enabled: false,
                ),
                const SizedBox(width: TwoGoSpacing.xs),
                const _RoundIconButton(
                  icon: Icons.picture_as_pdf_outlined,
                  iconColor: Color(0xFFE53935),
                  enabled: false,
                ),
                const SizedBox(width: TwoGoSpacing.xs),
                _RoundIconButton(
                  icon: Icons.ios_share_rounded,
                  enabled: onShare != null,
                  onPressed: onShare,
                ),
              ],
            ),
          ),
          Positioned(
            left: TwoGoSpacing.md,
            bottom: TwoGoSpacing.md,
            right: TwoGoSpacing.md,
            child: Text(
              destinationName,
              style: TwoGoTypography.headlineLarge.copyWith(
                color: TwoGoColors.contentInverse,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackBg() {
    return const ColoredBox(
      color: TwoGoColors.neutral800,
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          size: 64,
          color: TwoGoColors.neutral500,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = (iconColor ?? TwoGoColors.neutral900)
        .withValues(alpha: enabled ? 1 : 0.38);
    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: Material(
        color: TwoGoColors.neutral0.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwoGoColors.neutral900,
      borderRadius: BorderRadius.circular(999),
      elevation: 6,
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 18,
                color: TwoGoColors.contentInverse,
              ),
              const SizedBox(width: 8),
              Text(
                'Mapa',
                style: TwoGoTypography.labelLarge.copyWith(
                  color: TwoGoColors.contentInverse,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
