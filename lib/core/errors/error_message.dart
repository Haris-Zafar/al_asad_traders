import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';

/// Maps an [AppException] to user-facing plain English text.
/// Rule: docs/ARCHITECTURE.md > Error handling. Story: none.
String userErrorMessage(AppException exception) {
  return switch (exception) {
    ValidationException(message: final msg) =>
      msg.isNotEmpty ? msg : AppStrings.errorValidation,
    NotFoundException(message: final msg) =>
      msg.isNotEmpty ? msg : AppStrings.errorItemNoLongerAvailable,
    ConflictException(message: final msg) =>
      msg.isNotEmpty ? msg : AppStrings.errorConflict,
    PermissionException(message: final msg) =>
      msg.isNotEmpty ? msg : AppStrings.errorPleaseLogInAgain,
    UnavailableException(message: final msg) =>
      msg.isNotEmpty ? msg : AppStrings.errorInternetNeeded,
    UnknownException(message: final msg) =>
      msg.isNotEmpty ? msg : AppStrings.errorGeneric,
  };
}
