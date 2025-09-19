import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/edit_profile_model.dart';
import '../models/user_profile_model.dart';
import '../services/auth_repository.dart';
import 'auth_provider.dart';

/// Provider para obtener el perfil completo del usuario desde Firestore
final currentUserProfileProvider = FutureProvider<UserProfileModel?>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return null;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.id)
        .get();

    if (doc.exists && doc.data() != null) {
      return UserProfileModel.fromMap(doc.data()!);
    }

    return null;
  } catch (e) {
    print('Error loading user profile: $e');
    return null;
  }
});

/// Provider para el estado de edición del perfil
final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, EditProfileState>(
      (ref) => EditProfileNotifier(
        authRepository: ref.read(authRepositoryProvider),
        ref: ref,
      ),
    );

/// Notifier que maneja el estado y la lógica de edición del perfil
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  EditProfileNotifier({
    required AuthRepository authRepository,
    required Ref ref,
  }) : _authRepository = authRepository,
       _ref = ref,
       super(EditProfileState.initial());

  /// Inicializar el formulario con los datos actuales del usuario
  void initializeFromUserProfile(UserProfileModel? userProfile) {
    if (userProfile != null) {
      final editProfile = EditProfileModel.fromUserProfile(userProfile);
      state = state.copyWithProfile(editProfile);
    } else {
      state = EditProfileState.initial();
    }
  }

  /// Actualizar el nombre de usuario
  void updateUsername(String username) {
    final updatedProfile = state.profile.copyWith(username: username);
    state = state.copyWithProfile(updatedProfile);

    // Limpiar errores de validación previos
    if (state.validationErrors.isNotEmpty) {
      _validateProfile();
    }
  }

  /// Actualizar la moneda
  void updateCurrency(String currency) {
    final updatedProfile = state.profile.copyWith(currency: currency);
    state = state.copyWithProfile(updatedProfile);

    // Limpiar errores de validación previos
    if (state.validationErrors.isNotEmpty) {
      _validateProfile();
    }
  }

  /// Actualizar la foto de perfil
  void updatePhotoUrl(String? photoUrl) {
    final updatedProfile = state.profile.copyWith(photoUrl: photoUrl);
    state = state.copyWithProfile(updatedProfile);
  }

  /// Validar el perfil sin guardarlo
  bool _validateProfile() {
    final errors = state.profile.validationErrors;
    if (errors.isNotEmpty) {
      state = state.copyWithValidationErrors(errors);
      return false;
    }

    // Si no hay errores, limpiar el estado de error
    if (state.status == EditProfileStatus.error &&
        state.validationErrors.isNotEmpty) {
      state = state.copyWithProfile(state.profile);
    }

    return true;
  }

  /// Verificar si el username está disponible
  Future<bool> checkUsernameAvailability(String username) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) return false;

    try {
      return await _authRepository.isUsernameAvailable(
        username,
        currentUser.id,
      );
    } catch (e) {
      return false;
    }
  }

  /// Guardar los cambios del perfil
  Future<bool> saveProfile() async {
    // Validar primero
    if (!_validateProfile()) {
      return false;
    }

    final currentUser = _ref.read(currentUserProvider);
    final currentUserProfileAsync = _ref.read(currentUserProfileProvider);

    if (currentUser == null) {
      state = state.copyWithError('Usuario no autenticado');
      return false;
    }

    // Verificar si el username ha cambiado y está disponible
    await currentUserProfileAsync.when(
      data: (userProfile) async {
        if (userProfile != null &&
            state.profile.username != userProfile.username) {
          final isAvailable = await checkUsernameAvailability(
            state.profile.username,
          );
          if (!isAvailable) {
            state = state.copyWithValidationErrors([
              'El nombre de usuario ya está en uso',
            ]);
            return;
          }
        }
      },
      loading: () async {},
      error: (error, stack) async {},
    );

    // Si hay errores de validación, no continuar
    if (state.validationErrors.isNotEmpty) {
      return false;
    }

    state = state.copyWithLoading();

    try {
      // Actualizar perfil en Firestore
      await _authRepository.updateUserProfile(
        uid: currentUser.id,
        username: state.profile.username,
        currency: state.profile.currency,
        photoUrl: state.profile.photoUrl,
      );

      // Actualizar displayName en Firebase Auth si es diferente
      if (state.profile.username != currentUser.displayName) {
        try {
          await _authRepository.updateFirebaseDisplayName(
            state.profile.username,
          );
        } catch (e) {
          // No es crítico si falla la actualización en Firebase Auth
          print(
            'Warning: No se pudo actualizar displayName en Firebase Auth: $e',
          );
        }
      }

      // Actualizar photoUrl en Firebase Auth si es diferente
      if (state.profile.photoUrl != null &&
          state.profile.photoUrl != currentUser.photoUrl) {
        try {
          await _authRepository.updateFirebasePhotoUrl(state.profile.photoUrl!);
        } catch (e) {
          // No es crítico si falla la actualización en Firebase Auth
          print('Warning: No se pudo actualizar photoUrl en Firebase Auth: $e');
        }
      }

      // Invalidar el cache del perfil para que se recargue
      _ref.invalidate(currentUserProfileProvider);

      state = state.copyWithSuccess();
      return true;
    } catch (e) {
      String errorMessage = 'Error al actualizar el perfil';

      if (e is AuthException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Error inesperado: $e';
      }

      state = state.copyWithError(errorMessage);
      return false;
    }
  }

  /// Resetear el estado a inicial
  void reset() {
    state = EditProfileState.initial();
  }

  /// Limpiar errores
  void clearErrors() {
    if (state.status == EditProfileStatus.error) {
      state = state.copyWithProfile(state.profile);
    }
  }
}
