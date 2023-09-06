import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // required by Firebase Core lib
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // return const Placeholder(color: Colors.red);
    return Scaffold(
        appBar: AppBar(
          title: const Text('HomePage'),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                print(FirebaseAuth.instance.currentUser);
                return const Text('Done');
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());

              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
