import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/user_profile_model.dart';

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, this.code);

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

/// Repository que encapsula todas las operaciones de autenticación
/// Permite mockear para pruebas unitarias sin depender de Firebase
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream que escucha cambios en el estado de autenticación
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
      (User? user) => user != null ? UserModel.fromFirebaseUser(user) : null,
    );
  }

  /// Usuario actual (si existe)
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  /// Iniciar sesión con email y contraseña
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Verificar si el usuario está bloqueado por intentos fallidos
      final isBlocked = await isUserBlocked(email);
      if (isBlocked) {
        throw const AuthException(
          'Has superado el número de intentos. Intenta de nuevo más tarde',
          'too-many-attempts',
        );
      }

      final UserCredential result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      if (result.user == null) {
        throw const AuthException('Error al iniciar sesión', 'user-null');
      }

      // Login exitoso - reiniciar intentos fallidos
      await resetLoginAttempts(result.user!.uid);

      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      // Incrementar intentos fallidos en ciertos casos
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        await incrementLoginAttempts(email);
      }
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Registrar usuario con email y contraseña
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String currency,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (result.user == null) {
        throw const AuthException('Error al crear cuenta', 'user-null');
      }

      // Actualizar el displayName en Firebase Auth
      await result.user!.updateDisplayName(username);
      await result.user!.reload();

      // Crear perfil en Firestore
      final userProfile = UserProfileModel.fromFirebaseUser(
        uid: result.user!.uid,
        email: email.trim(),
        username: username,
        currency: currency,
        verified: true, // Marcamos como verificado directamente
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userProfile.toMap());

      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Iniciar sesión con Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          'Inicio de sesión cancelado',
          'google-signin-cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (result.user == null) {
        throw const AuthException(
          'Error al iniciar sesión con Google',
          'user-null',
        );
      }

      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } on PlatformException catch (e) {
      // Manejo específico de errores de Google Sign-In
      switch (e.code) {
        case 'sign_in_failed':
          throw const AuthException(
            'Error de configuración de Google Sign-In. Verifica que los SHA fingerprints estén configurados correctamente en Firebase.',
            'google-config-error',
          );
        case 'network_error':
          throw const AuthException(
            'Error de conexión. Verifica tu internet e intenta de nuevo.',
            'network-error',
          );
        case 'sign_in_canceled':
          throw const AuthException(
            'Inicio de sesión cancelado por el usuario.',
            'sign-in-cancelled',
          );
        default:
          throw AuthException('Error de Google Sign-In: ${e.message}', e.code);
      }
    } catch (e) {
      throw AuthException('Error inesperado con Google: $e', 'google-unknown');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      // Cerrar sesión de Firebase
      await _firebaseAuth.signOut();

      // Cerrar sesión de Google si está disponible
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e', 'signout-error');
    }
  }

  /// Obtener perfil de usuario desde Firestore
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw AuthException('Error al obtener perfil: $e', 'profile-error');
    }
  }

  /// Incrementar intentos fallidos de login
  Future<void> incrementLoginAttempts(String email) async {
    try {
      // Buscar usuario por email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final currentData = doc.data();
        final currentAttempts = currentData['loginAttempts'] ?? 0;

        await doc.reference.update({
          'loginAttempts': currentAttempts + 1,
          'lastAttempt': Timestamp.now(),
        });
      }
    } catch (e) {
      // No lanzar error aquí para no interrumpir el flujo de login
      print('Error al incrementar intentos: $e');
    }
  }

  /// Reiniciar intentos fallidos (al login exitoso)
  Future<void> resetLoginAttempts(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'loginAttempts': 0,
        'lastAttempt': null,
      });
    } catch (e) {
      // No lanzar error aquí para no interrumpir el flujo de login
      print('Error al reiniciar intentos: $e');
    }
  }

  /// Verificar si el usuario está bloqueado por intentos fallidos
  Future<bool> isUserBlocked(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final profile = UserProfileModel.fromMap(userData);
        return profile.isBlocked;
      }
      return false;
    } catch (e) {
      return false; // En caso de error, permitir el intento
    }
  }

  /// Enviar email para resetear contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Reautenticar usuario (para operaciones sensibles)
  Future<void> reauthenticateWithEmail(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user?.email == null) {
        throw const AuthException('Usuario no encontrado', 'user-not-found');
      }

      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Cambiar contraseña
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('Usuario no encontrado', 'user-not-found');
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Eliminar cuenta
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('Usuario no encontrado', 'user-not-found');
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Actualizar perfil del usuario en Firestore
  Future<UserProfileModel> updateUserProfile({
    required String uid,
    String? username,
    String? currency,
    String? photoUrl,
  }) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);

      // Preparar datos para actualizar
      final Map<String, dynamic> updateData = {};

      if (username != null && username.isNotEmpty) {
        updateData['username'] = username.trim();
      }

      if (currency != null && currency.isNotEmpty) {
        updateData['currency'] = currency;
      }

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      // Solo actualizar si hay datos para cambiar
      if (updateData.isNotEmpty) {
        await docRef.update(updateData);
      }

      // Obtener el perfil actualizado
      final updatedDoc = await docRef.get();
      if (!updatedDoc.exists) {
        throw const AuthException(
          'Perfil de usuario no encontrado',
          'profile-not-found',
        );
      }

      return UserProfileModel.fromMap(updatedDoc.data()!);
    } on FirebaseException catch (e) {
      throw AuthException('Error al actualizar perfil: ${e.message}', e.code);
    } catch (e) {
      throw AuthException(
        'Error inesperado al actualizar perfil: $e',
        'unknown',
      );
    }
  }

  /// Actualizar el displayName en Firebase Auth (opcional)
  Future<void> updateFirebaseDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('Usuario no encontrado', 'user-not-found');
      }

      await user.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Actualizar foto de perfil en Firebase Auth (opcional)
  Future<void> updateFirebasePhotoUrl(String photoUrl) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('Usuario no encontrado', 'user-not-found');
      }

      await user.updatePhotoURL(photoUrl);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Error inesperado: $e', 'unknown');
    }
  }

  /// Verificar si un username ya existe (para validación)
  Future<bool> isUsernameAvailable(String username, String currentUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .get();

      // Si no hay documentos, el username está disponible
      if (querySnapshot.docs.isEmpty) {
        return true;
      }

      // Si el único documento es del usuario actual, está disponible
      return querySnapshot.docs.length == 1 &&
          querySnapshot.docs.first.id == currentUid;
    } catch (e) {
      // En caso de error, asumir que no está disponible por seguridad
      return false;
    }
  }

  /// Obtener mensajes de error localizados
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email.';
      case 'user-not-found':
        return 'No se encontró ninguna cuenta con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El formato del email es inválido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'requires-recent-login':
        return 'Esta operación requiere autenticación reciente.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
