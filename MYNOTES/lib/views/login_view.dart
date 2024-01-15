// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:developer' as devtols show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() {
    return _LoginViewState();
  }
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login View'),
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
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                // AuthService.firebase().logIn(email: email, password: password);
                // await AuthService.firebase()
                //     .logIn(email: email, password: password);
                // // navigate to notes view after sign in and making sure user is verified
                // final user = AuthService.firebase().getCurrentUser;
                // if (user?.isEmailVerified ?? false) {
                //   Navigator.of(context).pushNamedAndRemoveUntil(notesRoute,
                //       (route) => false); // navigate to notes view after sign in
                 
                // } else {
                //   Navigator.of(context).pushNamedAndRemoveUntil(
                //       verifyEmailRoute, (route) => false);
                 
                // }

              } on UserNotFoundAuthException {
                await showErrorDialog(context, 'No user found for that email.');
              } on WrongPasswordAuthException {
                await showErrorDialog(
                    context, 'Wrong password provided for that user.');
              } on GenericAuthException {
                // catch GenericAuthException
                await showErrorDialog(context, 'Authentication failed');
              }
              
    
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not registered? Register here')),
        ],
      ),
    );
  }
}
