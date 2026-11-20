import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_profile/profile.dart';

void main() {
  group('AccountProfileCubit', () {
    test('load fetches Core profile via repository', () async {
      final repo = LocalAccountProfileRepository(
        seed: const AccountProfile(
          id: 'usr_1',
          email: 'gustavo.gv@gmail.com',
          displayName: 'Gustavo Vieira',
          photoUrl: 'https://cdn.example/g.jpg',
        ),
      );
      final cubit = AccountProfileCubit(repository: repo);

      await cubit.load();

      expect(cubit.state.status, AccountProfileStatus.ready);
      expect(cubit.state.profile.displayName, 'Gustavo Vieira');
      expect(cubit.state.profile.hasPhoto, isTrue);
      expect(cubit.state.errorMessage, isNull);
      await cubit.close();
    });

    test('load preserves local phone/cpf across Core refresh', () async {
      final repo = LocalAccountProfileRepository(
        seed: const AccountProfile(
          id: 'usr_1',
          email: 'a@b.com',
          displayName: 'Ana',
        ),
      );
      final cubit = AccountProfileCubit(repository: repo);
      cubit.applyPersonalDataLocally(
        displayName: 'Ana',
        phone: '11999990000',
        cpf: '12345678901',
      );

      await cubit.load();

      expect(cubit.state.profile.phone, '11999990000');
      expect(cubit.state.profile.cpf, '12345678901');
      expect(cubit.state.profile.email, 'a@b.com');
      await cubit.close();
    });

    test('uploadAvatarBytes updates photoUrl from repository', () async {
      final repo = LocalAccountProfileRepository(
        seed: const AccountProfile(id: 'usr_1', email: 'a@b.com'),
      );
      final cubit = AccountProfileCubit(repository: repo);

      final ok = await cubit.uploadAvatarBytes(
        bytes: [1, 2, 3],
        filename: 'avatar.jpg',
        contentType: 'image/jpeg',
      );

      expect(ok, isTrue);
      expect(cubit.state.status, AccountProfileStatus.ready);
      expect(cubit.state.profile.photoUrl, 'local://avatar/avatar.jpg');
      await cubit.close();
    });

    test('uploadAvatarBytes keeps ready status and failure on error', () async {
      final cubit = AccountProfileCubit(repository: _FailingAvatarRepository());

      final ok = await cubit.uploadAvatarBytes(
        bytes: [1],
        filename: 'avatar.jpg',
      );

      expect(ok, isFalse);
      expect(cubit.state.status, AccountProfileStatus.ready);
      expect(cubit.state.failure, isA<NetworkFailure>());
      expect(cubit.state.errorMessage, isNotNull);
      await cubit.close();
    });

    test('clearPhotoLocally clears photo without Core delete', () async {
      final repo = LocalAccountProfileRepository(
        seed: const AccountProfile(
          id: 'usr_1',
          email: 'a@b.com',
          photoUrl: 'https://cdn.example/a.jpg',
        ),
      );
      final cubit = AccountProfileCubit(repository: repo);
      await cubit.load();

      cubit.clearPhotoLocally();

      expect(cubit.state.profile.hasPhoto, isFalse);
      expect(cubit.state.profile.photoUrl, isNull);
      await cubit.close();
    });

    test('removeSavedCard updates local demo list only', () async {
      final cubit = AccountProfileCubit(
        repository: LocalAccountProfileRepository(),
      );
      final initialCount = cubit.state.savedCards.length;
      expect(initialCount, greaterThan(0));

      cubit.removeSavedCard(cubit.state.savedCards.first.id);

      expect(cubit.state.savedCards, hasLength(initialCount - 1));
      await cubit.close();
    });
  });
}

class _FailingAvatarRepository implements AccountProfileRepository {
  @override
  Future<AccountProfile> fetchMe({String? fallbackEmail}) async {
    return const AccountProfile(id: 'usr', email: 'a@b.com');
  }

  @override
  Future<String> uploadAvatar({
    required List<int> bytes,
    required String filename,
    String? contentType,
  }) {
    return Future.error(const NetworkFailure());
  }
}
