import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable // immutable class means that the class and its subclasses cannot be changed after it has been created
class AuthUser {
  // its optional because firebase doesnt require the email to be provided
  final String? email;
  final bool isEmailVerified;
  //required keyword means that the isEmailVerified property must be provided when creating a new instance of AuthUser, makes it a named parameter and adds more clarity to the code
  const AuthUser({this.email, required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      ); // factory constructor which creates a new instance of AuthUser from a Firebase User object and assigns the emailVerified property to the isEmailVerified property of AuthUser
}
