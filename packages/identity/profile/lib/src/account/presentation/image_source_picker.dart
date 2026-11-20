import 'package:image_picker/image_picker.dart';

/// Thin wrapper around [ImagePicker] for profile photo flows.
class ProfileImageSourcePicker {
  ProfileImageSourcePicker({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pick({required bool fromCamera}) async {
    final file = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 92,
    );
    return file?.path;
  }
}
