// ignore_for_file: use_build_context_synchronously

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email View'),
      ),
      body: Column(children: [
        const Text("We've sent you an email. Please open to verify your email"),
        const Text(
            "If you haven't received an email, please press the button below"),
        TextButton(
            onPressed: () async {
              // final user = FirebaseAuth.instance.currentUser;
              // await user?.sendEmailVerification();

              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send verification email')),
        TextButton(
            // in case the user makes a mistake or want to change email or restart the process
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              await AuthService.firebase().logOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (_) => false);
            },
            child: const Text("restart"))
      ]),
    );
  }
}
