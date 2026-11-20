import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/account_profile_repository.dart';
import 'account_profile_cubit.dart';

/// Provides [AccountProfileCubit] for the profile route subtree.
class ProfileScope extends StatelessWidget {
  const ProfileScope({
    super.key,
    required this.repository,
    required this.child,
    this.fallbackEmail,
  });

  final AccountProfileRepository repository;
  final String? fallbackEmail;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountProfileCubit(
        repository: repository,
        fallbackEmail: fallbackEmail,
      ),
      child: child,
    );
  }
}
