import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_profile/profile.dart';

/// Hub entry for `/app/profile` (cubit provided by [ProfileScope] shell).
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.imagePicker,
  });

  final ProfileImageSourcePicker? imagePicker;

  @override
  Widget build(BuildContext context) {
    final picker = imagePicker ?? ProfileImageSourcePicker();

    return ProfileHubPage(
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/app/home');
        }
      },
      onPersonalData: () => context.push('/app/profile/personal-data'),
      onSavedCards: () => context.push('/app/profile/saved-cards'),
      onExpiredItineraries: () =>
          context.push('/app/profile/expired-itineraries'),
      onCropPhoto: (path) => context.push(
        '/app/profile/change-photo',
        extra: path,
      ),
      pickImage: ({required bool fromCamera}) =>
          picker.pick(fromCamera: fromCamera),
      onHelp: () {
        TwoGoSnackbar.show(
          context,
          message: 'Em breve: suporte no app.',
        );
      },
    );
  }
}
