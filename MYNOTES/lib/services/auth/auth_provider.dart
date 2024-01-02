import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {

  Future<void> initialize(); // method to initialize the auth provider
  AuthUser? get getCurrentUser; // getter method to get the current user
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }); // method to log in a user

  Future<AuthUser> createUser({
    required String email,
    required String password,
  }); // method to create a user account

  Future<void> logOut(); // method to log out a user

  Future<void> sendEmailVerification(); // method to send an email verification
}
