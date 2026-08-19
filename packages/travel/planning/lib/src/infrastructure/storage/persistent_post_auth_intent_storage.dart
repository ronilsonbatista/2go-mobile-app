import 'dart:convert';
import 'package:twogo_storage/twogo_storage.dart';
import '../../domain/models/post_auth_intent.dart';
import '../../domain/repositories/post_auth_intent_storage.dart';

class PersistentPostAuthIntentStorage implements PostAuthIntentStorage {
  final TwoGoStorage _storage;
  static const String _intentKey = 'twogo_post_auth_intent';

  PersistentPostAuthIntentStorage({TwoGoStorage? storage})
    : _storage = storage ?? TwoGoStorage();

  @override
  Future<void> saveIntent(PostAuthIntent intent) async {
    if (intent.type == PostAuthIntentType.normalLogin) {
      await clearIntent();
      return;
    }
    final jsonStr = jsonEncode(intent.toJson());
    await _storage.setString(_intentKey, jsonStr);
  }

  @override
  Future<PostAuthIntent?> readIntent() async {
    final str = await _storage.getString(_intentKey);
    if (str == null || str.isEmpty) return null;
    try {
      final jsonMap = jsonDecode(str) as Map<String, dynamic>;
      return PostAuthIntent.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearIntent() async {
    await _storage.remove(_intentKey);
  }
}

class InMemoryPostAuthIntentStorage implements PostAuthIntentStorage {
  PostAuthIntent? _intent;

  @override
  Future<void> saveIntent(PostAuthIntent intent) async {
    if (intent.type == PostAuthIntentType.normalLogin) {
      _intent = null;
    } else {
      _intent = intent;
    }
  }

  @override
  Future<PostAuthIntent?> readIntent() async {
    return _intent;
  }

  @override
  Future<void> clearIntent() async {
    _intent = null;
  }
}
