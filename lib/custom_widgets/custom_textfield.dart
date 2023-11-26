import 'package:flutter/material.dart';

/// A custom text input field with a material design.
///
/// This widget represents a text input field with customizable properties such
/// as a controller, hintText, and visual appearance. It is commonly used for
/// capturing user input in a Flutter application.
class CustomTextField extends StatelessWidget {
  /// Creates a [CustomTextField].
  ///
  /// The [controller] and [hintText] parameters must not be null.
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  /// The controller for this text field. A TextEditingController can be used
  /// to control the text and to listen to changes.
  final TextEditingController controller;

  /// The text that is displayed in the input field when it is empty.
  final String hintText;

  @override
  Widget build(BuildContext context) {
    /// Builds the structure of the custom text field.
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xffF5F6FA),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
