import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';

import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_payment_cubit.dart';
import '../cubit/checkout_payment_state.dart';
import '../cubit/checkout_state.dart';
import '../widgets/checkout_coupon_section.dart';
import '../widgets/checkout_payment_method_tile.dart';
import '../widgets/checkout_price_summary.dart';
import 'pix_payment_view.dart';

class CheckoutPage extends StatelessWidget {
  final String tripId;
  final PaymentsRepository paymentsRepository;
  final PostAuthIntentStorage intentStorage;
  final TwoGoStorage storage;
  final CardTokenizer? cardTokenizer;
  final String publicKey;
  final void Function(
    String tripId,
    String paymentMethod,
    String? couponCode,
  )? onPaymentRequested;
  final void Function(CardReadyForPaymentState state)? onCardReadyForPayment;
  final void Function(String purchaseId, String tripId)? onPaymentConfirmed;
  final VoidCallback? onCancelled;
  final VoidCallback? onAlreadyEntitledCompleted;

  const CheckoutPage({
    super.key,
    required this.tripId,
    required this.paymentsRepository,
    required this.intentStorage,
    required this.storage,
    this.cardTokenizer,
    this.publicKey = 'APP_USR-TEST-DEVELOPMENT-PUBLIC-KEY',
    this.onPaymentRequested,
    this.onCardReadyForPayment,
    this.onPaymentConfirmed,
    this.onCancelled,
    this.onAlreadyEntitledCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CheckoutCubit>(
          create: (context) => CheckoutCubit(
            paymentsRepository: paymentsRepository,
            intentStorage: intentStorage,
            cardTokenizer: cardTokenizer,
          )..loadCheckout(tripId),
        ),
        BlocProvider<CheckoutPaymentCubit>(
          create: (context) => CheckoutPaymentCubit(
            paymentsRepository: paymentsRepository,
            storage: storage,
          )..resumePendingPayment(tripId),
        ),
      ],
      child: CheckoutView(
        tripId: tripId,
        publicKey: publicKey,
        onPaymentRequested: onPaymentRequested,
        onCardReadyForPayment: onCardReadyForPayment,
        onPaymentConfirmed: onPaymentConfirmed,
        onCancelled: onCancelled,
        onAlreadyEntitledCompleted: onAlreadyEntitledCompleted,
      ),
    );
  }
}

class CheckoutView extends StatelessWidget {
  final String tripId;
  final String publicKey;
  final void Function(
    String tripId,
    String paymentMethod,
    String? couponCode,
  )? onPaymentRequested;
  final void Function(CardReadyForPaymentState state)? onCardReadyForPayment;
  final void Function(String purchaseId, String tripId)? onPaymentConfirmed;
  final VoidCallback? onCancelled;
  final VoidCallback? onAlreadyEntitledCompleted;

