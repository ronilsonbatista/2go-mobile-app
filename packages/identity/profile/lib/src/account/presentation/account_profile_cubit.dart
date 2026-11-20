import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_core/twogo_core.dart';

import '../domain/account_profile.dart';
import '../domain/account_profile_repository.dart';
import '../domain/saved_card.dart';

enum AccountProfileStatus { initial, loading, ready, saving, error }

class AccountProfileState {
  const AccountProfileState({
    required this.status,
    this.profile = const AccountProfile(id: '', email: ''),
    this.savedCards = SavedCard.designDemos,
    this.errorMessage,
    this.failure,
  });

  factory AccountProfileState.initial() => const AccountProfileState(
        status: AccountProfileStatus.initial,
      );

  final AccountProfileStatus status;
  final AccountProfile profile;
  final List<SavedCard> savedCards;
  final String? errorMessage;
  final AppFailure? failure;

  bool get isLoading =>
      status == AccountProfileStatus.loading ||
      status == AccountProfileStatus.saving;

  AccountProfileState copyWith({
    AccountProfileStatus? status,
    AccountProfile? profile,
    List<SavedCard>? savedCards,
    String? errorMessage,
    AppFailure? failure,
    bool clearError = false,
  }) {
    return AccountProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      savedCards: savedCards ?? this.savedCards,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      failure: clearError ? null : (failure ?? this.failure),
    );
  }
}

class AccountProfileCubit extends Cubit<AccountProfileState> {
  AccountProfileCubit({
    required AccountProfileRepository repository,
    this.fallbackEmail,
  })  : _repository = repository,
        super(AccountProfileState.initial());

  final AccountProfileRepository _repository;
  final String? fallbackEmail;

  Future<void> load() async {
    emit(state.copyWith(
      status: AccountProfileStatus.loading,
      clearError: true,
    ));
    try {
      final profile = await _repository.fetchMe(fallbackEmail: fallbackEmail);
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          profile: profile.copyWith(
            phone: state.profile.phone,
            cpf: state.profile.cpf,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      final failure = e is AppFailure ? e : null;
      emit(
        state.copyWith(
          status: AccountProfileStatus.error,
          errorMessage: failure?.message ?? e.toString(),
          failure: failure,
        ),
      );
    }
  }

  /// Local-only personal data fields (Core has no PATCH /users/me).
  void applyPersonalDataLocally({
    required String displayName,
    String? phone,
    String? cpf,
  }) {
    emit(
      state.copyWith(
        status: AccountProfileStatus.ready,
        profile: state.profile.copyWith(
          displayName: displayName.trim(),
          phone: phone?.trim(),
          cpf: cpf?.trim(),
        ),
      ),
    );
  }

  /// Optimistic local clear — Core has no delete-avatar endpoint.
  void clearPhotoLocally() {
    emit(
      state.copyWith(
        profile: state.profile.copyWith(clearPhotoUrl: true),
      ),
    );
  }

  Future<bool> uploadAvatarBytes({
    required List<int> bytes,
    required String filename,
    String? contentType,
  }) async {
    emit(state.copyWith(
      status: AccountProfileStatus.saving,
      clearError: true,
    ));
    try {
      final url = await _repository.uploadAvatar(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          profile: state.profile.copyWith(photoUrl: url),
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      final failure = e is AppFailure ? e : null;
      emit(
        state.copyWith(
          status: AccountProfileStatus.ready,
          errorMessage: failure?.message ?? e.toString(),
          failure: failure,
        ),
      );
      return false;
    }
  }

  void removeSavedCard(String cardId) {
    emit(
      state.copyWith(
        savedCards:
            state.savedCards.where((c) => c.id != cardId).toList(growable: false),
      ),
    );
  }
}
