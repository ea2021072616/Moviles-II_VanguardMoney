import 'user.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final User? user;
  final Map<String, dynamic>? errors;

  const AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.user,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      token: json['token']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  factory AuthResponse.error(String message, {Map<String, dynamic>? errors}) {
    return AuthResponse(success: false, message: message, errors: errors);
  }

  factory AuthResponse.success({String? message, String? token, User? user}) {
    return AuthResponse(
      success: true,
      message: message,
      token: token,
      user: user,
    );
  }
}