  const CheckoutView({
    super.key,
    required this.tripId,
    required this.publicKey,
    this.onPaymentRequested,
    this.onCardReadyForPayment,
    this.onPaymentConfirmed,
    this.onCancelled,
    this.onAlreadyEntitledCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final checkoutCubit = context.read<CheckoutCubit>();
    final paymentCubit = context.read<CheckoutPaymentCubit>();

    return BlocConsumer<CheckoutPaymentCubit, CheckoutPaymentState>(
      listener: (context, paymentState) {
        if (paymentState is PaymentConfirmedByCoreState) {
          onPaymentConfirmed?.call(paymentState.purchaseId, paymentState.tripId);
        }
      },
      builder: (context, paymentState) {
        if (paymentState is CheckoutPixPendingState) {
          return Scaffold(
            backgroundColor: TwoGoColors.background,
            appBar: TwoGoAppBar(
              title: 'Pagamento PIX',
              leading: TwoGoIconButton(
                icon: Icons.close_rounded,
                onPressed: () => checkoutCubit.cancelCheckout(),
              ),
            ),
            body: PixPaymentView(
              purchaseId: paymentState.purchaseId,
              copyPaste: paymentState.copyPaste,
              qrCodeBase64: paymentState.qrCodeBase64,
              remainingSeconds: paymentState.remainingSeconds,
            ),
          );
        }

        if (paymentState is CheckoutCardAwaitingConfirmationState ||
            paymentState is CheckoutPaymentProcessingState) {
          return Scaffold(
            backgroundColor: TwoGoColors.background,
            appBar: const TwoGoAppBar(
              title: 'Processando Pagamento',
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TwoGoLoadingIndicator(size: 40),
                  const SizedBox(height: TwoGoSpacing.md),
                  Text(
                    'Aguardando confirmação do pagamento pelo servidor...',
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: TwoGoColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (paymentState is PaymentConfirmedByCoreState) {
          return Scaffold(
            backgroundColor: TwoGoColors.background,
            appBar: const TwoGoAppBar(title: 'Pagamento Confirmado'),
            body: Padding(
              padding: const EdgeInsets.all(TwoGoSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: TwoGoColors.success,
                    size: 72,
                  ),
                  const SizedBox(height: TwoGoSpacing.md),
                  Text(
                    'Pagamento Confirmado!',
                    style: TwoGoTypography.headlineMedium.copyWith(
                      color: TwoGoColors.contentPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TwoGoSpacing.xs),
                  Text(
                    'O servidor confirmou o recebimento. Seu acesso premium está liberado.',
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: TwoGoColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state is CardReadyForPaymentState) {
              onCardReadyForPayment?.call(state);
              paymentCubit.executePayment(
                tripId: tripId,
                paymentMethod: 'CARD',
                cardToken: state.cardToken,
                couponCode: state.couponCode,
                installments: state.installments,
              );
            } else if (state is CheckoutPaymentRequestedState) {
              onPaymentRequested?.call(
                state.tripId,
                state.paymentMethod,
                state.couponCode,
              );
              if (state.paymentMethod.toUpperCase() == 'PIX') {
                paymentCubit.executePayment(
                  tripId: tripId,
                  paymentMethod: 'PIX',
                  couponCode: state.couponCode,
                );
              }
            } else if (state is CheckoutCancelledState) {
              onCancelled?.call();
            }
          },
          builder: (context, state) {
            return Scaffold(
              backgroundColor: TwoGoColors.background,
              appBar: TwoGoAppBar(
                title: 'Checkout Premium',
                leading: TwoGoIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => checkoutCubit.cancelCheckout(),
                ),
              ),
              body: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(TwoGoSpacing.sm),
                    child: TwoGoProgressBar(progress: 0.5),
                  ),
                  Expanded(
                    child: _buildBody(context, state, checkoutCubit),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CheckoutState state,
    CheckoutCubit cubit,
  ) {
    if (state is CheckoutLoadingState || state is CheckoutInitialState) {
      return const Center(
        child: TwoGoLoadingIndicator(size: 32),
      );
    }

    if (state is CheckoutAlreadyEntitledState) {
      return Padding(
        padding: const EdgeInsets.all(TwoGoSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_rounded,
              color: TwoGoColors.success,
              size: 64,
            ),
            const SizedBox(height: TwoGoSpacing.md),
            Text(
              'Roteiro Já Desbloqueado!',
              style: TwoGoTypography.headlineMedium.copyWith(
                color: TwoGoColors.contentPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TwoGoSpacing.xs),
            Text(
              'Você já possui acesso premium completo a este roteiro.',
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TwoGoSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: TwoGoButton(
                text: 'Acessar Roteiro',
                onPressed: () {
                  cubit.cancelCheckout();
                  onAlreadyEntitledCompleted?.call();
                },
              ),
            ),
          ],
        ),
      );
    }

    if (state is CheckoutErrorState) {
      return Center(
        child: TwoGoStatusMessage(
          title: 'Erro ao carregar checkout',
          description: state.message,
          actionText: 'Tentar Novamente',
          onActionPressed: () => cubit.loadCheckout(tripId),
        ),
      );
    }

    if (state is CheckoutReadyState) {
      final summary = state.summary;
      final supportedMethods = summary.supportedPaymentMethods;

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TwoGoSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckoutPriceSummary(summary: summary),
                  const SizedBox(height: TwoGoSpacing.md),
                  CheckoutCouponSection(
                    coupon: summary.coupon,
                    isQuoting: state.isQuoting,
                    quoteError: state.quoteError,
                    onApplyCoupon: (code) => cubit.applyCoupon(tripId, code),
                    onRemoveCoupon: () => cubit.removeCoupon(tripId),
                  ),
                  const SizedBox(height: TwoGoSpacing.md),
                  TwoGoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forma de Pagamento',
                          style: TwoGoTypography.headlineSmall.copyWith(
                            color: TwoGoColors.contentPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: TwoGoSpacing.sm),
                        ...supportedMethods.map((method) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: TwoGoSpacing.xs),
                            child: CheckoutPaymentMethodTile(
                              methodKey: method,
                              isSelected: state.selectedPaymentMethod == method,
                              onTap: () => cubit.selectPaymentMethod(method),
                            ),
                          );
                        }),
                        if (state.cardTokenError != null) ...[
                          const SizedBox(height: TwoGoSpacing.sm),
                          TwoGoInlineFeedback(
                            message: state.cardTokenError!,
                            variant: TwoGoInlineFeedbackVariant.error,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(TwoGoSpacing.md),
            decoration: BoxDecoration(
              color: TwoGoColors.neutral0,
              boxShadow: [
                BoxShadow(
                  color: TwoGoColors.contentPrimary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: TwoGoButton(
                  text: 'Continuar com ${_getMethodTitle(state.selectedPaymentMethod)}',
                  loading: state.isTokenizing,
                  onPressed: state.isTokenizing
                      ? null
                      : () => cubit.requestPayment(publicKey: publicKey),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  String _getMethodTitle(String methodKey) {
    switch (methodKey.toUpperCase()) {
      case 'PIX':
        return 'PIX';
      case 'CARD':
      case 'CREDIT_CARD':
        return 'Cartão de Crédito';
      default:
        return methodKey;
    }
  }
}
