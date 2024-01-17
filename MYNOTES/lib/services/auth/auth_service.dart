import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/Firebase_auth_provider.dart';

// purpose of this class is to relay messages of the given auth provider to the UI, however it can have more functionality
class AuthService implements AuthProvider {
  final AuthProvider authProvider;
  const AuthService(this.authProvider);

// factory constructor returns a firebase auth provider
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<void> initialize() => authProvider.initialize();
// if you use =>, then you can omit the return keyword
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) {
    return authProvider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get getCurrentUser => authProvider.getCurrentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      authProvider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => authProvider.logOut();

  @override
  Future<void> sendEmailVerification() => authProvider.sendEmailVerification();
  
  @override
  Future<void> sendPasswordReset({required String email}) =>
      authProvider.sendPasswordReset(email: email);
}
