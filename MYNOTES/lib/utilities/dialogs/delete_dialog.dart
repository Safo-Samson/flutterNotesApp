import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Delete',
      message: 'Are you sure you want to delete this note?',
      optionsBuilder: () => {
            'No': false,
            'Yes': true,
          }).then(
    (value) => value ?? false, // that is if the user presses outside the dialog
  );
}
