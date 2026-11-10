import 'package:al_asad_traders/core/strings.dart';

/// Sealed base exception for all application errors.
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
sealed class AppException implements Exception {
  /// Base constructor taking a [message] key and optional [cause].
  const AppException(this.message, [this.cause]);

  /// Key or string identifier in strings.dart, never raw technical text.
  final String message;

  /// Underlying cause or original exception, if available.
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Thrown when user or system input breaks a business validation rule.
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
final class ValidationException extends AppException {
  /// Creates a validation exception.
  const ValidationException([
    super.message = AppStrings.errorValidation,
    super.cause,
  ]);
}

/// Thrown when an expected resource or document is missing.
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
final class NotFoundException extends AppException {
  /// Creates a not-found exception.
  const NotFoundException([
    super.message = AppStrings.errorItemNoLongerAvailable,
    super.cause,
  ]);
}

/// Thrown when a concurrent edit conflict occurs (e.g. bill no longer draft).
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
final class ConflictException extends AppException {
  /// Creates a conflict exception.
  const ConflictException([
    super.message = AppStrings.errorConflict,
    super.cause,
  ]);
}

/// Thrown when security rules deny access or user session is expired.
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
final class PermissionException extends AppException {
  /// Creates a permission exception.
  const PermissionException([
    super.message = AppStrings.errorPleaseLogInAgain,
    super.cause,
  ]);
}

/// Thrown when an operation requires internet connectivity.
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
final class UnavailableException extends AppException {
  /// Creates an unavailable exception.
  const UnavailableException([
    super.message = AppStrings.errorInternetNeeded,
    super.cause,
  ]);
}

/// Wraps any unexpected or unclassified exceptions.
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
final class UnknownException extends AppException {
  /// Creates an unknown exception.
  const UnknownException([
    super.message = AppStrings.errorGeneric,
    super.cause,
  ]);
}
