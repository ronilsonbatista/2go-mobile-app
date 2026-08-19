import '../models/post_auth_intent.dart';

abstract interface class PostAuthIntentStorage {
  Future<void> saveIntent(PostAuthIntent intent);
  Future<PostAuthIntent?> readIntent();
  Future<void> clearIntent();
}
