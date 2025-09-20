import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';
import '../constants/app_strings.dart';

/// Manejador centralizado de errores para VanguardMoney
/// Convierte errores de diferentes fuentes a AppException consistentes
class ErrorHandler {
  /// Maneja cualquier error y lo convierte a AppException
  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error, stackTrace);
    }

    // Network errors genericos
    if (error.toString().contains('network') ||
        error.toString().toLowerCase().contains('connection')) {
      return NetworkException.noConnection();
    }

    // Generic errors
    return UnknownException(originalError: error, stackTrace: stackTrace);
  }

  /// Maneja errores específicos de Firebase Auth
  static AuthException _handleFirebaseAuthError(
    FirebaseAuthException error,
    StackTrace? stackTrace,
  ) {
    switch (error.code) {
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'wrong-password':
        return AuthException.wrongPassword();
      case 'email-already-in-use':
        return AuthException.emailAlreadyInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'invalid-email':
        return AuthException.invalidEmail();
      case 'too-many-requests':
        return AuthException.tooManyRequests();
      case 'user-disabled':
        return AuthException(
          message: 'Esta cuenta ha sido deshabilitada',
          code: 'USER_DISABLED',
          originalError: error,
          stackTrace: stackTrace,
        );
      case 'operation-not-allowed':
        return AuthException(
          message: 'Operación no permitida',
          code: 'OPERATION_NOT_ALLOWED',
          originalError: error,
          stackTrace: stackTrace,
        );
      default:
        return AuthException(
          message: AppStrings.errorAuth,
          code: 'AUTH_UNKNOWN',
          originalError: error,
          stackTrace: stackTrace,
        );
    }
  }

  /// Valida campos de formulario y lanza ValidationException si hay errores
  static void validateForm(Map<String, String?> fields) {
    final errors = <String, String>{};

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      if (value == null || value.trim().isEmpty) {
        errors[fieldName] = AppStrings.validationRequired;
      }
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        message: 'Corrige los errores en el formulario',
        code: 'FORM_VALIDATION_ERROR',
        fieldErrors: errors,
      );
    }
  }

  /// Valida email específicamente
  static void validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      throw ValidationException.required('email');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw ValidationException.invalidFormat(
        'email',
        'Correo electrónico válido',
      );
    }
  }

  /// Valida contraseña
  static void validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      throw ValidationException.required('password');
    }

    if (password.length < 6) {
      throw ValidationException.outOfRange('password', 'Mínimo 6 caracteres');
    }
  }

  /// Valida monto de transacción
  static void validateAmount(String? amountStr) {
    if (amountStr == null || amountStr.trim().isEmpty) {
      throw BusinessLogicException.invalidAmount();
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      throw BusinessLogicException.invalidAmount();
    }
  }

  /// Valida fecha
  static void validateDate(DateTime? date) {
    if (date == null) {
      throw BusinessLogicException.invalidDate();
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      throw BusinessLogicException(
        message: 'La fecha no puede ser futura',
        code: 'FUTURE_DATE',
      );
    }
  }

  /// Log de errores (para implementar con analytics/crashlytics)
  static void logError(AppException error) {
    // TODO: Implementar logging con Firebase Crashlytics
    print('🔴 ERROR [${error.code}]: ${error.message}');
    if (error.originalError != null) {
      print('   Original: ${error.originalError}');
    }
    if (error.stackTrace != null) {
      print('   Stack: ${error.stackTrace}');
    }
  }
}
