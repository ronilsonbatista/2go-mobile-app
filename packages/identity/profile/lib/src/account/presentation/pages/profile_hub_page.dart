import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../profile_tokens.dart';
import '../account_profile_cubit.dart';
import '../widgets/photo_action_sheet.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_back_button.dart';

typedef ProfilePhotoPick = Future<String?> Function({required bool fromCamera});

/// Seu perfil — hub matching design prints.
class ProfileHubPage extends StatefulWidget {
  const ProfileHubPage({
    super.key,
    required this.onBack,
    required this.onPersonalData,
    required this.onSavedCards,
    required this.onExpiredItineraries,
    required this.onCropPhoto,
    this.onHelp,
    this.pickImage,
  });

  final VoidCallback onBack;
  final VoidCallback onPersonalData;
  final VoidCallback onSavedCards;
  final VoidCallback onExpiredItineraries;
  final ValueChanged<String> onCropPhoto;
  final VoidCallback? onHelp;
  final ProfilePhotoPick? pickImage;

  @override
  State<ProfileHubPage> createState() => _ProfileHubPageState();
}

class _ProfileHubPageState extends State<ProfileHubPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountProfileCubit>().load();
  }

  Future<void> _onCameraTap() async {
    final cubit = context.read<AccountProfileCubit>();
    final hasPhoto = cubit.state.profile.hasPhoto;
    final action = await PhotoActionSheet.show(context, hasPhoto: hasPhoto);
    if (!mounted || action == null || action == PhotoSheetAction.cancel) {
      return;
    }

    switch (action) {
      case PhotoSheetAction.removePhoto:
        cubit.clearPhotoLocally();
        return;
      case PhotoSheetAction.editCrop:
        final url = cubit.state.profile.photoUrl;
        if (url != null && url.isNotEmpty) {
          widget.onCropPhoto(url);
        }
        return;
      case PhotoSheetAction.takePhoto:
      case PhotoSheetAction.takeNewPhoto:
        await _pickAndCrop(fromCamera: true);
        return;
      case PhotoSheetAction.pickGallery:
      case PhotoSheetAction.pickAnotherGallery:
        await _pickAndCrop(fromCamera: false);
        return;
      case PhotoSheetAction.cancel:
        return;
    }
  }

  Future<void> _pickAndCrop({required bool fromCamera}) async {
    final pick = widget.pickImage;
    if (pick == null) {
      TwoGoSnackbar.show(
        context,
        message: 'Seletor de imagem indisponível neste build.',
        variant: TwoGoSnackbarVariant.error,
      );
      return;
    }
    final path = await pick(fromCamera: fromCamera);
    if (!mounted || path == null || path.isEmpty) return;
    widget.onCropPhoto(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: profileAppBar(title: 'Seu perfil', onBack: widget.onBack),
      body: BlocConsumer<AccountProfileCubit, AccountProfileState>(
        listenWhen: (a, b) => a.failure != b.failure && b.failure != null,
        listener: (context, state) {
          final failure = state.failure;
          if (failure != null) {
            TwoGoErrorFeedback.present(context, failure);
          }
        },
        builder: (context, state) {
          if (state.status == AccountProfileStatus.loading &&
              state.profile.email.isEmpty &&
              (state.profile.displayName == null ||
                  state.profile.displayName!.isEmpty)) {
            return const Center(child: TwoGoLoadingIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ProfileTokens.pageGutter,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: ProfileTokens.headerToAvatarGap),
                        ProfileAvatar(
                          profile: state.profile,
                          onCameraTap: _onCameraTap,
                        ),
                        const SizedBox(height: ProfileTokens.avatarToMenuGap),
                        _MenuCard(
                          onPersonalData: widget.onPersonalData,
                          onSavedCards: widget.onSavedCards,
                          onExpiredItineraries: widget.onExpiredItineraries,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: TwoGoSpacing.lg),
                  child: TextButton(
                    onPressed: widget.onHelp,
                    child: Text(
                      'Precisa de ajuda?',
                      style: TwoGoTypography.titleMedium.copyWith(
                        color: TwoGoColors.contentPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.onPersonalData,
    required this.onSavedCards,
    required this.onExpiredItineraries,
  });

  final VoidCallback onPersonalData;
  final VoidCallback onSavedCards;
  final VoidCallback onExpiredItineraries;

  @override
  Widget build(BuildContext context) {
    final items = <(String, VoidCallback)>[
      ('Dados pessoais', onPersonalData),
      ('Cartões salvos', onSavedCards),
      ('Roteiros expirados', onExpiredItineraries),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ProfileTokens.menuSurface,
        borderRadius: BorderRadius.circular(ProfileTokens.menuRadius),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: TwoGoColors.neutral0,
              ),
            InkWell(
              onTap: items[i].$2,
              borderRadius: i == 0
                  ? const BorderRadius.vertical(
                      top: Radius.circular(ProfileTokens.menuRadius),
                    )
                  : i == items.length - 1
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(ProfileTokens.menuRadius),
                        )
                      : BorderRadius.zero,
              child: SizedBox(
                height: ProfileTokens.menuItemHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TwoGoSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          items[i].$1,
                          style: TwoGoTypography.titleMedium.copyWith(
                            color: TwoGoColors.contentPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: TwoGoColors.contentPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
