import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/saved_card.dart';
import '../../profile_tokens.dart';
import '../account_profile_cubit.dart';
import '../widgets/delete_card_sheet.dart';
import '../widgets/profile_back_button.dart';

/// Cartões salvos + delete confirm. Local/demo list — Core has no cards API.
class SavedCardsPage extends StatelessWidget {
  const SavedCardsPage({super.key, this.onBack});

  final VoidCallback? onBack;

  Future<void> _confirmDelete(BuildContext context, SavedCard card) async {
    final confirmed = await DeleteCardSheet.show(context, card: card);
    if (confirmed == true && context.mounted) {
      context.read<AccountProfileCubit>().removeSavedCard(card.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: profileAppBar(title: 'Cartões salvos', onBack: onBack),
      body: SafeArea(
        child: BlocBuilder<AccountProfileCubit, AccountProfileState>(
          builder: (context, state) {
            final cards = state.savedCards;
            if (cards.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum cartão salvo.',
                  style: TwoGoTypography.bodyLarge.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                ProfileTokens.pageGutter,
                TwoGoSpacing.lg,
                ProfileTokens.pageGutter,
                TwoGoSpacing.lg,
              ),
              itemCount: cards.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: ProfileTokens.cardGap),
              itemBuilder: (context, index) {
                final card = cards[index];
                return _SavedCardTile(
                  card: card,
                  onDelete: () => _confirmDelete(context, card),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({required this.card, required this.onDelete});

  final SavedCard card;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      decoration: BoxDecoration(
        color: TwoGoColors.surfacePrimary,
        borderRadius: BorderRadius.circular(ProfileTokens.cardRadius),
        border: Border.all(color: TwoGoColors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    card.maskedLabel,
                    style: TwoGoTypography.titleMedium.copyWith(
                      color: TwoGoColors.contentSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: TwoGoSpacing.xs),
                _BrandMark(brand: card.brand),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Excluir cartão',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: ProfileTokens.destructiveInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.brand});

  final SavedCardBrand brand;

  @override
  Widget build(BuildContext context) {
    if (brand == SavedCardBrand.visa) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F71),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return SizedBox(
      width: 28,
      height: 18,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 10,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFF79E1B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
