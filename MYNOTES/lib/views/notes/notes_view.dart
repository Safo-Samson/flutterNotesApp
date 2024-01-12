// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_actions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
// import 'dart:developer' as devtols show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // late keyword means that the variable will be initialized later
  late final NotesService _notesService;
  // get the email of the user from firebase
  String get userEmail => AuthService.firebase().getCurrentUser!.email!;
  @override
  void initState() {
    _notesService = NotesService();
    // _notesService.open();  this is not needed because any function related to the database will open it automatically because of ensureDbIsOpened() function
    super.initState();
  }

  // theres no dispose function because the database will be closed automatically when the app is closed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Notes'),
          actions: [
            IconButton(
                onPressed: () {
                  // pusnNamed() is used to navigate to a route back to the previous route with the back button on the appbar
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon: const Icon(Icons.add)),
            PopupMenuButton<MenuAction>(onSelected: (action) async {
              switch (action) {
                case MenuAction.logout:
                  final result = await showLogOutDialog(context);

                  if (result) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
              }
            }, itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            }),
          ],
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _notesService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        // this is called fallthrough case
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            
                            final allNotes =
                                snapshot.data as List<DatabaseNotes>;
                            return NotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _notesService.deleteNote(
                                  id: note.id,
                                );
                              },
                              onTap: (note) {
                                Navigator.of(context).pushNamed(
                                    createOrUpdateNoteRoute,
                                    arguments: note);
                              },
                            );
                          } else {
                            return const Center(
                                child: Text('You have no notes yet'));
                          }
                        default:
                          return const Center(
                              child: CircularProgressIndicator());
                      }
                    });

              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }


// not sure why this is here but it is used to show a dialog when the user clicks on the logout button
  showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Logout')),
            ],
          );
        });
  }
}
