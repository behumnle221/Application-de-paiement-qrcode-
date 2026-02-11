// lib/models/api_models.dart

// Réponse générique de l'API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

// LOGIN MODELS
class LoginRequest {
  final String emailOrPhone;
  final String password;

  LoginRequest({required this.emailOrPhone, required this.password});

  Map<String, dynamic> toJson() => {
    'emailOrPhone': emailOrPhone,
    'password': password,
  };
}

class LoginResponse {
  final String token;
  final int userId;
  final String email;
  final String telephone;
  final String role;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.telephone,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? 'CLIENT',
    );
  }
}

// REGISTRATION MODELS
class ClientRegisterRequest {
  final String nom;
  final String email;
  final String telephone;
  final String password;

  ClientRegisterRequest({
    required this.nom,
    required this.email,
    required this.telephone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'email': email,
    'telephone': telephone,
    'password': password,
  };
}

class VendeurRegisterRequest {
  final String nom;
  final String email;
  final String telephone;
  final String nomCommerce;
  final String adresse;
  final String password;

  VendeurRegisterRequest({
    required this.nom,
    required this.email,
    required this.telephone,
    required this.nomCommerce,
    required this.adresse,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'email': email,
    'telephone': telephone,
    'nomCommerce': nomCommerce,
    'adresse': adresse,
    'password': password,
  };
}

class UserResponse {
  final int id;
  final String nom;
  final String email;
  final String telephone;
  final String role;
  final DateTime dateInscription;

  UserResponse({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.role,
    required this.dateInscription,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? 'CLIENT',
      dateInscription:
          json['dateInscription'] != null
              ? DateTime.parse(json['dateInscription'])
              : DateTime.now(),
    );
  }
}
