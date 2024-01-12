class CloudStorageException implements Exception {
  const CloudStorageException();
}

// this is C in crud
class CouldNotCreateNoteException extends CloudStorageException {}

// this is R in crud
class CouldNoteGetAllNotesException extends CloudStorageException {}

// this is U in crud
class CouldNoteUpdateNoteException extends CloudStorageException {}

// this is D in crud
class CouldNoteDeleteNoteException extends CloudStorageException {}
