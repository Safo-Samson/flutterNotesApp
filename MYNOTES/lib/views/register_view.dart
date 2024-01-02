// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:developer' as devtols show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return const Placeholder(color: Colors.red);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register View'),
      ),
      body: Column(
        children: [
          TextField(
              controller: _emailController,
              enableSuggestions: false, // disable suggestions very important
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              )),
          TextField(
              controller: _passwordController,
              obscureText: true, // hide password
              enableSuggestions: false, // disable suggestions very important
              autocorrect:
                  false, // disable autocorrect very important foro password
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              )),
          TextButton(
            onPressed: () async {
              final email = _emailController.text;
              final password = _passwordController.text;
              try {
                await AuthService.firebase()
                    .createUser(email: email, password: password);

                // final user = FirebaseAuth.instance.currentUser;
                AuthService.firebase().getCurrentUser; // get current user
                AuthService.firebase()
                    .sendEmailVerification(); // send verification email to user email automatically

                Navigator.of(context).pushNamed(
                    verifyEmailRoute); // used pushNamed instead of pushNamedAndRemoveUntil because i dont want to replace the login screen but rather add the verify email screen on top of it.
              } on WeakPasswordAuthException {
                await showErrorDialog(context, 'Your password is weak.');
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, 'User Already Exists.');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Email is invalid.');
              } on GenericAuthException {
                await showErrorDialog(context, 'An error occured.');
              } 
              Navigator.of(context).pushNamedAndRemoveUntil(
                verifyEmailRoute,
                (route) => false,
              );
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Already registered? Login here')),
        ],
      ),
    );
  }
}
