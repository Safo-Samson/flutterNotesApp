import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/new_notes_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email.dart';
// import 'dart:developer' as devtols show log;


void main() {
  WidgetsFlutterBinding.ensureInitialized(); // required by Firebase Core lib
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      newNoteRoute: (context) => const NewNotesView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // return const Placeholder(color: Colors.red);
    return FutureBuilder(
      // future: Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // ),
      future: AuthService.firebase()
          .initialize(), // initialize firebase using my AuthService rather than using the standard way of initializing firebase
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // final user = FirebaseAuth.instance.currentUser;
            final user = AuthService.firebase()
                .getCurrentUser; // get current user using my AuthService rather than using the standard way of getting current user
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          case ConnectionState.waiting:
          case ConnectionState.active:
          case ConnectionState.none:
            return const Center(child: CircularProgressIndicator());

          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

