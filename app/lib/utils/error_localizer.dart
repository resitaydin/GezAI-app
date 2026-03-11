import '../l10n/app_localizations.dart';

/// Utility class to localize authentication error messages.
///
/// Since AuthService doesn't have access to BuildContext, it throws errors
/// with error codes. This utility maps those codes to localized messages
/// at the UI layer.
class ErrorLocalizer {
  /// Maps an error message or error code to a localized message.
  ///
  /// Usage:
  /// ```dart
  /// final l10n = AppLocalizations.of(context)!;
  /// final localizedError = ErrorLocalizer.getLocalizedError(
  ///   error.toString(),
  ///   l10n,
  /// );
  /// ```
  static String getLocalizedError(String error, AppLocalizations l10n) {
    // Check if error contains Firebase error codes
    if (error.contains('invalid-credential')) {
      return l10n.errorInvalidCredential;
    }
    if (error.contains('user-not-found')) {
      return l10n.errorUserNotFound;
    }
    if (error.contains('wrong-password')) {
      return l10n.errorWrongPassword;
    }
    if (error.contains('invalid-email')) {
      return l10n.errorInvalidEmail;
    }
    if (error.contains('user-disabled')) {
      return l10n.errorUserDisabled;
    }
    if (error.contains('email-already-in-use')) {
      return l10n.errorEmailAlreadyInUse;
    }
    if (error.contains('weak-password')) {
      return l10n.errorWeakPassword;
    }
    if (error.contains('operation-not-allowed')) {
      return l10n.errorOperationNotAllowed;
    }
    if (error.contains('too-many-requests')) {
      return l10n.errorTooManyRequests;
    }
    if (error.contains('network-request-failed')) {
      return l10n.errorNetworkRequestFailed;
    }
    if (error.contains('expired-action-code')) {
      return l10n.errorExpiredActionCode;
    }
    if (error.contains('invalid-action-code')) {
      return l10n.errorInvalidActionCode;
    }
    if (error.contains('requires-recent-login')) {
      return l10n.errorRequiresRecentLogin;
    }
    if (error.contains('account-exists-with-different-credential')) {
      return l10n.errorAccountExistsWithDifferentCredential;
    }
    if (error.contains('credential-already-in-use')) {
      return l10n.errorCredentialAlreadyInUse;
    }
    if (error.contains('Google sign-in cancelled')) {
      return l10n.errorGoogleSignInCancelled;
    }
    if (error.contains('Google sign-in failed')) {
      return l10n.errorGoogleSignInFailed;
    }

    // Return a generic user-friendly error for any unhandled error
    return l10n.errorUnknown;
  }
}
