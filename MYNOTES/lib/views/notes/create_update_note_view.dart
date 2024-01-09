import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  // NewNotesViewState createState() => NewNotesViewState();
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController
      _textController; // to keep track of the text in the textfield

  Future<DatabaseNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNotes>();

    if (widgetNote != null) {
      // meaning the note already exists (user has tapped on an existing note to edit it)
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final exisitingNote = _note;
    if (exisitingNote != null) {
      // meaning the note already exists
      return exisitingNote;
    }
    // the getCurrentUser! is unwarpped (!) because we are sure that the user is logged in
    final currentUser = AuthService.firebase().getCurrentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
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
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
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
