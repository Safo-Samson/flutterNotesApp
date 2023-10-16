// this is a helper function to show an error dialog
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  // Navigator.pop(context); same as below
                  Navigator.of(context).pop();
                },
                child: const Text('Ok')),
          ],
        );
      });
}
