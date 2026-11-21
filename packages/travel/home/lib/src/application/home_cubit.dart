import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/models/home_crm_snapshot.dart';
import '../domain/models/home_destination.dart';
import '../domain/models/home_profile.dart';
import '../domain/repositories/home_content_repository.dart';

enum HomeStatus { initial, loading, ready, failure }

/// Which Home shell to show.
enum HomeShellMode {
  /// Guest / no owned upcoming trip — hero + Destinos em alta (Home-9/10/11).
  discovery,

  /// Authenticated CRM — próxima viagem / empty suitcase (Home-1…8).
  crm,
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.destinations = const [],
    this.heroIndex = 0,
    this.profile = const HomeProfile(isAuthenticated: false),
    this.crm = HomeCrmSnapshot.empty,
    this.errorMessage,
  });

  final HomeStatus status;
  final List<HomeDestination> destinations;
  final int heroIndex;
  final HomeProfile profile;
  final HomeCrmSnapshot crm;
  final String? errorMessage;

  HomeDestination? get currentDestination {
    if (destinations.isEmpty) return null;
    final index = heroIndex.clamp(0, destinations.length - 1);
    return destinations[index];
  }

  /// Paid-trip CRM only when Core returns `GET /home/trip` → `trip != null`.
  /// Guests and auth users without a paid trip stay on discovery Home.
  HomeShellMode get shellMode {
    if (crm.hasPaidTrip) return HomeShellMode.crm;
    return HomeShellMode.discovery;
  }

  HomeState copyWith({
    HomeStatus? status,
    List<HomeDestination>? destinations,
    int? heroIndex,
    HomeProfile? profile,
    HomeCrmSnapshot? crm,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      destinations: destinations ?? this.destinations,
      heroIndex: heroIndex ?? this.heroIndex,
      profile: profile ?? this.profile,
      crm: crm ?? this.crm,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        destinations,
        heroIndex,
        profile,
        crm,
        errorMessage,
      ];
}

/// View-model for Home layout: guest/auth chip + destination carousel + CRM.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required HomeContentRepository repository,
    this.autoAdvance = true,
    this.autoAdvanceInterval = const Duration(seconds: 5),
  }) : _repository = repository,
       super(const HomeState());

  final HomeContentRepository _repository;
  final bool autoAdvance;
  final Duration autoAdvanceInterval;
  Timer? _timer;

  Future<void> load({
    required bool isAuthenticated,
    String? userId,
  }) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    try {
      final destinations = await _repository.fetchDestinations();
      final profile = await _repository.resolveProfile(
        isAuthenticated: isAuthenticated,
        userId: userId,
      );
      final crm = await _repository.fetchCrmSnapshot(
        isAuthenticated: isAuthenticated,
        userId: userId,
      );
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          destinations: destinations,
          heroIndex: destinations.isEmpty
              ? 0
              : state.heroIndex.clamp(0, destinations.length - 1),
          profile: profile,
          crm: crm,
        ),
      );
      _restartAutoAdvance();
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      _timer?.cancel();
    }
  }

  void setHeroIndex(int index) {
    if (state.destinations.isEmpty) return;
    final next = index % state.destinations.length;
    final normalized = next < 0 ? next + state.destinations.length : next;
    if (normalized == state.heroIndex) return;
    emit(state.copyWith(heroIndex: normalized));
    _restartAutoAdvance();
  }

  void nextHero() {
    if (state.destinations.isEmpty) return;
    setHeroIndex(state.heroIndex + 1);
  }

  void previousHero() {
    if (state.destinations.isEmpty) return;
    setHeroIndex(state.heroIndex - 1);
  }

  void selectDestination(String id) {
    final index = state.destinations.indexWhere((d) => d.id == id);
    if (index >= 0) {
      setHeroIndex(index);
    }
  }

  /// Patches Home greeting/avatar after Dados pessoais / avatar save.
  ///
  /// Core has no PATCH `/users/me` for name — local AccountProfile is source
  /// of truth until the next successful [refreshProfile] from GET `/users/me`
  /// (avatar upload does update Core `photoUrl`).
  void applyProfileLocally({
    String? displayName,
    String? photoUrl,
    bool clearPhotoUrl = false,
  }) {
    if (!state.profile.isAuthenticated) return;
    final nextName = displayName?.trim();
    emit(
      state.copyWith(
        profile: HomeProfile.authenticated(
          displayName: (nextName != null && nextName.isNotEmpty)
              ? nextName
              : state.profile.displayName,
          photoUrl: clearPhotoUrl
              ? null
              : (photoUrl ?? state.profile.photoUrl),
          photoAssetPath: state.profile.photoAssetPath,
        ),
      ),
    );
  }

  /// Re-fetches `GET /users/me` into Home (keeps destinations/CRM).
  Future<void> refreshProfile({
    required bool isAuthenticated,
    String? userId,
  }) async {
    if (!isAuthenticated) {
      emit(state.copyWith(profile: HomeProfile.guest()));
      return;
    }
    try {
      final profile = await _repository.resolveProfile(
        isAuthenticated: true,
        userId: userId,
      );
      if (isClosed) return;
      emit(state.copyWith(profile: profile));
    } catch (_) {
      // Soft-fail — keep existing greeting/avatar.
    }
  }

  void _restartAutoAdvance() {
    _timer?.cancel();
    if (!autoAdvance || state.destinations.length < 2) return;
    if (state.shellMode == HomeShellMode.crm) return;
    _timer = Timer.periodic(autoAdvanceInterval, (_) {
      if (isClosed) return;
      nextHero();
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
