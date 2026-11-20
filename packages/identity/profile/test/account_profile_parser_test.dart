import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_profile/profile.dart';

void main() {
  const parser = AccountProfileParser();

  test('parses nested user from /users/me payload', () {
    final profile = parser.parse({
      'message': 'Acesso liberado!',
      'user': {
        'userId': 'usr_1',
        'id': 'usr_1',
        'email': 'gustavo.gv@gmail.com',
        'displayName': 'Gustavo Vieira',
        'photoUrl': null,
      },
    });

    expect(profile.id, 'usr_1');
    expect(profile.email, 'gustavo.gv@gmail.com');
    expect(profile.displayName, 'Gustavo Vieira');
    expect(profile.hasPhoto, isFalse);
    expect(profile.initials, 'GV');
  });

  test('reads photoUrl when present', () {
    final profile = parser.parse({
      'user': {
        'id': 'usr_2',
        'email': 'a@b.com',
        'displayName': 'Ana',
        'photoUrl': 'https://cdn.example/ana.jpg',
      },
    });

    expect(profile.hasPhoto, isTrue);
    expect(profile.photoUrl, 'https://cdn.example/ana.jpg');
  });

  test('unwraps data envelope', () {
    final profile = parser.parse({
      'success': true,
      'data': {
        'user': {
          'id': 'usr_3',
          'fullName': 'Maria Silva',
          'email': 'm@2go.app',
          'photoUrl': '   ',
        },
      },
    });

    expect(profile.displayName, 'Maria Silva');
    expect(profile.hasPhoto, isFalse);
    expect(profile.initials, 'MS');
  });

  test('prefers displayName over fullName (Core GET /users/me shape)', () {
    final profile = parser.parse({
      'user': {
        'userId': 'usr_4',
        'email': 'x@2go.app',
        'displayName': 'Nome Exibido',
        'fullName': 'Nome Completo Ignorado',
        'photoUrl': null,
      },
    });

    expect(profile.id, 'usr_4');
    expect(profile.displayName, 'Nome Exibido');
  });

  test('falls back to userId and fallbackEmail', () {
    final profile = parser.parse(
      {
        'user': {
          'userId': 'only-user-id',
          'displayName': null,
          'photoUrl': null,
        },
      },
      fallbackEmail: 'fallback@2go.app',
    );

    expect(profile.id, 'only-user-id');
    expect(profile.email, 'fallback@2go.app');
    expect(profile.hasPhoto, isFalse);
  });
}
