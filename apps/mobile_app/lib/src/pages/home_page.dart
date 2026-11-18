import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_session/twogo_session.dart';

/// Home route — course layout (guest silhouette / auth photo or initials).
class HomePage extends StatelessWidget {
  const HomePage({required this.homeCubit, super.key});

  final HomeCubit homeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>.value(
      value: homeCubit,
      child: HomeView(
        onCreateItinerary: () => context.go('/planning/wizard'),
        onAccessItineraries: () => context.go('/app/trips'),
        onProfileTap: () {
          final session = context.read<SessionCubit>().state;
          if (session.isAuthenticated) {
            context.go('/app/profile');
          } else {
            context.go('/auth');
          }
        },
      ),
    );
  }
}
