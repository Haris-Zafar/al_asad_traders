import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/errors/error_message.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException hierarchy', () {
    test('ValidationException has correct default message and toString', () {
      const exception = ValidationException();
      expect(exception.message, AppStrings.errorValidation);
      expect(exception.cause, isNull);
      expect(
        exception.toString(),
        'ValidationException: ${AppStrings.errorValidation}',
      );
    });

    test('ValidationException preserves custom message and cause', () {
      final cause = Exception('Invalid input');
      final exception = ValidationException('Custom error', cause);
      expect(exception.message, 'Custom error');
      expect(exception.cause, cause);
      expect(
        exception.toString(),
        'ValidationException: Custom error (cause: $cause)',
      );
    });

    test('NotFoundException has default and custom messages', () {
      const defaultEx = NotFoundException();
      expect(defaultEx.message, AppStrings.errorItemNoLongerAvailable);

      const customEx = NotFoundException('Buyer not found');
      expect(customEx.message, 'Buyer not found');
    });

    test('ConflictException has default and custom messages', () {
      const defaultEx = ConflictException();
      expect(defaultEx.message, AppStrings.errorConflict);

      const customEx = ConflictException('Bill is already finished');
      expect(customEx.message, 'Bill is already finished');
    });

    test('PermissionException has default and custom messages', () {
      const defaultEx = PermissionException();
      expect(defaultEx.message, AppStrings.errorPleaseLogInAgain);

      const customEx = PermissionException('Access denied');
      expect(customEx.message, 'Access denied');
    });

    test('UnavailableException has default and custom messages', () {
      const defaultEx = UnavailableException();
      expect(defaultEx.message, AppStrings.errorInternetNeeded);

      const customEx = UnavailableException('No internet');
      expect(customEx.message, 'No internet');
    });

    test('UnknownException has default and custom messages', () {
      const defaultEx = UnknownException();
      expect(defaultEx.message, AppStrings.errorGeneric);

      const customEx = UnknownException('Unexpected crash');
      expect(customEx.message, 'Unexpected crash');
    });
  });

  group('userErrorMessage mapping', () {
    test('maps ValidationException to plain English text', () {
      expect(
        userErrorMessage(const ValidationException()),
        AppStrings.errorValidation,
      );
      expect(
        userErrorMessage(const ValidationException('Amount must be positive')),
        'Amount must be positive',
      );
    });

    test('maps NotFoundException to plain English text', () {
      expect(
        userErrorMessage(const NotFoundException()),
        AppStrings.errorItemNoLongerAvailable,
      );
      expect(
        userErrorMessage(const NotFoundException('Product removed')),
        'Product removed',
      );
    });

    test('maps ConflictException to plain English text', () {
      expect(
        userErrorMessage(const ConflictException()),
        AppStrings.errorConflict,
      );
      expect(
        userErrorMessage(const ConflictException('Already paid')),
        'Already paid',
      );
    });

    test('maps PermissionException to plain English text', () {
      expect(
        userErrorMessage(const PermissionException()),
        AppStrings.errorPleaseLogInAgain,
      );
    });

    test('maps UnavailableException to plain English text', () {
      expect(
        userErrorMessage(const UnavailableException()),
        AppStrings.errorInternetNeeded,
      );
    });

    test('maps UnknownException to plain English text', () {
      expect(
        userErrorMessage(const UnknownException()),
        AppStrings.errorGeneric,
      );
    });
  });
}
