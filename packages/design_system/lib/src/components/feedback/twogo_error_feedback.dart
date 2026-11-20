import 'package:flutter/material.dart';
import 'package:twogo_core/twogo_core.dart';

import 'twogo_snackbar.dart';

/// Shared UI bridge: typed [AppFailure] → field helpers / toast patterns.
///
/// - [NetworkFailure] → coral connectivity toast
/// - [ValidationFailure] with field errors → no toast (bind via [fieldError])
/// - everything else → dark error toast
abstract final class TwoGoErrorFeedback {
  static const invalidField = TwoGoCoreFieldMessages.invalid;
  static const requiredField = TwoGoCoreFieldMessages.required;

  /// Presents a toast when appropriate. Returns field errors for form binding.
  static Map<String, String> present(
    BuildContext context,
    AppFailure failure, {
    bool showToastForValidation = false,
  }) {
    if (failure is NetworkFailure) {
      TwoGoSnackbar.showNoConnection(context, message: failure.message);
      return const {};
    }

    if (failure is ValidationFailure) {
      if (showToastForValidation || !failure.hasFieldErrors) {
        TwoGoSnackbar.show(
          context,
          message: failure.message,
          variant: TwoGoSnackbarVariant.error,
        );
      }
      return failure.fieldErrors;
    }

    if (failure is InvalidOtpFailure) {
      // OTP screens own inline field + toast copy.
      return const {};
    }

    TwoGoSnackbar.show(
      context,
      message: failure.message,
      variant: TwoGoSnackbarVariant.error,
    );
    return const {};
  }

  static String? fieldError(AppFailure? failure, String field) {
    if (failure is ValidationFailure) {
      return failure.errorFor(field);
    }
    return null;
  }
}
