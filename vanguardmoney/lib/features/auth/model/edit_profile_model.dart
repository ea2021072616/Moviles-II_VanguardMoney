/// Modelo para manejar los datos de edición del perfil
/// Separa los datos editables de los inmutables
class EditProfileModel {
  final String username;
  final String currency;
  final String? photoUrl;

  const EditProfileModel({
    required this.username,
    required this.currency,
    this.photoUrl,
  });

  /// Factory constructor desde UserProfileModel
  factory EditProfileModel.fromUserProfile(dynamic userProfile) {
    return EditProfileModel(
      username: userProfile?.username ?? '',
      currency: userProfile?.currency ?? 'S/',
      photoUrl: userProfile?.photoUrl,
    );
  }

  /// Factory constructor vacío
  factory EditProfileModel.empty() {
    return const EditProfileModel(username: '', currency: 'S/');
  }

  /// Método para copiar con nuevos valores
  EditProfileModel copyWith({
    String? username,
    String? currency,
    String? photoUrl,
  }) {
    return EditProfileModel(
      username: username ?? this.username,
      currency: currency ?? this.currency,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Convierte a Map para actualizaciones en Firestore
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> updateData = {};

    if (username.isNotEmpty) {
      updateData['username'] = username;
    }

    if (currency.isNotEmpty) {
      updateData['currency'] = currency;
    }

    if (photoUrl != null) {
      updateData['photoUrl'] = photoUrl;
    }

    return updateData;
  }

  /// Valida si los datos son válidos
  bool get isValid {
    return username.trim().isNotEmpty &&
        username.trim().length >= 3 &&
        currency.isNotEmpty;
  }

  /// Lista de errores de validación
  List<String> get validationErrors {
    final List<String> errors = [];

    if (username.trim().isEmpty) {
      errors.add('El nombre de usuario es requerido');
    } else if (username.trim().length < 3) {
      errors.add('El nombre de usuario debe tener al menos 3 caracteres');
    } else if (username.trim().length > 30) {
      errors.add('El nombre de usuario no puede tener más de 30 caracteres');
    }

    if (currency.isEmpty) {
      errors.add('La moneda es requerida');
    }

    return errors;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditProfileModel &&
        other.username == username &&
        other.currency == currency &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => Object.hash(username, currency, photoUrl);

  @override
  String toString() {
    return 'EditProfileModel(username: $username, currency: $currency, photoUrl: $photoUrl)';
  }
}

/// Estados posibles durante la edición del perfil
enum EditProfileStatus { initial, loading, success, error }

/// Clase para encapsular el estado y resultado de la edición
class EditProfileState {
  final EditProfileStatus status;
  final EditProfileModel profile;
  final String? errorMessage;
  final List<String> validationErrors;

  const EditProfileState({
    required this.status,
    required this.profile,
    this.errorMessage,
    this.validationErrors = const [],
  });

  /// Estado inicial
  factory EditProfileState.initial() {
    return EditProfileState(
      status: EditProfileStatus.initial,
      profile: EditProfileModel.empty(),
    );
  }

  /// Estado de carga
  EditProfileState copyWithLoading() {
    return EditProfileState(
      status: EditProfileStatus.loading,
      profile: profile,
    );
  }

  /// Estado de éxito
  EditProfileState copyWithSuccess() {
    return EditProfileState(
      status: EditProfileStatus.success,
      profile: profile,
    );
  }

  /// Estado de error
  EditProfileState copyWithError(String errorMessage) {
    return EditProfileState(
      status: EditProfileStatus.error,
      profile: profile,
      errorMessage: errorMessage,
    );
  }

  /// Estado con validación de errores
  EditProfileState copyWithValidationErrors(List<String> errors) {
    return EditProfileState(
      status: EditProfileStatus.error,
      profile: profile,
      validationErrors: errors,
    );
  }

  /// Actualizar el perfil
  EditProfileState copyWithProfile(EditProfileModel newProfile) {
    return EditProfileState(
      status: EditProfileStatus.initial,
      profile: newProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditProfileState &&
        other.status == status &&
        other.profile == profile &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, profile, errorMessage);
}
