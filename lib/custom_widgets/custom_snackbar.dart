import 'package:flutter/material.dart';

/// Displays a SnackBar with the specified [text].
///
/// This function is a convenience method for showing a SnackBar using the
/// `ScaffoldMessenger` of the provided [context]. It creates a SnackBar
/// with a message provided by the [text] parameter and displays it in the UI.
///
/// Example:
/// ```dart
/// showSnackBar(context, 'This is a SnackBar message');
/// ```
///
/// Parameters:
/// - [context]: The build context associated with the current widget tree.
/// - [text]: The message text to display in the SnackBar.
void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
