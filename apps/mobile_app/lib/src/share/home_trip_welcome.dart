import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_trips/trips.dart';

/// Loads pending guest welcomes on Home and shows the first-open modal.
class HomeTripWelcomeHost extends StatefulWidget {
  const HomeTripWelcomeHost({
    super.key,
    required this.apiClient,
    required this.child,
    this.enabled = true,
  });

  final TripShareApiClient apiClient;
  final Widget child;
  final bool enabled;

  @override
  State<HomeTripWelcomeHost> createState() => _HomeTripWelcomeHostState();
}

class _HomeTripWelcomeHostState extends State<HomeTripWelcomeHost> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkWelcomes());
    }
  }

  Future<void> _checkWelcomes() async {
    if (_checked || !mounted) return;
    _checked = true;
    try {
      final pending = await widget.apiClient.listPendingWelcomes();
      if (!mounted || pending.isEmpty) return;
      final item = pending.first;
      await TripWelcomeSheet.show(
        context,
        item: item,
        onAccept: () async {
          await widget.apiClient.markWelcomeSeen(item.tripId);
          if (!mounted) return;
          context.go(
            '/app/trips?tripId=${Uri.encodeComponent(item.tripId)}&inviteAccepted=1',
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      if (e is AppFailure) {
        // Soft-fail: Home stays usable if welcome endpoints are not deployed yet.
        if (e is NetworkFailure) {
          TwoGoErrorFeedback.present(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
