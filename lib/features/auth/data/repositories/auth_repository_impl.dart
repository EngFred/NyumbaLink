// ── iOS Setup Required ────────────────────────────────────────────────────────
// 1. Apple Sign-In entitlement:
//    Add <key>com.apple.developer.applesignin</key><array><string>Default</string></array>
//    to ios/Runner/Runner.entitlements
//
// 2. Google Sign-In OAuth client:
//    GoogleService-Info.plist must contain a CLIENT_ID key (the OAuth 2.0
//    client ID). This is generated automatically by the Firebase console when
//    you add an iOS app.
//
// 3. Google Sign-In URL scheme:
//    Copy the REVERSED_CLIENT_ID value from GoogleService-Info.plist and add
//    it as a CFBundleURLSchemes entry in ios/Runner/Info.plist so Google can
//    redirect back to the app after authentication:
//
//    <key>CFBundleURLTypes</key>
//    <array>
//      <dict>
//        <key>CFBundleURLSchemes</key>
//        <array>
//          <string>$(REVERSED_CLIENT_ID)</string>   <!-- from GoogleService-Info.plist -->
//        </array>
//      </dict>
//    </array>
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await _remoteDataSource.login(email, password);
    await _localDataSource.saveAuthData(
      response.accessToken,
      response.user as AuthUserModel,
    );
    return response;
  }

  @override
  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _remoteDataSource.register(name, email, password);
    await _localDataSource.saveAuthData(
      response.accessToken,
      response.user as AuthUserModel,
    );
    return response;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAuthData();
  }

  @override
  Future<AuthUser?> getCachedUser() async {
    return _localDataSource.getUser();
  }

  @override
  Future<String?> getCachedToken() async {
    return _localDataSource.getToken();
  }

  @override
  Future<AuthUser> updateProfile({String? name, String? email}) async {
    final Map<String, dynamic> data = {};
    if (name != null && name.isNotEmpty) data['name'] = name;
    if (email != null && email.isNotEmpty) data['email'] = email;

    final updatedUser = await _remoteDataSource.updateProfile(data);

    final token = await _localDataSource.getToken();
    if (token != null) {
      await _localDataSource.saveAuthData(token, updatedUser);
    }

    return updatedUser;
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _remoteDataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await _remoteDataSource.resetPassword(email, otp, newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    // Hit the server first (it blacklists the token there)
    await _remoteDataSource.deleteAccount();
    // Then clear local cache so the app treats this as a full logout
    await _localDataSource.clearAuthData();
  }

  @override
  Future<AuthResponse> googleSignIn() async {
    // 1. Trigger the account picker (replaces signIn())
    final googleUser = await GoogleSignIn.instance.authenticate();

    // 2. Get the ID token (now synchronous, not async)
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) throw Exception('Failed to retrieve Google ID token');

    // 3. Exchange with backend and persist session
    final response = await _remoteDataSource.googleSignIn(idToken);
    await _localDataSource.saveAuthData(
      response.accessToken,
      response.user as AuthUserModel,
    );
    return response;
  }

  @override
  Future<AuthResponse> appleSignIn() async {
    // 1. Trigger the native Apple sign-in sheet, requesting email + full name
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) {
      throw Exception('Failed to retrieve Apple identity token');
    }

    // 2. Exchange the token with our backend.
    // Apple only provides name/email on the VERY FIRST sign-in — the remote
    // datasource conditionally includes the user object when email is non-null.
    final response = await _remoteDataSource.appleSignIn(
      identityToken: identityToken,
      firstName: credential.givenName,
      lastName: credential.familyName,
      email: credential.email,
    );

    // 3. Persist the session locally, same as login/register
    await _localDataSource.saveAuthData(
      response.accessToken,
      response.user as AuthUserModel,
    );
    return response;
  }
}
