// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:developer' as devtols show log;

import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Your password is weak.');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'User Email Already Exists.');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Email is invalid.');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'An error occured.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register View'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Plese provide email and password to register'),
                TextField(
                    controller: _emailController,
                    enableSuggestions:
                        false, // disable suggestions very important
                    autocorrect: false,
                    autofocus: true,
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
          
                    context.read<AuthBloc>().add(AuthEventRegister(
                          email,
                          password,
                        ));
                  },
                  child: const Text('Register'),
                ),
                TextButton(
                    onPressed: () {
                      // Navigator.of(context).pushNamedAndRemoveUntil(
                      //   loginRoute,
                      //   (route) => false,
                      // );
          
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: const Text('Already registered? Login here')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
