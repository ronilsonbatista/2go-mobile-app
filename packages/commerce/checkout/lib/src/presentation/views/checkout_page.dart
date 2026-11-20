import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';

import '../../domain/checkout_buyer_mode.dart';
import '../../domain/checkout_invite_prefill.dart';
import '../../domain/checkout_saved_card.dart';
import '../../domain/checkout_trip_preview.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_payment_cubit.dart';
import '../cubit/checkout_payment_state.dart';
import '../cubit/checkout_state.dart';
import '../widgets/checkout_coupon_sheet.dart';
import '../widgets/checkout_payment_methods_list.dart';
import '../widgets/checkout_personal_data_section.dart';
import '../widgets/checkout_terms_row.dart';
import '../widgets/checkout_trip_card.dart';
import '../widgets/checkout_valor_section.dart';
import 'card_payment_view.dart';
import 'checkout_error_view.dart';
import 'checkout_success_view.dart';
import 'pix_payment_view.dart';
import 'terms_of_use_page.dart';

enum _CheckoutUiStep { cart, card, terms }

/// Carrinho / Pagamento layout-first checkout flow.
class CheckoutPage extends StatelessWidget {
  final String tripId;
  final PaymentsRepository paymentsRepository;
  final PostAuthIntentStorage intentStorage;
  final TwoGoStorage storage;
  final CardTokenizer? cardTokenizer;
  final String publicKey;
  final CheckoutBuyerMode buyerMode;
  final CheckoutTripPreview tripPreview;
  final CheckoutSavedCard? savedCard;
  final CheckoutInvitePrefill? invitePrefill;
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
    this.buyerMode = CheckoutBuyerMode.firstPurchase,
    this.tripPreview = CheckoutTripPreview.demoRoma,
    this.savedCard,
    this.invitePrefill,
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
        buyerMode: buyerMode,
        tripPreview: tripPreview,
        savedCard: savedCard ??
            (buyerMode == CheckoutBuyerMode.returning
                ? CheckoutSavedCard.demoMastercard4405
                : null),
        invitePrefill: invitePrefill ??
            (buyerMode == CheckoutBuyerMode.invite
                ? CheckoutInvitePrefill.demoJoao
                : null),
        onPaymentRequested: onPaymentRequested,
        onCardReadyForPayment: onCardReadyForPayment,
        onPaymentConfirmed: onPaymentConfirmed,
        onCancelled: onCancelled,
        onAlreadyEntitledCompleted: onAlreadyEntitledCompleted,
      ),
    );
  }
}

class CheckoutView extends StatefulWidget {
  final String tripId;
  final String publicKey;
  final CheckoutBuyerMode buyerMode;
  final CheckoutTripPreview tripPreview;
  final CheckoutSavedCard? savedCard;
  final CheckoutInvitePrefill? invitePrefill;
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
    required this.buyerMode,
    required this.tripPreview,
    this.savedCard,
    this.invitePrefill,
    this.onPaymentRequested,
    this.onCardReadyForPayment,
    this.onPaymentConfirmed,
    this.onCancelled,
    this.onAlreadyEntitledCompleted,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();

  _CheckoutUiStep _step = _CheckoutUiStep.cart;
  bool _termsAccepted = false;
  bool _handledPixExpire = false;
  String? _pendingToast;
  TwoGoSnackbarVariant _pendingToastVariant = TwoGoSnackbarVariant.info;

  @override
  void initState() {
    super.initState();
    final prefill = widget.invitePrefill;
    if (prefill != null) {
      _nameController.text = prefill.fullName;
      _phoneController.text = prefill.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  void _queueToast(String message, TwoGoSnackbarVariant variant) {
    _pendingToast = message;
    _pendingToastVariant = variant;
  }

  void _flushToast(BuildContext context) {
    final message = _pendingToast;
    if (message == null) return;
    _pendingToast = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      TwoGoSnackbar.show(
        context,
        message: message,
        variant: _pendingToastVariant,
      );
    });
  }

  bool get _personalDataValid {
    if (!widget.buyerMode.showsPersonalData) return true;
    final nameOk = _nameController.text.trim().length >= 3;
    final phoneDigits =
        _phoneController.text.replaceAll(RegExp(r'\D'), '').length >= 10;
    final cpfDigits =
        _cpfController.text.replaceAll(RegExp(r'\D'), '').length == 11;
    return nameOk && phoneDigits && cpfDigits;
  }

