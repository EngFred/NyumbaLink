class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.provider,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String provider;

  bool get isSocialAuth => provider == 'GOOGLE' || provider == 'APPLE';
}

class AuthResponse {
  const AuthResponse({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;
}
