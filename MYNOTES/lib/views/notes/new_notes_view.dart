import 'package:flutter/material.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  NewNotesViewState createState() => NewNotesViewState();
}

class NewNotesViewState extends State<NewNotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: const Center(
        child: Text('Write your note here'),
      ),
    );
  }
}
