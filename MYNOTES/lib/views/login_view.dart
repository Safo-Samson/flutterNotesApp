// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:developer' as devtols show log;
// import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
    
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, 'No user found for that credentials.');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
                context, 'Wrong credentials provided for that user.');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication failed');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login View'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Plese login with your email and password'),

              TextField(
                  controller: _emailController,
                  enableSuggestions:
                      false, // disable suggestions very important
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
                  enableSuggestions:
                      false, // disable suggestions very important
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
                  context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                },
                child: const Text('Login'),
              ),
              TextButton(
                  onPressed: () {
                    // Navigator.of(context)
                    //     .pushNamedAndRemoveUntil(registerRoute, (route) => false);

                    context
                        .read<AuthBloc>()
                        .add(const AuthEventShouldRegister());
                  },
                  child: const Text('Not registered? Register here')),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                        AuthEventForgotPassword(email: _emailController.text));
                  },
                  child: const Text('Forgot password?')),
            ],
          ),
        ),
      ),
    );
  }
}