  bool get _canProceedToPayment {
    if (!_personalDataValid) return false;
    if (widget.buyerMode.showsTerms && !_termsAccepted) return false;
    return true;
  }

  void _openTerms() {
    setState(() => _step = _CheckoutUiStep.terms);
  }

  Future<void> _openCouponSheet(
    BuildContext context,
    CheckoutCubit cubit,
  ) async {
    final code = await showCheckoutCouponSheet(context);
    if (code == null || code.isEmpty || !mounted) return;
    await cubit.applyCoupon(widget.tripId, code);
  }

  void _onSelectPaymentMethod(String method) {
    if (!_canProceedToPayment) {
      if (widget.buyerMode.showsTerms && !_termsAccepted) {
        TwoGoSnackbar.show(
          context,
          message: 'Aceite o Termos de Uso antes de continuar',
          variant: TwoGoSnackbarVariant.warning,
        );
        return;
      }
      TwoGoSnackbar.show(
        context,
        message: 'Preencha os dados pessoais para continuar',
        variant: TwoGoSnackbarVariant.warning,
      );
      return;
    }

    final cubit = context.read<CheckoutCubit>();
    cubit.selectPaymentMethod(method);

    switch (method.toUpperCase()) {
      case 'CARD':
      case 'CREDIT_CARD':
        setState(() => _step = _CheckoutUiStep.card);
        break;
      case 'PIX':
        cubit.requestPayment(publicKey: widget.publicKey);
        break;
      case 'APPLE_PAY':
        _showWalletStubSheet(isApple: true);
        break;
      case 'GOOGLE_PAY':
        _showWalletStubSheet(isApple: false);
        break;
    }
  }

