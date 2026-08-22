import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_trips/trips.dart';
import '../cubit/paid_trip_handoff_cubit.dart';
import '../cubit/paid_trip_handoff_state.dart';

class PaidTripHandoffPage extends StatelessWidget {
  final String tripId;
  final String purchaseId;
  final PaymentsRepository paymentsRepository;
  final TripsRepository tripsRepository;
  final TwoGoStorage storage;
  final void Function(TripEntity trip) onHandoffSuccess;
  final VoidCallback? onCancelled;

  const PaidTripHandoffPage({
    super.key,
    required this.tripId,
    required this.purchaseId,
    required this.paymentsRepository,
    required this.tripsRepository,
    required this.storage,
    required this.onHandoffSuccess,
    this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaidTripHandoffCubit>(
      create: (context) => PaidTripHandoffCubit(
        paymentsRepository: paymentsRepository,
        tripsRepository: tripsRepository,
        storage: storage,
      )..reconcileAndUnlockTrip(
          tripId: tripId,
          purchaseId: purchaseId,
        ),
      child: Scaffold(
        backgroundColor: TwoGoColors.neutral900,
        body: SafeArea(
          child: BlocConsumer<PaidTripHandoffCubit, PaidTripHandoffState>(
            listener: (context, state) {
              if (state is PaidTripHandoffSuccessState) {
                onHandoffSuccess(state.trip);
              }
            },
            builder: (context, state) {
              if (state is PaidTripHandoffSuccessState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: TwoGoColors.success,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pagamento Confirmado!',
                        style: TwoGoTypography.headlineMedium.copyWith(
                          color: TwoGoColors.contentInverse,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seu roteiro completo está pronto.',
                        style: TwoGoTypography.bodyMedium.copyWith(
                          color: TwoGoColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is PaidTripHandoffFailureState) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: TwoGoColors.error,
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ops! Não foi possível ativar seu roteiro',
                        style: TwoGoTypography.headlineSmall.copyWith(
                          color: TwoGoColors.contentInverse,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage,
                        style: TwoGoTypography.bodyMedium.copyWith(
                          color: TwoGoColors.neutral400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (state.canRetryReconciliation)
                        TwoGoButton(
                          text: 'Tentar Novamente',
                          onPressed: () {
                            context.read<PaidTripHandoffCubit>().reconcileAndUnlockTrip(
                                  tripId: tripId,
                                  purchaseId: purchaseId,
                                );
                          },
                        ),
                      if (state.canRetryPayment && onCancelled != null) ...[
                        const SizedBox(height: 12),
                        TwoGoButton(
                          text: 'Voltar ao Checkout',
                          variant: TwoGoButtonVariant.secondary,
                          onPressed: onCancelled,
                        ),
                      ],
                    ],
                  ),
                );
              }

              // Loading / Reconciling State
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(TwoGoColors.brandLime),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Confirmando sua viagem...',
                      style: TwoGoTypography.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Estamos ativando o acesso completo ao seu roteiro.',
                      style: TwoGoTypography.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
