import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// file name
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

class NotesService {
  Database? _db;

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

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);

      final db = await openDatabase(dbPath);
      _db = db;

      // create user table
      const createUserTable = '''
            CREATE TABLE IF NOT EXISTS "User" (
              "id"	INTEGER NOT NULL,
              "email"	TEXT NOT NULL UNIQUE,
              PRIMARY KEY("id" AUTOINCREMENT)
            );
          ''';

      await db.execute(createUserTable);

      // create note table
      const createNotesTable = '''
      CREATE TABLE IF NOT EXISTS "Notes" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "User"("id"),
        PRIMARY KEY("id")
      );
      ''';
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (deletedCount == 0) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
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
    final db = _getDatabaseOrThrow();

    // make sure the user exists with the given email and get the user id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create the note
    final text = '';
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

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable);

    return deletedCount;
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }

    return DatabaseNotes.fromRow(notes.first);
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
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
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatedCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    }

    return await getNote(id: note.id);
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
