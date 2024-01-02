import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable // immutable class means that the class and its subclasses cannot be changed after it has been created
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user
      .emailVerified); // factory constructor which creates a new instance of AuthUser from a Firebase User object and assigns the emailVerified property to the isEmailVerified property of AuthUser
}
