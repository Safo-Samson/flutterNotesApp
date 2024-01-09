import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  // noteservice is a singleton class, meaning it will only be instantiated once
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes); // add the notes to the stream
      },
    );
  }
  factory NotesService() => _shared;
  Database? _db;
  //  a list of notes that are cached in memory
  List<DatabaseNotes> _notes = [];

  late final StreamController<List<DatabaseNotes>> _notesStreamController;

// reads all notes from the database and caches them in memory through the _notesStreamController
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

// a getter that returns the stream of notes
  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      return await getUser(email: email);
    } on CouldNotFindUser {
      return await createUser(email: email);
    } catch (e) {
      // this is mainly for debugging purposes
      rethrow;
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpened();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpened();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpened() async {
    try {
      await open();
    } on DatabaseAlreadyOpenedException {
      // do nothing
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);

      final db = await openDatabase(dbPath);
      _db = db;
      // create the tables if they don't exist
      await db.execute(createUserTable);
      await db.execute(createNotesTable);

      // cache all notes in memory now that the database is open
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (deletedCount == 0) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: userId, email: email.toLowerCase());
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    }

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();

    // make sure the user exists with the given email and get the user id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create the note
    const text = '';
    final noteId = db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNotes(
      id: noteId as int,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    // add the note to the cache
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final deletedCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      // remove the note from the cache
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable);

    // remove the note from the cache
    _notes = [];
    _notesStreamController.add(_notes);

    return deletedCount;
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);

      // update the cache
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }

    return notes.map((note) => DatabaseNotes.fromRow(note));
  }

  Future<DatabaseNotes> updateNote(
      {required DatabaseNotes note, required String text}) async {
    await _ensureDbIsOpened();
    final db = _getDatabaseOrThrow();

// make sure the note exists
    await getNote(id: note.id);

    final updatedCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);

      // update the cache
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[[idColumn]] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'Person{id: $id, email: $email}';
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNotes(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNotes.fromRow(Map<String, Object?> map) // constructor
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return 'Note{id: $id, userId: $userId, isSyncedWithCloud: $isSyncedWithCloud}';
  }

  @override
  bool operator ==(covariant DatabaseNotes other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

// file name
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// create user table
const createUserTable = '''
            CREATE TABLE IF NOT EXISTS "user" (
              "id"	INTEGER NOT NULL,
              "email"	TEXT NOT NULL UNIQUE,
              PRIMARY KEY("id" AUTOINCREMENT)
            );
          ''';

// create note table
const createNotesTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "User"("id"),
        PRIMARY KEY("id")
      );
      ''';
