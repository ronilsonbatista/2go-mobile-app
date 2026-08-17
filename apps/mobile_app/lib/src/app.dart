import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_session/twogo_session.dart';

import 'router/app_router.dart';

class TwoGoApp extends StatefulWidget {
  final String environment;
  final SessionCubit sessionCubit;
  final AuthRepository authRepository;

  const TwoGoApp({
    super.key,
    required this.environment,
    required this.sessionCubit,
    required this.authRepository,
  });

  @override
  State<TwoGoApp> createState() => _TwoGoAppState();
}

class _TwoGoAppState extends State<TwoGoApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(
      sessionCubit: widget.sessionCubit,
      authRepository: widget.authRepository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>.value(
      value: widget.sessionCubit,
      child: MaterialApp.router(
        title: '2GO (${widget.environment})',
        theme: TwoGoTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
