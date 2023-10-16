import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtols show log;

import 'package:mynotes/constants/routes.dart';

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
                final FirebaseAuth auth = FirebaseAuth.instance;
                UserCredential userCredential =
                    await auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                devtols.log('userCredential: $userCredential');
                // print(userCredential);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  devtols.log('The password provided is too weak.');
                } else if (e.code == 'email-already-in-use') {
                  devtols.log('The account already exists for that email.');
                } else if (e.code == 'weak-password') {
                  devtols.log('The password provided is too weak.');
                } else if (e.code == 'invalid-email') {
                  devtols.log('The email address is not valid.');
                } else if (e.code == 'email-already-in-use') {
                  devtols.log(
                      'The email address is already in use by another account.');
                }
              }
              FirebaseAuth auth = FirebaseAuth.instance;
              UserCredential userCredential =
                  await auth.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              devtols.log('userCredential: $userCredential');
              Navigator.of(context).pushNamedAndRemoveUntil(
                notesRoute,
                (route) => false,
              );
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(
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
