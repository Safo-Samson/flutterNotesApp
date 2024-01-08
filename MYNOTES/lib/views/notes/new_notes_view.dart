import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  // NewNotesViewState createState() => NewNotesViewState();
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController
      _textController; // to keep track of the text in the textfield

  Future<DatabaseNotes> createNewNote() async {
    final exisitingNote = _note;
    if (exisitingNote != null) {
      // meaning the note already exists
      return exisitingNote;
    }
    // the getCurrentUser! is unwarpped (!) because we are sure that the user is logged in
    final currentUser = AuthService.firebase().getCurrentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  // delete the note if the text is empty
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  // save the note if the text is not empty
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        text: _textController.text,
      );
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void initState() {
    // remember this is a singleton class so it will not create a new instance of the class
    _notesService = NotesService();
    _textController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Note'),
        ),
        body: FutureBuilder(
          future: createNewNote(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                // _note = snapshot.data as DatabaseNotes; // cast the snapshot.data to DatabaseNotes but it gives me an error
                _note = snapshot.data;
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter your note here',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // to make it multiline
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
