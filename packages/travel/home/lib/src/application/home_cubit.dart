import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/models/home_destination.dart';
import '../domain/models/home_profile.dart';
import '../domain/repositories/home_content_repository.dart';

enum HomeStatus { initial, loading, ready, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.destinations = const [],
    this.heroIndex = 0,
    this.profile = const HomeProfile(isAuthenticated: false),
    this.errorMessage,
  });

  final HomeStatus status;
  final List<HomeDestination> destinations;
  final int heroIndex;
  final HomeProfile profile;
  final String? errorMessage;

  HomeDestination? get currentDestination {
    if (destinations.isEmpty) return null;
    final index = heroIndex.clamp(0, destinations.length - 1);
    return destinations[index];
  }

  HomeState copyWith({
    HomeStatus? status,
    List<HomeDestination>? destinations,
    int? heroIndex,
    HomeProfile? profile,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      destinations: destinations ?? this.destinations,
      heroIndex: heroIndex ?? this.heroIndex,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    destinations,
    heroIndex,
    profile,
    errorMessage,
  ];
}

/// View-model for Home layout: guest/auth chip + destination carousel.
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
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          destinations: destinations,
          heroIndex: destinations.isEmpty
              ? 0
              : state.heroIndex.clamp(0, destinations.length - 1),
          profile: profile,
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

  void _restartAutoAdvance() {
    _timer?.cancel();
    if (!autoAdvance || state.destinations.length < 2) return;
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
