import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtols show log;

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
                final FirebaseAuth auth = FirebaseAuth.instance;
                UserCredential userCredential =
                    await auth.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                devtols.log('userCredential: $userCredential');
                // print(userCredential);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  devtols.log('No user found for that email.');
                  // print('No user found for that email.');
                } else if (e.code == 'wrong-password') {
                  devtols.log('Wrong password provided for that user.');
                  // print('Wrong password provided for that user.');
                }
              }
              FirebaseAuth auth = FirebaseAuth.instance;
              UserCredential userCredential =
                  await auth.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
              devtols.log('userCredential: $userCredential');
              // print(userCredential);
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/register', (route) => false);
              },
              child: const Text('Not registered? Register here')),
        ],
      ),
    );
  }
}