  Future<void> _showWalletStubSheet({required bool isApple}) async {
    final ready = context.read<CheckoutCubit>().state;
    final amount = ready is CheckoutReadyState
        ? ready.summary.pricing.finalAmount
        : 21.99;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: TwoGoColors.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: TwoGoRadius.sheetTop,
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(TwoGoSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isApple ? 'Apple Pay' : 'Google Pay',
                  style: TwoGoTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.sm),
                Text(
                  'Roteiro Único · pagamento único',
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.md),
                Text(
                  'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TwoGoTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.lg),
                TwoGoButton(
                  text: isApple
                      ? 'Confirm with side button'
                      : 'Pagar com Google Pay',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.read<CheckoutCubit>().requestPayment(
                          publicKey: widget.publicKey,
                        );
                  },
                ),
                const SizedBox(height: TwoGoSpacing.xs),
                TwoGoButton(
                  text: 'Cancelar',
                  variant: TwoGoButtonVariant.tertiary,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePixExpired(CheckoutPaymentCubit paymentCubit) {
    if (_handledPixExpire) return;
    _handledPixExpire = true;
    paymentCubit.acknowledgeExpiredPayment();
    _queueToast(
      'O prazo do PIX expirou. Repita a operação para finalizar a compra.',
      TwoGoSnackbarVariant.warning,
    );
    setState(() => _step = _CheckoutUiStep.cart);
  }

  @override
  Widget build(BuildContext context) {
    final checkoutCubit = context.read<CheckoutCubit>();
    final paymentCubit = context.read<CheckoutPaymentCubit>();

    return BlocConsumer<CheckoutPaymentCubit, CheckoutPaymentState>(
      listener: (context, paymentState) {
        if (paymentState is PaymentConfirmedByCoreState) {
          widget.onPaymentConfirmed?.call(
            paymentState.purchaseId,
            paymentState.tripId,
          );
        } else if (paymentState is CheckoutPaymentExpiredState) {
          _handlePixExpired(paymentCubit);
        }
      },
      builder: (context, paymentState) {
        if (paymentState is PaymentConfirmedByCoreState) {
          return CheckoutSuccessView(
            onAccessItinerary: () {
              widget.onPaymentConfirmed?.call(
                paymentState.purchaseId,
                paymentState.tripId,
              );
            },
          );
        }

        if (paymentState is CheckoutPaymentFailureState ||
            paymentState is CheckoutPaymentRejectedState) {
          final message = paymentState is CheckoutPaymentFailureState
              ? paymentState.errorMessage
              : (paymentState as CheckoutPaymentRejectedState).errorMessage;
          return CheckoutErrorView(
            message: message,
            onBack: () {
              paymentCubit.resetToIdle();
              setState(() => _step = _CheckoutUiStep.card);
            },
          );
        }

        if (paymentState is CheckoutPixPendingState) {
          final ready = checkoutCubit.state;
          final amount = ready is CheckoutReadyState
              ? ready.summary.pricing.finalAmount
              : 21.99;
          return PixPaymentView(
            purchaseId: paymentState.purchaseId,
            copyPaste: paymentState.copyPaste,
            qrCodeBase64: paymentState.qrCodeBase64,
            remainingSeconds: paymentState.remainingSeconds,
            amount: amount,
            onBack: () {
              paymentCubit.resetToIdle();
              setState(() => _step = _CheckoutUiStep.cart);
            },
            onExpired: () => _handlePixExpired(paymentCubit),
          );
        }

        if (paymentState is CheckoutCardAwaitingConfirmationState ||
            paymentState is CheckoutPaymentProcessingState) {
          return Scaffold(
            backgroundColor: TwoGoColors.backgroundPrimary,
            appBar: const TwoGoAppBar(
              title: 'Processando Pagamento',
              showBackButton: false,
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

        return BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state is CardReadyForPaymentState) {
              widget.onCardReadyForPayment?.call(state);
              paymentCubit.executePayment(
                tripId: widget.tripId,
                paymentMethod: 'CARD',
                cardToken: state.cardToken,
                couponCode: state.couponCode,
                installments: state.installments,
              );
            } else if (state is CheckoutPaymentRequestedState) {
              widget.onPaymentRequested?.call(
                state.tripId,
                state.paymentMethod,
                state.couponCode,
              );
              if (state.paymentMethod.toUpperCase() == 'PIX' ||
                  state.paymentMethod.toUpperCase() == 'APPLE_PAY' ||
                  state.paymentMethod.toUpperCase() == 'GOOGLE_PAY') {
                paymentCubit.executePayment(
                  tripId: widget.tripId,
                  paymentMethod: state.paymentMethod.toUpperCase() == 'PIX'
                      ? 'PIX'
                      : state.paymentMethod,
                  couponCode: state.couponCode,
                );
              }
            } else if (state is CheckoutCancelledState) {
              widget.onCancelled?.call();
            } else if (state is CheckoutReadyState) {
              if (state.quoteError != null) {
                _queueToast('Cupom inválido', TwoGoSnackbarVariant.error);
              } else if (state.couponJustApplied) {
                _queueToast(
                  'Cupom aplicado com sucesso!',
                  TwoGoSnackbarVariant.success,
                );
              }
            }
          },
          builder: (context, state) {
            _flushToast(context);

            if (_step == _CheckoutUiStep.terms) {
              return TermsOfUsePage(
                onBack: () => setState(() => _step = _CheckoutUiStep.cart),
              );
            }

            if (state is CheckoutLoadingState ||
                state is CheckoutInitialState) {
              return Scaffold(
                backgroundColor: TwoGoColors.backgroundPrimary,
                appBar: TwoGoAppBar(
                  title: 'Carrinho',
                  leading: TwoGoIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => checkoutCubit.cancelCheckout(),
                  ),
                ),
                body: const Center(child: TwoGoLoadingIndicator(size: 32)),
              );
            }

            if (state is CheckoutAlreadyEntitledState) {
              return Scaffold(
                backgroundColor: TwoGoColors.backgroundPrimary,
                appBar: const TwoGoAppBar(title: 'Carrinho'),
                body: TwoGoStatusMessage(
                  type: TwoGoStatusMessageType.success,
                  title: 'Roteiro Já Desbloqueado!',
                  description:
                      'Você já possui acesso premium completo a este roteiro.',
                  actionText: 'Acessar roteiro',
                  onActionPressed: () {
                    checkoutCubit.cancelCheckout();
                    widget.onAlreadyEntitledCompleted?.call();
                  },
                ),
              );
            }

            if (state is CheckoutErrorState) {
              return Scaffold(
                backgroundColor: TwoGoColors.backgroundPrimary,
                appBar: TwoGoAppBar(
                  title: 'Carrinho',
                  leading: TwoGoIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => checkoutCubit.cancelCheckout(),
                  ),
                ),
                body: TwoGoStatusMessage(
                  type: TwoGoStatusMessageType.error,
                  title: 'Erro ao carregar checkout',
                  description: state.message,
                  actionText: 'Tentar Novamente',
                  onActionPressed: () =>
                      checkoutCubit.loadCheckout(widget.tripId),
                ),
              );
            }

            if (state is CheckoutReadyState) {
              if (_step == _CheckoutUiStep.card) {
                return CardPaymentView(
                  amount: state.summary.pricing.finalAmount,
                  savedCard: widget.savedCard,
                  isSubmitting: state.isTokenizing,
                  errorMessage: state.cardTokenError,
                  onBack: () => setState(() => _step = _CheckoutUiStep.cart),
                  onPay: ({
                    required cardNumber,
                    required holderName,
                    required expiry,
                    required cvv,
                    required saveCard,
                    required usingSavedCard,
                  }) {
                    // Layout-first: tokenization still via existing cubit path.
                    checkoutCubit.requestPayment(
                      publicKey: widget.publicKey,
                      cpf: _cpfController.text.replaceAll(RegExp(r'\D'), ''),
                    );
                  },
                );
              }

              return _CartScaffold(
                onClose: () => checkoutCubit.cancelCheckout(),
                child: _CartBody(
                  summary: state.summary,
                  tripPreview: widget.tripPreview,
                  buyerMode: widget.buyerMode,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  cpfController: _cpfController,
                  termsAccepted: _termsAccepted,
                  isQuoting: state.isQuoting,
                  onTermsChanged: (v) => setState(() => _termsAccepted = v),
                  onOpenTerms: _openTerms,
                  onAddCoupon: () => _openCouponSheet(context, checkoutCubit),
                  onRemoveCoupon: () =>
                      checkoutCubit.removeCoupon(widget.tripId),
                  onSelectPaymentMethod: _onSelectPaymentMethod,
                  onPersonalDataChanged: (_) => setState(() {}),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _CartScaffold extends StatelessWidget {
  const _CartScaffold({required this.onClose, required this.child});

  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: TwoGoAppBar(
        title: 'Carrinho',
        leading: TwoGoIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: onClose,
        ),
      ),
      body: child,
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({
    required this.summary,
    required this.tripPreview,
    required this.buyerMode,
    required this.nameController,
    required this.phoneController,
    required this.cpfController,
    required this.termsAccepted,
    required this.isQuoting,
    required this.onTermsChanged,
    required this.onOpenTerms,
    required this.onAddCoupon,
    required this.onRemoveCoupon,
    required this.onSelectPaymentMethod,
    required this.onPersonalDataChanged,
  });

  final CheckoutSummary summary;
  final CheckoutTripPreview tripPreview;
  final CheckoutBuyerMode buyerMode;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController cpfController;
  final bool termsAccepted;
  final bool isQuoting;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onAddCoupon;
  final VoidCallback onRemoveCoupon;
  final ValueChanged<String> onSelectPaymentMethod;
  final ValueChanged<String> onPersonalDataChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        TwoGoSpacing.md,
        TwoGoSpacing.sm,
        TwoGoSpacing.md,
        TwoGoSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckoutTripCard(trip: tripPreview),
          const SizedBox(height: TwoGoSpacing.lg),
          CheckoutValorSection(
            pricing: summary.pricing,
            coupon: summary.coupon,
            onAddCoupon: isQuoting ? () {} : onAddCoupon,
            onRemoveCoupon: isQuoting ? null : onRemoveCoupon,
          ),
          if (buyerMode.showsPersonalData) ...[
            const SizedBox(height: TwoGoSpacing.xl),
            CheckoutPersonalDataSection(
              nameController: nameController,
              phoneController: phoneController,
              cpfController: cpfController,
              onChanged: onPersonalDataChanged,
            ),
          ],
          if (buyerMode.showsTerms) ...[
            const SizedBox(height: TwoGoSpacing.md),
            CheckoutTermsRow(
              accepted: termsAccepted,
              onChanged: onTermsChanged,
              onOpenTerms: onOpenTerms,
            ),
          ],
          const SizedBox(height: TwoGoSpacing.xl),
          CheckoutPaymentMethodsList(
            methods: summary.supportedPaymentMethods,
            availability: summary.paymentMethodAvailability,
            onSelect: onSelectPaymentMethod,
          ),
        ],
      ),
    );
  }
}
